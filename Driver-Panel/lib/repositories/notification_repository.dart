import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/services/notification_service.dart';

class NotificationRepository {
  NotificationRepository(this._service);

  final NotificationService _service;

  Future<List<AppNotification>> getNotifications() =>
      _service.getNotifications();

  Future<void> markAsRead(String id) => _service.markAsRead(id);
}

class DocumentRepository {
  DocumentRepository(this._service);

  final DocumentService _service;

  Future<List<DocumentInfo>> getDocuments() => _service.getDocuments();
}

class SupportRepository {
  SupportRepository(this._service);

  final SupportService _service;

  Future<List<FaqItem>> getFaq() => _service.getFaq();
  Future<List<SupportTicket>> getTickets() => _service.getTickets();
  Future<void> createTicket({required String subject, required String message}) =>
      _service.createTicket(subject: subject, message: message);
  Future<List<EmergencyContact>> getEmergencyContacts() =>
      _service.getEmergencyContacts();
  Future<void> triggerSos({required double lat, required double lng}) =>
      _service.triggerSos(lat: lat, lng: lng);
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(notificationServiceProvider));
});

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(documentServiceProvider));
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.watch(supportServiceProvider));
});
