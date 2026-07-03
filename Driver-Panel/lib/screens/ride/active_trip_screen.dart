import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/navigation_launcher.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  static const _statusFlow = [
    ('heading_to_pickup', 'Heading To Pickup', 'Arrived'),
    ('arrived', 'Arrived', 'Start Ride'),
    ('started', 'Ride Started', 'Complete Ride'),
  ];

  LatLng _navTarget(ActiveRide ride) {
    if (ride.status == 'started') {
      return LatLng(ride.destinationLat, ride.destinationLng);
    }
    return LatLng(ride.pickupLat, ride.pickupLng);
  }

  String _navLabel(ActiveRide ride) {
    return ride.status == 'started' ? 'Destination' : 'Pickup';
  }

  Future<void> _openNavigation(ActiveRide ride) async {
    final target = _navTarget(ride);
    final app = ref.read(navigationAppProvider);
    final launched = await NavigationLauncher.openMaps(
      lat: target.latitude,
      lng: target.longitude,
      label: _navLabel(ride),
      app: app,
    );
    if (!launched && mounted) {
      context.showSnackBar('Could not open navigation app', isError: true);
    }
  }

  Future<void> _callPassenger(ActiveRide ride) async {
    final phone = ride.passengerPhone;
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        context.showSnackBar('Passenger phone not available', isError: true);
      }
      return;
    }
    final launched = await NavigationLauncher.callPhone(phone);
    if (!launched && mounted) {
      context.showSnackBar('Could not open phone dialer', isError: true);
    }
  }

  Future<void> _messagePassenger(ActiveRide ride) async {
    final phone = ride.passengerPhone;
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        context.showSnackBar('Passenger phone not available', isError: true);
      }
      return;
    }
    final launched = await NavigationLauncher.sendSms(
      phone,
      body: 'Hi ${ride.passengerName}, I am your WaveGo Captain.',
    );
    if (!launched && mounted) {
      context.showSnackBar('Could not open messaging app', isError: true);
    }
  }

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
    final sheetColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
            onMapCreated: (_) {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: pickup,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: const InfoWindow(title: 'Pickup'),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: destination,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
                infoWindow: const InfoWindow(title: 'Destination'),
              ),
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
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
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
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentAction.$2,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ride.passengerName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.currency(ride.estimatedFare),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ActionBtn(
                          icon: Icons.navigation,
                          label: 'Navigate',
                          onTap: () => _openNavigation(ride),
                        ),
                        _ActionBtn(
                          icon: Icons.phone,
                          label: 'Call',
                          onTap: () => _callPassenger(ride),
                        ),
                        _ActionBtn(
                          icon: Icons.chat,
                          label: 'Chat',
                          onTap: () => _messagePassenger(ride),
                        ),
                        _ActionBtn(
                          icon: Icons.emergency,
                          label: 'SOS',
                          color: AppColors.error,
                          onTap: () => context.push(RouteNames.sos),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: currentAction.$3,
                      onPressed: () => _handleStatusAction(ride),
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

  Future<void> _handleStatusAction(ActiveRide ride) async {
    final vm = ref.read(rideViewModelProvider.notifier);

    if (ride.status == 'heading_to_pickup') {
      await vm.updateStatus(ride.id, 'arrived');
      return;
    }

    if (ride.status == 'arrived') {
      final otp = await _promptRideOtp();
      if (otp == null || !mounted) return;
      await vm.updateStatus(ride.id, 'started', otp: otp);
      return;
    }

    if (ride.status == 'started') {
      final payment = await vm.completeRide(ride.id);
      if (payment != null && mounted) {
        context.push(RouteNames.payment, extra: payment);
      }
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
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

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
