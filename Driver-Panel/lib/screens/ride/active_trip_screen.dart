import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  GoogleMapController? _mapController;

  static const _statusFlow = [
    ('heading_to_pickup', 'Heading To Pickup', 'Arrived'),
    ('arrived', 'Arrived', 'Start Ride'),
    ('started', 'Ride Started', 'Complete Ride'),
  ];

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideViewModelProvider).activeRide;
    if (ride == null) {
      return const Scaffold(body: Center(child: Text('No active ride')));
    }

    final pickup = LatLng(ride.pickupLat, ride.pickupLng);
    final destination = LatLng(ride.destinationLat, ride.destinationLng);
    final currentAction = _statusFlow.firstWhere(
      (s) => s.$1 == ride.status,
      orElse: () => _statusFlow.last,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
              Marker(markerId: const MarkerId('pickup'), position: pickup, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), infoWindow: InfoWindow(title: 'Pickup')),
              Marker(markerId: const MarkerId('destination'), position: destination, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), infoWindow: InfoWindow(title: 'Destination')),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: [pickup, destination],
                color: AppColors.primary,
                width: 4,
              ),
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    onPressed: () => context.push(RouteNames.sos),
                    style: IconButton.styleFrom(backgroundColor: AppColors.error),
                    icon: const Icon(Icons.emergency),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.25,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(currentAction.$2, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(ride.passengerName, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(DateFormatter.currency(ride.estimatedFare), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ActionBtn(icon: Icons.navigation, label: 'Navigate', onTap: () {}),
                        _ActionBtn(icon: Icons.phone, label: 'Call', onTap: () {}),
                        _ActionBtn(icon: Icons.chat, label: 'Chat', onTap: () {}),
                        _ActionBtn(icon: Icons.emergency, label: 'SOS', color: AppColors.error, onTap: () => context.push(RouteNames.sos)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: currentAction.$3,
                      onPressed: () => _handleStatusAction(ride, currentAction),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusAction(ActiveRide ride, (String, String, String) action) async {
    final vm = ref.read(rideViewModelProvider.notifier);
    switch (ride.status) {
      case 'heading_to_pickup':
        await vm.updateStatus(ride.id, 'arrived');
      case 'arrived':
        final otp = await _promptRideOtp();
        if (otp == null || !mounted) return;
        await vm.updateStatus(ride.id, 'started', otp: otp);
      case 'started':
        final payment = await vm.completeRide(ride.id);
        if (payment != null && mounted) {
          context.push(RouteNames.payment, extra: payment);
        }
      default:
        break;
    }
  }

  Future<String?> _promptRideOtp() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Ride OTP'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: 'Passenger OTP',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Start Ride'),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color ?? AppColors.primary),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
