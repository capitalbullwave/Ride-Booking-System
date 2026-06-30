import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/ride_model.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, required this.payment});

  final PaymentBreakdown payment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text('Trip Completed!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(DateFormatter.currency(payment.totalEarnings), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('Total Earnings', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Row('Payment Mode', payment.paymentMode),
            _Row('Trip Fare', DateFormatter.currency(payment.tripFare)),
            _Row('Commission', '- ${DateFormatter.currency(payment.commission)}', color: AppColors.error),
            if (payment.bonus > 0) _Row('Bonus', '+ ${DateFormatter.currency(payment.bonus)}', color: AppColors.success),
            const Divider(height: 32),
            _Row('Total Earnings', DateFormatter.currency(payment.totalEarnings), bold: true),
            const Spacer(),
            AppButton(
              label: 'View Summary',
              onPressed: () => context.pushReplacement(RouteNames.rideSummary),
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
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: color, fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}
