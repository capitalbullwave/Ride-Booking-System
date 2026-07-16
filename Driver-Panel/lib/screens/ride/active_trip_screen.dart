import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/geo_distance.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/navigation_launcher.dart';
import 'package:wavego_driver/models/payment_completion_data.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/slide_confirm_button.dart';
import 'package:wavego_driver/providers/ride_chat_provider.dart';
import 'package:wavego_driver/services/ride_realtime_service.dart';
import 'package:wavego_driver/widgets/ride/ride_chat_notification.dart';
import 'package:wavego_driver/widgets/ride/ride_chat_sheet.dart';
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
  final _tripMapController = TripMapController();
  String? _otpError;
  bool _otpSubmitting = false;
  bool _statusUpdating = false;
  bool _loading = true;
  bool _locatingMe = false;
  bool _cancelHandled = false;
  int _missingActiveRideCount = 0;
  int? _tripEtaMinutes;
  String? _tripDistanceLabel;
  Timer? _statusPollTimer;
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

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
    await showRideChatSheet(
      context: context,
      ref: ref,
      rideId: ride.id,
      peerName: ride.passengerName,
    );
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
      final ride = ref.read(rideViewModelProvider).activeRide;
      if (ride != null) _startRideRealtime(ride);
    });
  }

  void _startRideRealtime(ActiveRide ride) {
    final realtime = ref.read(rideRealtimeProvider);
    unawaited(realtime.connect());
    realtime.subscribeRide(ride.id);
    _realtimeSub?.cancel();
    _realtimeSub = realtime.messages.listen((msg) {
      if (!mounted) return;
      final event = msg['event']?.toString() ?? '';
      final msgRideId = msg['ride_id']?.toString();
      if (msgRideId != null && msgRideId != ride.id) return;

      if (event == 'ride_cancelled') {
        unawaited(_handleRideCancelled());
        return;
      }

      if (event != 'chat_message') return;
      if ((msg['sender_type']?.toString() ?? '') == 'driver') return;
      if (ref.read(rideChatSheetOpenProvider)) return;

      final text = msg['message']?.toString() ?? '';
      if (text.isEmpty) return;

      final currentRide = ref.read(rideViewModelProvider).activeRide ?? ride;
      showRideChatNotification(
        context,
        senderName: msg['sender_name']?.toString() ?? currentRide.passengerName,
        message: text,
        onTap: () => _messagePassenger(currentRide),
      );
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
    final rideState = ref.read(rideViewModelProvider);
    // Accept navigates here before POST /accept-ride finishes — skip cancel checks.
    if (rideState.isAccepting) return;

    final current = rideState.activeRide;
    if (current == null) return;
    if (current.status != 'heading_to_pickup' && current.status != 'arrived') {
      return;
    }

    final ride =
        await ref.read(rideViewModelProvider.notifier).refreshActiveRideStatus();
    if (!mounted || _cancelHandled) return;
    if (ride != null) {
      _missingActiveRideCount = 0;
      return;
    }

    // Require a few consecutive misses so a race with accept can't fake-cancel.
    _missingActiveRideCount += 1;
    if (_missingActiveRideCount >= 2) {
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
    _realtimeSub?.cancel();
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
    final primaryBusy = ride.status == 'arrived'
        ? _otpSubmitting
        : ride.status == 'started'
            ? _statusUpdating
            : false;
    final isStartingRide = ref.watch(rideViewModelProvider).isAccepting;
    final blockPrimaryAction = primaryBusy ||
        (ride.status == 'heading_to_pickup' && isStartingRide);

    final sheetFraction = ride.status == 'arrived'
        ? 0.68
        : ride.status == 'started'
            ? 0.34
            : 0.38;
    final myLocationBottom =
        MediaQuery.sizeOf(context).height * sheetFraction + 12;

    return Scaffold(
      body: Stack(
        children: [
          TripMapView(
            ride: ride,
            controller: _tripMapController,
            onTripMetrics: ({speedKmh, etaMinutes, distanceMeters}) {
              if (!mounted) return;
              setState(() {
                _tripEtaMinutes = etaMinutes;
                _tripDistanceLabel = distanceMeters != null
                    ? formatDistanceAway(distanceMeters)
                    : null;
              });
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: () => context.go(RouteNames.dashboard),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: sheetFraction,
            minChildSize: ride.status == 'started' ? 0.26 : 0.28,
            maxChildSize: ride.status == 'started' ? 0.42 : 0.78,
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
                    if (ride.status == 'started') ...[
                      _StartedTripSheet(
                        ride: ride,
                        etaMinutes: _tripEtaMinutes,
                        distanceLabel: _tripDistanceLabel,
                        onNavigate: () => _openNavigation(ride),
                        onCall: () => _callPassenger(ride),
                        onChat: () => _messagePassenger(ride),
                      ),
                      const SizedBox(height: 16),
                      SlideConfirmButton(
                        label: 'Complete ride',
                        enabled: !blockPrimaryAction,
                        isLoading: primaryBusy,
                        onConfirmed: () =>
                            _handleStatusAction(ride, currentAction.$1),
                      ),
                    ] else ...[
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
                          Icons.person_pin_circle,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ride.pickupAddress,
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
                          'When you reach pickup, slide to confirm arrival. Then enter the passenger\'s 4-digit start code from their Bull Wave Rides app.',
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (ride.status == 'heading_to_pickup')
                      SlideConfirmButton(
                        label: 'Arrived',
                        enabled: !blockPrimaryAction,
                        isLoading: primaryBusy,
                        onConfirmed: () =>
                            _handleStatusAction(ride, currentAction.$1),
                      )
                    else
                      AppButton(
                        label: currentAction.$3,
                        isLoading: blockPrimaryAction,
                        onPressed: blockPrimaryAction
                            ? null
                            : () => _handleStatusAction(ride, currentAction.$1),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          // Above bottom sheet (same pattern as user tracking screen).
          Positioned(
            right: 12,
            bottom: myLocationBottom,
            child: Material(
              color: Colors.white,
              elevation: 3,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _locatingMe
                    ? null
                    : () async {
                        setState(() => _locatingMe = true);
                        try {
                          await _tripMapController.goToMyLocation();
                        } finally {
                          if (mounted) setState(() => _locatingMe = false);
                        }
                      },
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: _locatingMe
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.my_location,
                          size: 22,
                          color: Color(0xFF1A73E8),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusAction(ActiveRide ride, String statusKey) async {
    final vm = ref.read(rideViewModelProvider.notifier);

    if (statusKey == 'heading_to_pickup') {
      // Show OTP entry immediately; sync "arrived" with the server in the background.
      vm.patchActiveRideStatus('arrived');
      WidgetsBinding.instance.addPostFrameCallback((_) => _expandSheetForOtp());

      try {
        await vm.updateStatus(ride.id, 'arrived');
      } catch (e) {
        if (!mounted) return;
        vm.patchActiveRideStatus('heading_to_pickup');
        context.showSnackBar(e.userMessage, isError: true);
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
      setState(() => _statusUpdating = true);
      try {
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
      } finally {
        if (mounted) setState(() => _statusUpdating = false);
      }
    }
  }
}

class _StartedTripSheet extends StatelessWidget {
  const _StartedTripSheet({
    required this.ride,
    required this.etaMinutes,
    required this.distanceLabel,
    required this.onNavigate,
    required this.onCall,
    required this.onChat,
  });

  final ActiveRide ride;
  final int? etaMinutes;
  final String? distanceLabel;
  final VoidCallback onNavigate;
  final VoidCallback onCall;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final eta = etaMinutes ?? 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Ride started',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
            children: [
              const TextSpan(text: 'Destination in '),
              TextSpan(
                text: '$eta min',
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          distanceLabel ?? 'Calculating route...',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.success),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ride.destinationAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          ride.passengerName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _ActionBtn(
              icon: Icons.navigation,
              label: 'Navigate',
              onTap: onNavigate,
            ),
            _ActionBtn(
              icon: Icons.phone,
              label: 'Call',
              onTap: onCall,
            ),
            _ActionBtn(
              icon: Icons.chat,
              label: 'Chat',
              onTap: onChat,
            ),
          ],
        ),
      ],
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
