class VehicleFareQuote {
  const VehicleFareQuote({
    required this.vehicleTypeId,
    required this.estimatedFare,
    this.originalFare,
    this.memberDiscount = 0,
    this.discountPercent = 0,
  });

  final String vehicleTypeId;
  final double estimatedFare;
  final double? originalFare;
  final double memberDiscount;
  final double discountPercent;

  bool get hasDiscount => memberDiscount > 0 || (originalFare ?? 0) > estimatedFare;

  factory VehicleFareQuote.fromJson(Map<String, dynamic> json) {
    return VehicleFareQuote(
      vehicleTypeId: json['vehicle_type_id']?.toString() ?? '',
      estimatedFare: (json['estimated_fare'] as num?)?.toDouble() ?? 0,
      originalFare: (json['original_fare'] as num?)?.toDouble(),
      memberDiscount: (json['member_discount'] as num?)?.toDouble() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RideFareEstimateResult {
  const RideFareEstimateResult({
    required this.discountPercent,
    required this.quotes,
  });

  final double discountPercent;
  final Map<String, VehicleFareQuote> quotes;
}
