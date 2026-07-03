import 'package:wavego_user/models/support_models.dart';
import 'package:wavego_user/services/base_api_service.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';

class SupportService extends BaseApiService {
  SupportService(super.dio);

  Future<List<FaqItem>> getFaq() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return const [
        FaqItem(
          id: '1',
          question: 'How do I book a ride?',
          answer: 'Enter pickup and drop locations, choose a vehicle, and confirm.',
        ),
        FaqItem(
          id: '2',
          question: 'What payment methods are supported?',
          answer: 'Cash, wallet, UPI, and card depending on your city.',
        ),
      ];
    }

    return get(
      ApiEndpoints.supportFaqs,
      parser: (data) {
        final List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          list = data['data'] as List<dynamic>? ?? [];
        } else {
          list = [];
        }
        return list
            .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<SupportTicketSummary> createTicket({
    required String subject,
    required String message,
    String? category,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return SupportTicketSummary(
        id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        subject: subject,
        status: 'open',
        createdAt: DateTime.now().toIso8601String(),
      );
    }

    return post(
      ApiEndpoints.createSupportTicket,
      data: {
        'subject': subject,
        'message': message,
        if (category != null) 'category': category,
      },
      parser: (data) =>
          SupportTicketSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<SupportTicketSummary>> getTickets() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return [];
    }

    return get(
      ApiEndpoints.supportTickets,
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map((e) =>
                SupportTicketSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<SupportTicketDetail> getTicket(String id) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return SupportTicketDetail(
        id: id,
        subject: 'Mock ticket',
        status: 'open',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        messages: const [],
      );
    }

    return get(
      '${ApiEndpoints.supportTickets}/$id',
      parser: (data) =>
          SupportTicketDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}
