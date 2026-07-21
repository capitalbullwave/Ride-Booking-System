import 'package:wavego_driver/models/notification_model.dart';
import 'package:wavego_driver/models/ride_model.dart';

bool isRideRequestNotification(AppNotification notification) {
  if (notification.type != 'ride') return false;
  final data = notification.data;
  if (data == null) return false;
  return data['event'] == 'ride_request' && data['ride_id'] != null;
}

bool isActionableRideRequestNotification(AppNotification notification) {
  if (!isRideRequestNotification(notification)) return false;
  final outcome = notification.data?['outcome'];
  if (outcome != null && outcome.toString().isNotEmpty) return false;
  final actions = notification.data?['actions'];
  if (actions is List && actions.isEmpty) return false;
  return true;
}

String? rideIdFromNotification(AppNotification notification) {
  return notification.data?['ride_id']?.toString();
}

RideRequest? rideRequestFromNotification(AppNotification notification) {
  if (!isRideRequestNotification(notification)) return null;
  return rideRequestFromRealtimePayload(notification.data!);
}

RideRequest? rideRequestFromRealtimePayload(Map<String, dynamic> data) {
  if (data['event'] != 'ride_request' || data['ride_id'] == null) return null;
  final isCorporate = data['is_corporate'] == true ||
      (data['ride_type'] as String?) == 'CORPORATE';
  final companyName = data['company_name'] as String?;
  final passengerName = data['passenger_name'] as String? ?? 'Passenger';
  final paymentMode = data['payment_method'] as String? ?? 'CASH';
  return RideRequest(
    id: data['ride_id']?.toString() ?? '',
    pickupAddress: data['pickup_address'] as String? ?? '',
    destinationAddress: data['dropoff_address'] as String? ?? '',
    pickupLat: (data['pickup_lat'] as num?)?.toDouble() ?? 0,
    pickupLng: (data['pickup_lng'] as num?)?.toDouble() ?? 0,
    destinationLat: (data['dropoff_lat'] as num?)?.toDouble() ?? 0,
    destinationLng: (data['dropoff_lng'] as num?)?.toDouble() ?? 0,
    distance: (data['estimated_distance_km'] as num?)?.toDouble() ?? 0,
    estimatedTime:
        ((data['estimated_duration_min'] as num?)?.toDouble() ?? 0).round(),
    estimatedFare: (data['estimated_fare'] as num?)?.toDouble() ?? 0,
    paymentMode: isCorporate ? 'COMPANY' : paymentMode,
    passengerName: isCorporate && companyName != null && companyName.isNotEmpty
        ? '$passengerName · $companyName'
        : passengerName,
    passengerPhone: data['passenger_phone'] as String?,
    expiresIn: 60,
  );
}
