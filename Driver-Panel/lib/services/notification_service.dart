import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class NotificationService extends BaseApiService {
  NotificationService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<List<AppNotification>> getNotifications() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final list = await loadMockJsonList('notifications.json');
      return list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return get(
      ApiEndpoints.notifications,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> markAsRead(String id) async {
    if (useMock) return;
    await put('${ApiEndpoints.markNotificationRead}/$id');
  }
}

class DocumentService extends BaseApiService {
  DocumentService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<List<DocumentInfo>> getDocuments() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final list = await loadMockJsonList('documents.json');
      return list
          .map((e) => DocumentInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return get(
      ApiEndpoints.documents,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => DocumentInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

class SupportService extends BaseApiService {
  SupportService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<List<FaqItem>> getFaq() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final list = await loadMockJsonList('faq.json');
      return list.map((e) => FaqItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    return get(
      ApiEndpoints.faq,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list.map((e) => FaqItem.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  Future<List<SupportTicket>> getTickets() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final list = await loadMockJsonList('support_tickets.json');
      return list
          .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return get(
      ApiEndpoints.tickets,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> createTicket({required String subject, required String message}) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return;
    }

    await post(
      ApiEndpoints.createTicket,
      data: {'subject': subject, 'message': message},
    );
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    if (useMock) {
      final list = await loadMockJsonList('emergency_contacts.json');
      return list
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return get(
      ApiEndpoints.emergencyContacts,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>;
        return list
            .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<void> triggerSos({required double lat, required double lng}) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return;
    }

    await post(ApiEndpoints.sos, data: {'lat': lat, 'lng': lng});
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});

final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
