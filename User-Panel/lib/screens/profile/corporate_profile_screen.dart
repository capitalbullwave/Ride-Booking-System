import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/corporate_models.dart';
import 'package:wavego_user/services/corporate_service.dart';

class CorporateProfileScreen extends ConsumerWidget {
  const CorporateProfileScreen({super.key});

  Future<void> _openCompanyRegistration(BuildContext context) async {
    final uri = Uri.parse(AppConfig.corporateRegisterUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Open this link to register: ${AppConfig.corporateRegisterUrl}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync = ref.watch(corporateMembershipProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Corporate')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(corporateMembershipProvider);
          await ref.read(corporateMembershipProvider.future);
        },
        child: membershipAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Unable to load corporate membership.\nMake sure the backend is running.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(corporateMembershipProvider),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
          data: (membership) {
            if (membership.isCorporateMember) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  _MembershipCard(membership: membership),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      membership.canBookCorporate
                          ? 'You can book Corporate Rides from the Choose a ride screen. Toggle Corporate Ride ON — payment will show Paid by Company.'
                          : 'Your company or employee status is not active yet. Ask your company admin / platform admin to approve.',
                      style: TextStyle(color: AppColors.mutedForeground, height: 1.4),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              children: [
                const Icon(
                  Icons.business_center_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No corporate membership yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'If you are an employee, ask your company admin to add your phone number.\n\n'
                  'If you represent a company, apply for Bull Wave Rides for Business on our website. '
                  'Registration is reviewed by our team before activation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.mutedForeground, height: 1.45),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _openCompanyRegistration(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Apply for company registration'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Opens the secure registration page in your browser.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership});

  final CorporateMembership membership;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corporate Membership',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _row('Company', membership.companyName ?? '—'),
          _row('Employee Code', membership.employeeCode ?? '—'),
          _row('Department', membership.department ?? '—'),
          _row('Designation', membership.designation ?? '—'),
          _row(
            'Status',
            membership.employeeStatus ?? membership.companyStatus ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: AppColors.mutedForeground)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
