class StudentPassApplication {
  const StudentPassApplication({
    required this.id,
    required this.aadharNumber,
    required this.collegeName,
    this.aadharPhotoUrl,
    this.studentIdPhotoUrl,
    required this.status,
    required this.discountPercent,
    this.rejectionReason,
    this.verifiedAt,
  });

  final String id;
  final String aadharNumber;
  final String collegeName;
  final String? aadharPhotoUrl;
  final String? studentIdPhotoUrl;
  final String status;
  final double discountPercent;
  final String? rejectionReason;
  final String? verifiedAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  factory StudentPassApplication.fromJson(Map<String, dynamic> json) {
    return StudentPassApplication(
      id: json['id'] as String? ?? '',
      aadharNumber: json['aadhar_number'] as String? ?? '',
      collegeName: json['college_name'] as String? ?? '',
      aadharPhotoUrl: json['aadhar_photo_url'] as String?,
      studentIdPhotoUrl: json['student_id_photo_url'] as String?,
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 20,
      rejectionReason: json['rejection_reason'] as String?,
      verifiedAt: json['verified_at'] as String?,
    );
  }
}

class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.periodLabel,
    required this.benefits,
    required this.rideDiscountPercent,
    this.price = 0,
    this.isPopular = false,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final String priceLabel;
  final String periodLabel;
  final List<String> benefits;
  final double rideDiscountPercent;
  final double price;
  final bool isPopular;

  bool get isFree => price <= 0 || slug == 'free';

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final benefits = json['benefits'];
    return SubscriptionPlanModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? 'free',
      name: json['name'] as String? ?? 'Free',
      description: json['description'] as String? ?? '',
      priceLabel: json['price_label'] as String? ?? '₹0',
      periodLabel: json['period_label'] as String? ?? 'forever',
      benefits: benefits is List
          ? benefits.map((e) => e.toString()).toList()
          : const <String>[],
      rideDiscountPercent: (json['ride_discount_percent'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }
}

class SubscriptionCheckoutSession {
  const SubscriptionCheckoutSession({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.planSlug,
    required this.planName,
    this.contact,
    this.email,
    this.customerName,
  });

  final String orderId;
  final int amount;
  final String currency;
  final String keyId;
  final String planSlug;
  final String planName;
  final String? contact;
  final String? email;
  final String? customerName;

  factory SubscriptionCheckoutSession.fromJson(Map<String, dynamic> json) {
    final prefill = json['prefill'] as Map<String, dynamic>? ?? {};
    final plan = json['plan'] as Map<String, dynamic>? ?? {};
    return SubscriptionCheckoutSession(
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      keyId: (json['key_id'] ?? json['razorpay_key_id'] ?? '').toString().trim(),
      planSlug: plan['slug'] as String? ?? '',
      planName: plan['name'] as String? ?? 'Subscription',
      contact: prefill['contact'] as String?,
      email: prefill['email'] as String?,
      customerName: prefill['name'] as String?,
    );
  }

  factory SubscriptionCheckoutSession.fromWalletCheckout(Map<String, dynamic> json) {
    final checkout = json['checkout'] as Map<String, dynamic>? ?? json;
    final prefill = checkout['prefill'] as Map<String, dynamic>? ?? {};
    return SubscriptionCheckoutSession(
      orderId: checkout['order_id'] as String? ?? '',
      amount: (checkout['amount'] as num?)?.toInt() ?? 0,
      currency: checkout['currency'] as String? ?? 'INR',
      keyId: (checkout['key_id'] ?? checkout['razorpay_key_id'] ?? '').toString().trim(),
      planSlug: '',
      planName: checkout['description'] as String? ?? 'Wallet top-up',
      contact: prefill['contact'] as String?,
      email: prefill['email'] as String?,
      customerName: prefill['name'] as String?,
    );
  }
}
