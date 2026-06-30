import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.item});

  final ActivityItem item;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(item.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(color: _statusColor(item.status), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.place, size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.address)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Text(item.date),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (item.status.toLowerCase() == 'completed') ...[
            AppButton(
              label: 'Book again',
              onPressed: () {
                Navigator.pop(context);
                context.showSnackBar('Opening ride booking...');
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Get help with this trip',
              variant: AppButtonVariant.outline,
              onPressed: () => context.showSnackBar('Support ticket created'),
            ),
          ] else if (item.status.toLowerCase() == 'cancelled') ...[
            AppButton(
              label: 'Book a new ride',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
