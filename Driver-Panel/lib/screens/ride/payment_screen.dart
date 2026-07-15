import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/models/payment_completion_data.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/ride/rate_passenger_dialog.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, this.completion});

  final PaymentCompletionData? completion;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _ratingPromptShown = false;
  bool _paymentCollected = false;
  bool _collectingCash = false;
  PaymentBreakdown? _payment;

  PaymentCompletionData? get _completion =>
      widget.completion ?? ref.watch(rideViewModelProvider).pendingPayment;

  PaymentBreakdown get payment =>
      _payment ?? _completion?.payment ?? const PaymentBreakdown(
        tripFare: 0,
        commission: 0,
        bonus: 0,
        totalEarnings: 0,
        paymentMode: 'CASH',
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardViewModelProvider.notifier).loadDashboard();
    });
  }

  Future<void> _promptRating() async {
    if (_ratingPromptShown || !mounted) return;
    _ratingPromptShown = true;

    final result = await showRatePassengerDialog(
      context,
      passengerName: _completion?.passengerName ?? 'Passenger',
    );

    if (result != null && _completion != null) {
      try {
        await ref.read(rideViewModelProvider.notifier).ratePassenger(
              _completion!.rideId,
              rating: result['rating'] as int? ?? 5,
              comment: result['comment'] as String?,
            );
        if (mounted) {
          context.showSnackBar('Thanks for your feedback!');
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.userMessage, isError: true);
        }
      }
    }
  }

  void _goHome() {
    ref.read(rideViewModelProvider.notifier).clearPendingPayment();
    ref.read(rideViewModelProvider.notifier).clearRide();
    context.go(RouteNames.dashboard);
  }

  Future<void> _onPaymentCollected() async {
    setState(() => _paymentCollected = true);
    ref.read(rideViewModelProvider.notifier).clearPendingPayment();
    await _promptRating();
  }

  Future<void> _collectCash() async {
    final completion = _completion;
    if (completion == null || _collectingCash || _paymentCollected) return;
    setState(() => _collectingCash = true);
    try {
      final updated = await ref
          .read(rideViewModelProvider.notifier)
          .collectCashPayment(completion.rideId);
      if (!mounted) return;
      setState(() => _payment = updated);
      context.showSnackBar('Cash payment collected successfully');
      await _onPaymentCollected();
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.userMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _collectingCash = false);
    }
  }

  Future<void> _collectOnline() async {
    final completion = _completion;
    if (completion == null || _paymentCollected) {
      if (completion == null && mounted) {
        context.showSnackBar('Payment details missing. Open ride from dashboard.', isError: true);
      }
      return;
    }

    final paid = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpiQrDialog(
        rideId: completion.rideId,
        amount: payment.tripFare,
        fetchQr: () => ref
            .read(rideViewModelProvider.notifier)
            .createOnlinePaymentQr(completion.rideId),
        onPollStatus: () => ref
            .read(rideViewModelProvider.notifier)
            .checkOnlinePaymentStatus(completion.rideId),
      ),
    );

    if (paid == true && mounted) {
      context.showSnackBar('UPI payment received');
      await _onPaymentCollected();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_completion == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _goHome();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goHome,
            ),
            title: const Text('Collect Payment'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment session expired. Complete the ride again or check trip history.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Go to Dashboard',
                    onPressed: _goHome,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final completion = _completion!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _goHome,
          ),
          title: const Text('Collect Payment'),
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  Icon(
                    _paymentCollected ? Icons.check_circle : Icons.receipt_long,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _paymentCollected ? 'Payment Received!' : 'Trip Completed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormatter.currency(payment.tripFare),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _paymentCollected ? 'Your earnings credited' : 'Amount to collect',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Row('Trip Fare', DateFormatter.currency(payment.tripFare)),
            _Row(
              'Platform commission',
              '- ${DateFormatter.currency(payment.commission)}',
              color: AppColors.error,
            ),
            if (payment.bonus > 0)
              _Row(
                'Bonus',
                '+ ${DateFormatter.currency(payment.bonus)}',
                color: AppColors.success,
              ),
            const Divider(height: 28),
            _Row(
              'Your Earnings',
              DateFormatter.currency(payment.totalEarnings),
              bold: true,
              color: AppColors.primary,
            ),
            if (!_paymentCollected) ...[
              const SizedBox(height: 28),
              Text(
                'How did the passenger pay?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a payment method to complete this ride',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
              const SizedBox(height: 16),
              _CollectOptionTile(
                icon: Icons.payments_outlined,
                title: 'Cash',
                subtitle: 'Passenger paid in cash',
                enabled: !_collectingCash,
                onTap: _collectCash,
              ),
              const SizedBox(height: 12),
              _CollectOptionTile(
                icon: Icons.qr_code_2_rounded,
                title: 'UPI',
                subtitle: 'Show dynamic QR — passenger scans & pays',
                enabled: !_collectingCash,
                onTap: _collectOnline,
              ),
              if (_collectingCash) ...[
                const SizedBox(height: 20),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Processing payment...',
                    style: TextStyle(color: AppColors.mutedForeground),
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 28),
              AppButton(
                label: 'View Summary',
                onPressed: () => context.pushReplacement(
                  RouteNames.rideSummary,
                  extra: completion.rideId,
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

class _CollectOptionTile extends StatelessWidget {
  const _CollectOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppColors.muted.withValues(alpha: 0.5),
            border: Border.all(
              color: enabled ? AppColors.border : AppColors.muted,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled ? AppColors.primary : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled ? AppColors.mutedForeground : AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpiQrDialog extends StatefulWidget {
  const _UpiQrDialog({
    required this.rideId,
    required this.amount,
    required this.fetchQr,
    required this.onPollStatus,
  });

  final String rideId;
  final double amount;
  final Future<Map<String, dynamic>> Function() fetchQr;
  final Future<bool> Function() onPollStatus;

  @override
  State<_UpiQrDialog> createState() => _UpiQrDialogState();
}

class _UpiQrDialogState extends State<_UpiQrDialog> {
  Timer? _pollTimer;
  bool _checking = false;
  bool _loadingQr = true;
  String? _networkImageUrl;
  String? _qrData;
  Uint8List? _base64ImageBytes;
  String? _error;

  static bool _isHttpUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static bool _isBase64Image(String value) =>
      value.startsWith('data:image') ||
      (value.length > 200 && !value.startsWith('upi://') && !_isHttpUrl(value));

  static Uint8List? _decodeBase64Image(String value) {
    try {
      var raw = value.trim();
      if (raw.contains(',')) {
        raw = raw.split(',').last;
      }
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQr();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _loadQr() async {
    try {
      final qrData = await widget.fetchQr();
      if (!mounted) return;

      if (qrData['payment_collected'] == true) {
        Navigator.of(context).pop(true);
        return;
      }

      final imageUrl = qrData['image_url']?.toString() ?? '';
      final imageContent = qrData['image_content']?.toString() ?? '';
      final shortUrl = qrData['short_url']?.toString() ?? '';

      String? networkImageUrl;
      String? qrPayload;
      Uint8List? base64Bytes;

      if (_isHttpUrl(imageUrl)) {
        networkImageUrl = imageUrl;
      } else if (imageContent.isNotEmpty && _isBase64Image(imageContent)) {
        base64Bytes = _decodeBase64Image(imageContent);
        if (base64Bytes == null) {
          qrPayload = imageContent;
        }
      } else if (imageContent.isNotEmpty) {
        qrPayload = imageContent;
      } else if (_isHttpUrl(shortUrl)) {
        networkImageUrl = shortUrl;
        qrPayload = shortUrl;
      } else if (shortUrl.isNotEmpty) {
        qrPayload = shortUrl;
      } else {
        throw Exception('Could not generate UPI payment QR');
      }

      setState(() {
        _loadingQr = false;
        _networkImageUrl = networkImageUrl;
        _qrData = qrPayload;
        _base64ImageBytes = base64Bytes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingQr = false;
        _error = e.userMessage;
      });
    }
  }

  Future<void> _retryQr() async {
    setState(() {
      _loadingQr = true;
      _error = null;
      _networkImageUrl = null;
      _qrData = null;
      _base64ImageBytes = null;
    });
    await _loadQr();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_checking || _loadingQr || _error != null || !mounted) return;
    setState(() => _checking = true);
    try {
      final paid = await widget.onPollStatus();
      if (paid && mounted) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.userMessage);
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Widget _buildQrVisual() {
    if (_base64ImageBytes != null) {
      return Image.memory(
        _base64ImageBytes!,
        width: 240,
        height: 240,
        fit: BoxFit.contain,
      );
    }
    if (_networkImageUrl != null) {
      return Image.network(
        _networkImageUrl!,
        width: 240,
        height: 240,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => _qrData != null
            ? QrImageView(
                data: _qrData!,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
              )
            : const Icon(Icons.broken_image_outlined, size: 48),
      );
    }
    return QrImageView(
      data: _qrData!,
      version: QrVersions.auto,
      size: 240,
      backgroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI QR Payment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        DateFormatter.currency(widget.amount),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: SizedBox(
                width: 240,
                height: 240,
                child: _loadingQr
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : _buildQrVisual(),
              ),
            ),
            if (_error == null) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_checking || _loadingQr)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_checking || _loadingQr) const SizedBox(width: 8),
                  Text(
                    _loadingQr ? 'Generating QR…' : 'Waiting for payment…',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _retryQr,
                child: const Text('Retry'),
              ),
            ],
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color, this.bold = false});
  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
