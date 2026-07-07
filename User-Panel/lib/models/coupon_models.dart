class RideCoupon {
  const RideCoupon({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderAmount = 0,
  });

  final String id;
  final String code;
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? maxDiscount;
  final double minOrderAmount;

  factory RideCoupon.fromJson(Map<String, dynamic> json) => RideCoupon(
        id: json['id']?.toString() ?? '',
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? json['code'] as String? ?? 'Offer',
        description: json['description'] as String?,
        discountType: json['discount_type'] as String? ?? 'flat',
        discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0,
        maxDiscount: (json['max_discount'] as num?)?.toDouble(),
        minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      );

  String get subtitle {
    if (discountType == 'percentage') {
      final cap = maxDiscount != null ? ' (up to ₹${maxDiscount!.round()})' : '';
      return '${discountValue.round()}% off$cap';
    }
    return '₹${discountValue.round()} off';
  }
}

class AppliedCoupon {
  const AppliedCoupon({
    required this.coupon,
    required this.discountAmount,
    required this.finalAmount,
  });

  final RideCoupon coupon;
  final double discountAmount;
  final double finalAmount;
}
