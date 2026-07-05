import 'dart:async';

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
  const PaymentScreen({super.key, required this.completion});

  final PaymentCompletionData completion;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _ratingPromptShown = false;
  bool _paymentCollected = false;
  bool _collecting = false;
  PaymentBreakdown? _payment;

  PaymentBreakdown get payment => _payment ?? widget.completion.payment;

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
      passengerName: widget.completion.passengerName,
    );

    if (result != null) {
      try {
        await ref.read(rideViewModelProvider.notifier).ratePassenger(
              widget.completion.rideId,
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

  Future<void> _onPaymentCollected() async {
    setState(() => _paymentCollected = true);
    await _promptRating();
  }

  Future<void> _collectCash() async {
    if (_collecting || _paymentCollected) return;
    setState(() => _collecting = true);
    try {
      final updated = await ref
          .read(rideViewModelProvider.notifier)
          .collectCashPayment(widget.completion.rideId);
      if (!mounted) return;
      setState(() => _payment = updated);
      context.showSnackBar('Cash payment collected successfully');
      await _onPaymentCollected();
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.userMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _collecting = false);
    }
  }

  Future<void> _collectOnline() async {
    if (_collecting || _paymentCollected) return;
    setState(() => _collecting = true);
    try {
      final qrData = await ref
          .read(rideViewModelProvider.notifier)
          .createOnlinePaymentQr(widget.completion.rideId);
      if (!mounted) return;

      if (qrData['payment_collected'] == true) {
        context.showSnackBar('Payment already collected');
        await _onPaymentCollected();
        return;
      }

      final shortUrl = qrData['short_url']?.toString() ?? '';
      final imageUrl = qrData['image_url']?.toString() ?? '';
      if (shortUrl.isEmpty && imageUrl.isEmpty) {
        throw Exception('Could not generate Razorpay payment QR');
      }

      final paid = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _RazorpayQrDialog(
          rideId: widget.completion.rideId,
          qrPayload: shortUrl.isNotEmpty ? shortUrl : imageUrl,
          useNetworkImage: shortUrl.isEmpty,
          amount: (qrData['amount'] as num?)?.toDouble() ?? payment.tripFare,
          onPollStatus: () => ref
              .read(rideViewModelProvider.notifier)
              .checkOnlinePaymentStatus(widget.completion.rideId),
        ),
      );

      if (paid == true && mounted) {
        context.showSnackBar('Online payment received');
        await _onPaymentCollected();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.userMessage, isError: true);
      }
    } finally {
      if (mounted) setState(() => _collecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collect Payment')),
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
              'Commission',
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
                enabled: !_collecting,
                onTap: _collectCash,
              ),
              const SizedBox(height: 12),
              _CollectOptionTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Online',
                subtitle: 'Show QR — passenger scans & pays via Razorpay',
                enabled: !_collecting,
                onTap: _collectOnline,
              ),
              if (_collecting) ...[
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
                  extra: widget.completion.rideId,
                ),
              ),
            ],
          ],
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

class _RazorpayQrDialog extends StatefulWidget {
  const _RazorpayQrDialog({
    required this.rideId,
    required this.qrPayload,
    required this.amount,
    required this.onPollStatus,
    this.useNetworkImage = false,
  });

  final String rideId;
  final String qrPayload;
  final double amount;
  final Future<bool> Function() onPollStatus;
  final bool useNetworkImage;

  @override
  State<_RazorpayQrDialog> createState() => _RazorpayQrDialogState();
}

class _RazorpayQrDialogState extends State<_RazorpayQrDialog> {
  Timer? _pollTimer;
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_checking || !mounted) return;
    setState(() => _checking = true);
    try {
      final paid = await widget.onPollStatus();
      if (paid && mounted) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan to Pay'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ask passenger to scan this QR and pay ${DateFormatter.currency(widget.amount)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: widget.useNetworkImage
                ? Image.network(
                    widget.qrPayload,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined, size: 48),
                  )
                : QrImageView(
                    data: widget.qrPayload,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_checking)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (_checking) const SizedBox(width: 8),
              Text(
                'Waiting for payment...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
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
