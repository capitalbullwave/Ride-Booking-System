class CashfreeCheckoutSession {
  const CashfreeCheckoutSession({
    required this.orderId,
    required this.paymentSessionId,
    required this.environment,
    required this.amount,
    required this.currency,
    required this.description,
    this.planSlug = '',
    this.planName = '',
    this.contact,
    this.email,
    this.customerName,
    this.appId,
  });

  final String orderId;
  final String paymentSessionId;
  final String environment;
  final int amount;
  final String currency;
  final String description;
  final String planSlug;
  final String planName;
  final String? contact;
  final String? email;
  final String? customerName;
  final String? appId;

  factory CashfreeCheckoutSession.fromJson(Map<String, dynamic> json) {
    final prefill = json['prefill'] as Map<String, dynamic>? ?? {};
    final plan = json['plan'] as Map<String, dynamic>? ?? {};
    return CashfreeCheckoutSession(
      orderId: (json['order_id'] ?? '').toString().trim(),
      paymentSessionId: (json['payment_session_id'] ?? '').toString().trim(),
      environment: (json['environment'] ?? 'sandbox').toString().trim().toLowerCase(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      description: (json['description'] ?? plan['name'] ?? 'Payment').toString(),
      planSlug: plan['slug'] as String? ?? '',
      planName: plan['name'] as String? ?? 'Subscription',
      contact: prefill['contact'] as String?,
      email: prefill['email'] as String?,
      customerName: prefill['name'] as String?,
      appId: json['app_id']?.toString(),
    );
  }

  factory CashfreeCheckoutSession.fromWalletCheckout(Map<String, dynamic> json) {
    final checkout = json['checkout'] is Map
        ? Map<String, dynamic>.from(json['checkout'] as Map)
        : json;
    return CashfreeCheckoutSession.fromJson({
      ...checkout,
      'description': checkout['description'] ?? 'Wallet top-up',
    });
  }

  bool get isReady => orderId.isNotEmpty && paymentSessionId.isNotEmpty;
}

class CashfreeCheckoutResult {
  const CashfreeCheckoutResult({required this.orderId});

  final String orderId;
}
