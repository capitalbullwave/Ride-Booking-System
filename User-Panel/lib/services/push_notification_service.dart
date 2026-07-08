import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';
import 'package:wavego_user/services/base_api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM background: ${message.messageId} ${message.data}');
}

typedef NotificationNavigationHandler = void Function(Map<String, dynamic> data);

class PushNotificationService extends BaseApiService {
  PushNotificationService(super.dio, this._secureStorage);

  final SecureStorageService _secureStorage;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _currentToken;
  NotificationNavigationHandler? onNavigate;

  static const AndroidNotificationChannel _rideChannel =
      AndroidNotificationChannel(
    'ride',
    'Ride Alerts',
    description: 'Trip updates and driver status',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _walletChannel =
      AndroidNotificationChannel(
    'wallet',
    'Wallet',
    description: 'Wallet and payment updates',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel _promoChannel =
      AndroidNotificationChannel(
    'promotion',
    'Promotions',
    description: 'Offers and promotions',
    importance: Importance.low,
  );

  static const AndroidNotificationChannel _adminChannel =
      AndroidNotificationChannel(
    'admin',
    'Admin & System',
    description: 'Announcements and system alerts',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel _emergencyChannel =
      AndroidNotificationChannel(
    'emergency',
    'Emergency',
    description: 'Emergency alerts',
    importance: Importance.max,
  );

  Future<bool> initialize() async {
    if (_initialized) return true;
    if (kIsWeb) return false;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase.initializeApp failed (add google-services.json): $e');
      return false;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final raw = response.payload;
        if (raw == null || raw.isEmpty) return;
        try {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          onNavigate?.call(data);
        } catch (_) {}
      },
    );

    if (Platform.isAndroid) {
      final android = _local.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_rideChannel);
      await android?.createNotificationChannel(_walletChannel);
      await android?.createNotificationChannel(_promoChannel);
      await android?.createNotificationChannel(_adminChannel);
      await android?.createNotificationChannel(_emergencyChannel);
      await android?.requestNotificationsPermission();
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNavigate?.call(Map<String, dynamic>.from(message.data));
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      Future.microtask(
        () => onNavigate?.call(Map<String, dynamic>.from(initial.data)),
      );
    }

    messaging.onTokenRefresh.listen((token) async {
      _currentToken = token;
      debugPrint('========== FCM TOKEN (refresh) ==========');
      debugPrint(token);
      debugPrint('=========================================');
      await syncTokenToBackend(token);
    });

    _initialized = true;
    await refreshAndSyncToken();
    return true;
  }

  Future<String?> refreshAndSyncToken() async {
    if (!_initialized) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      _currentToken = token;
      if (token != null) {
        debugPrint('========== FCM TOKEN ==========');
        debugPrint(token);
        debugPrint('===============================');
        await syncTokenToBackend(token);
      }
      return token;
    } catch (e) {
      debugPrint('FCM getToken failed: $e');
      return null;
    }
  }

  Future<void> syncTokenToBackend([String? token]) async {
    final value = token ?? _currentToken;
    if (value == null || value.isEmpty) return;
    final access = await _secureStorage.read(AppConstants.accessTokenKey);
    if (access == null || access.isEmpty) return;

    try {
      await post(
        ApiEndpoints.deviceToken,
        data: {
          'fcm_token': value,
          'device_type': Platform.isIOS ? 'ios' : 'android',
          'device_id': value.substring(0, value.length.clamp(0, 40)),
        },
      );
      debugPrint('FCM token synced to backend');
    } catch (e) {
      debugPrint('FCM token sync failed: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'Bull Wave Rides';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';
    final channelId = _channelFor(message.data);

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  String _channelFor(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['event'] ?? '').toString().toLowerCase();
    if (type.contains('wallet') || type.contains('payment')) {
      return _walletChannel.id;
    }
    if (type.contains('promo') || type.contains('offer')) {
      return _promoChannel.id;
    }
    if (type.contains('admin') || type.contains('system')) {
      return _adminChannel.id;
    }
    if (type.contains('emergency') || type.contains('sos')) {
      return _emergencyChannel.id;
    }
    return _rideChannel.id;
  }

  static void navigateFromPayload(
    void Function(String location) go,
    Map<String, dynamic> data,
  ) {
    final event = (data['event'] ?? data['type'] ?? data['screen'] ?? '')
        .toString()
        .toLowerCase();
    if (event.contains('wallet') || event.contains('payment')) {
      go(RouteNames.wallet);
      return;
    }
    if (event.contains('subscription')) {
      go(RouteNames.profileSubscription);
      return;
    }
    if (event.contains('promo') || event.contains('offer')) {
      go(RouteNames.home);
      return;
    }
    if (event.contains('accepted') ||
        event.contains('arrived') ||
        event.contains('started') ||
        event.contains('tracking') ||
        event == 'live_tracking') {
      go(RouteNames.bookTracking);
      return;
    }
    if (event.contains('completed')) {
      go(RouteNames.bookings);
      return;
    }
    go(RouteNames.notifications);
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    ref.watch(dioClientProvider).dio,
    ref.watch(secureStorageProvider),
  );
});
