import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class AmbulanceScreen extends StatelessWidget {
  const AmbulanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Ambulance'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency, color: AppColors.error, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Emergency Service',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Medical transport when every minute counts.',
                          style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select ambulance type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _AmbulanceTypeCard(
              title: 'Basic Life Support (BLS)',
              subtitle: 'Non-critical patient transport',
              eta: '8 min',
              price: '₹1,200',
              onTap: () => _showRequestSheet(context),
            ),
            const SizedBox(height: 12),
            _AmbulanceTypeCard(
              title: 'Advanced Life Support (ALS)',
              subtitle: 'Critical care with medical equipment',
              eta: '12 min',
              price: '₹2,500',
              onTap: () => _showRequestSheet(context),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Call SOS Hotline',
              variant: AppButtonVariant.danger,
              icon: Icons.phone,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm emergency request',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('An ambulance will be dispatched to your location immediately.'),
            const SizedBox(height: 24),
            AppButton(
              label: 'Request Ambulance',
              variant: AppButtonVariant.danger,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/ambulance/tracking');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbulanceTypeCard extends StatelessWidget {
  const _AmbulanceTypeCard({
    required this.title,
    required this.subtitle,
    required this.eta,
    required this.price,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String eta;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital, color: AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('ETA $eta', style: const TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                ),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class AmbulanceTrackingScreen extends StatelessWidget {
  const AmbulanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance on the way'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.muted,
              child: const Center(child: Icon(Icons.map, size: 64)),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Dr. Karan Patel • BLS Ambulance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Arriving in 8 minutes',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
