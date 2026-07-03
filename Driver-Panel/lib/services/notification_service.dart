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
      return _fromMockList(await loadMockJsonList('notifications.json'));
    }

    final data = await get<dynamic>(
      ApiEndpoints.driverNotifications,
      queryParameters: {'page': 1, 'page_size': 50},
      parser: (raw) => raw,
    );
    return _parseNotificationList(data);
  }

  List<AppNotification> _fromMockList(List<dynamic> list) {
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<AppNotification> _parseNotificationList(dynamic data) {
    final List<dynamic> raw;
    if (data is List) {
      raw = data;
    } else if (data is Map<String, dynamic>) {
      final nested = data['data'] ?? data['items'] ?? data['notifications'];
      if (nested is! List) return [];
      raw = nested;
    } else {
      return [];
    }

    return raw.map((item) {
      final map = item as Map<String, dynamic>;
      return AppNotification.fromJson({
        'id': map['id']?.toString() ?? '',
        'title': map['title'] as String? ?? 'Notification',
        'body': map['body'] as String? ?? map['message'] as String? ?? '',
        'type': _mapType(
          map['type'] as String? ?? map['notification_type'] as String?,
        ),
        'read': map['read'] as bool? ?? map['is_read'] as bool? ?? false,
        'created_at':
            map['created_at'] as String? ?? DateTime.now().toIso8601String(),
        if (map['data'] != null) 'data': map['data'],
      });
    }).toList();
  }

  String _mapType(String? raw) {
    switch ((raw ?? 'system').toLowerCase()) {
      case 'ride':
        return 'ride';
      case 'promo':
      case 'offer':
        return 'offer';
      case 'payment':
      case 'bonus':
        return 'bonus';
      case 'expiry':
        return 'expiry';
      default:
        return 'system';
    }
  }

  Future<void> markAsRead(String id) async {
    if (useMock) return;
    await put('${ApiEndpoints.driverNotifications}/$id/read');
  }

  Future<void> markAllRead() async {
    if (useMock) return;
    await put('${ApiEndpoints.driverNotifications}/read-all');
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
        final List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          list = data['data'] as List<dynamic>? ?? [];
        } else {
          list = [];
        }
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
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<Map<String, dynamic>> getTicketDetail(String id) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return {
        'id': id,
        'subject': 'Mock ticket',
        'status': 'open',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'messages': <dynamic>[],
      };
    }

    return get(
      '${ApiEndpoints.tickets}/$id',
      parser: (data) => data as Map<String, dynamic>,
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
      ApiEndpoints.driverEmergencyContacts,
      parser: (data) => _parseEmergencyContacts(data),
    );
  }

  List<EmergencyContact> _parseEmergencyContacts(dynamic data) {
    final List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ?? [];
    } else {
      list = [];
    }
    return list
        .map((e) => EmergencyContact.fromJson({
              'id': (e as Map<String, dynamic>)['id']?.toString() ?? '',
              'name': e['name'] as String? ?? '',
              'phone': e['phone'] as String? ?? '',
              'relation': e['relation'] as String?,
            }))
        .toList();
  }

  Future<EmergencyContact> createEmergencyContact({
    required String name,
    required String phone,
    String? relation,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return EmergencyContact(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        relation: relation,
      );
    }

    return post(
      ApiEndpoints.driverEmergencyContacts,
      data: {
        'name': name,
        'phone': phone,
        if (relation != null) 'relation': relation,
      },
      parser: (data) => EmergencyContact.fromJson({
        ...(data as Map<String, dynamic>),
        'id': (data)['id']?.toString() ?? '',
      }),
    );
  }

  Future<EmergencyContact> updateEmergencyContact({
    required String id,
    required String name,
    required String phone,
    String? relation,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return EmergencyContact(id: id, name: name, phone: phone, relation: relation);
    }

    return put(
      '${ApiEndpoints.driverEmergencyContacts}/$id',
      data: {
        'name': name,
        'phone': phone,
        'relation': relation,
      },
      parser: (data) => EmergencyContact.fromJson({
        ...(data as Map<String, dynamic>),
        'id': (data)['id']?.toString() ?? id,
      }),
    );
  }

  Future<void> deleteEmergencyContact(String id) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return;
    }

    await delete('${ApiEndpoints.driverEmergencyContacts}/$id');
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
