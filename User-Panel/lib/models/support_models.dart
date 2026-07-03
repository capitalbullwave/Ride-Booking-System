class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
  });

  final String id;
  final String question;
  final String answer;
  final String? category;

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String?,
    );
  }
}

class SupportTicketSummary {
  const SupportTicketSummary({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String subject;
  final String status;
  final String createdAt;
  final String? updatedAt;

  factory SupportTicketSummary.fromJson(Map<String, dynamic> json) {
    return SupportTicketSummary(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? 'Support request',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class SupportTicketMessage {
  const SupportTicketMessage({
    required this.id,
    required this.sender,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String sender;
  final String senderType;
  final String message;
  final String createdAt;

  bool get isAdmin => senderType == 'admin';

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: json['id']?.toString() ?? '',
      sender: json['sender'] as String? ?? 'Support',
      senderType: json['sender_type'] as String? ?? 'user',
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}

class SupportTicketDetail {
  const SupportTicketDetail({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String subject;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<SupportTicketMessage> messages;

  factory SupportTicketDetail.fromJson(Map<String, dynamic> json) {
    final raw = json['messages'] as List<dynamic>? ?? [];
    return SupportTicketDetail(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? 'Support request',
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      messages: raw
          .map((e) => SupportTicketMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
