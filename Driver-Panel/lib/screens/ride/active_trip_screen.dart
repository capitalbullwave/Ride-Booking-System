import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/navigation_launcher.dart';
import 'package:wavego_driver/models/payment_completion_data.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/ride/trip_map_view.dart';

class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({super.key});

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  static const _statusFlow = [
    ('heading_to_pickup', 'Heading To Pickup', 'Arrived at pickup'),
    ('arrived', 'At Pickup — enter start code', 'Start ride'),
    ('started', 'Ride Started', 'Complete Ride'),
  ];

  final _otpController = TextEditingController();
  final _sheetController = DraggableScrollableController();
  String? _otpError;
  bool _otpSubmitting = false;
  bool _statusUpdating = false;
  bool _loading = true;
  bool _cancelHandled = false;
  Timer? _statusPollTimer;

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
      body: 'Hi ${ride.passengerName}, I am your Fast Bull Captain.',
    );
    if (!launched && mounted) {
      context.showSnackBar('Could not open messaging app', isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    if (ref.read(rideViewModelProvider).activeRide != null) {
      _loading = false;
    }
    Future.microtask(() async {
      if (ref.read(rideViewModelProvider).activeRide == null) {
        await ref.read(rideViewModelProvider.notifier).restoreActiveRide();
      }
      if (!mounted) return;
      if (ref.read(rideViewModelProvider).activeRide == null) {
        context.go(RouteNames.dashboard);
        return;
      }
      setState(() => _loading = false);
      _startStatusPolling();
    });
  }

  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollRideStatus();
    });
  }

  Future<void> _pollRideStatus() async {
    if (_cancelHandled || !mounted) return;
    final current = ref.read(rideViewModelProvider).activeRide;
    if (current == null) return;
    if (current.status != 'heading_to_pickup' && current.status != 'arrived') {
      return;
    }

    final ride =
        await ref.read(rideViewModelProvider.notifier).refreshActiveRideStatus();
    if (!mounted || _cancelHandled) return;
    if (ride == null) {
      await _handleRideCancelled();
    }
  }

  Future<void> _handleRideCancelled() async {
    if (_cancelHandled || !mounted) return;
    _cancelHandled = true;
    _statusPollTimer?.cancel();
    ref.read(rideViewModelProvider.notifier).clearRide();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 48),
        title: const Text('Ride cancelled'),
        content: const Text(
          'The passenger cancelled this ride. You can accept new requests from the home screen.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (mounted) context.go(RouteNames.dashboard);
  }

  void _expandSheetForOtp() {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      0.68,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    _sheetController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rideViewModelProvider.select((s) => s.activeRide?.status), (prev, next) {
      if (next == 'arrived' && prev != 'arrived') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _expandSheetForOtp());
      }
    });

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ride = ref.watch(rideViewModelProvider).activeRide;
    if (ride == null) {
      return const Scaffold(
        body: Center(child: Text('No active ride')),
      );
    }

    final currentAction = _statusFlow.firstWhere(
      (s) => s.$1 == ride.status,
      orElse: () => _statusFlow.last,
    );
    final sheetColor = Theme.of(context).colorScheme.surface;
    final primaryBusy = _statusUpdating || _otpSubmitting;
    final isStartingRide = ref.watch(rideViewModelProvider).isAccepting;

    return Scaffold(
      body: Stack(
        children: [
          TripMapView(ride: ride),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () => context.go(RouteNames.dashboard),
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
            controller: _sheetController,
            initialChildSize: ride.status == 'arrived' ? 0.68 : 0.38,
            minChildSize: 0.28,
            maxChildSize: 0.78,
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
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          ride.status == 'started'
                              ? Icons.location_on
                              : Icons.person_pin_circle,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ride.status == 'started'
                                ? ride.destinationAddress
                                : ride.pickupAddress,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ride.passengerName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                    Text(
                      ride.paymentMode,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (ride.status == 'heading_to_pickup') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'When you reach pickup, tap "Arrived at pickup". Then enter the passenger\'s 4-digit start code from their Fast Bull app.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                    if (ride.status == 'arrived') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.pin, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ask the passenger for their Ride start code shown in the app.',
                                style: TextStyle(fontSize: 12, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Passenger start code',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(
                          fontSize: 32,
                          letterSpacing: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0 0 0 0',
                          counterText: '',
                          errorText: _otpError,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          if (_otpError != null) setState(() => _otpError = null);
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wrong code will not start the ride.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
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
                      isLoading: primaryBusy || isStartingRide,
                      onPressed: (primaryBusy || isStartingRide)
                          ? null
                          : () => _handleStatusAction(ride, currentAction.$1),
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

  Future<void> _handleStatusAction(ActiveRide ride, String statusKey) async {
    final vm = ref.read(rideViewModelProvider.notifier);

    if (statusKey == 'heading_to_pickup') {
      setState(() => _statusUpdating = true);
      try {
        await vm.updateStatus(ride.id, 'arrived');
        if (mounted) {
          vm.patchActiveRideStatus('arrived');
          _expandSheetForOtp();
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.userMessage, isError: true);
        }
      } finally {
        if (mounted) setState(() => _statusUpdating = false);
      }
      return;
    }

    if (statusKey == 'arrived') {
      final code = _otpController.text.trim();
      if (code.length < 4) {
        setState(() => _otpError = 'Enter the 4-digit code from passenger app');
        return;
      }
      setState(() {
        _otpSubmitting = true;
        _otpError = null;
      });
      _statusPollTimer?.cancel();
      try {
        await ref.read(rideViewModelProvider.notifier).startRideWithOtp(ride.id, code);
        if (mounted) {
          _otpController.clear();
          context.showSnackBar('Ride started');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _otpError = e.userMessage);
        }
      } finally {
        if (mounted) {
          setState(() => _otpSubmitting = false);
          _startStatusPolling();
        }
      }
      return;
    }

    if (statusKey == 'started') {
      final payment = await vm.completeRide(ride.id);
      if (payment != null && mounted) {
        context.pushReplacement(
          RouteNames.payment,
          extra: PaymentCompletionData(
            payment: payment,
            rideId: ride.id,
            passengerName: ride.passengerName,
          ),
        );
      }
    }
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
