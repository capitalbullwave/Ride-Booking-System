import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class ReferEarnDashboard {
  ReferEarnDashboard({
    required this.enabled,
    required this.title,
    required this.description,
    required this.terms,
    required this.inviteCode,
    required this.shareMessage,
    required this.requiredRides,
    required this.rewardAmount,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.totalEarned,
    required this.hasAppliedCode,
    required this.referrals,
  });

  final bool enabled;
  final String title;
  final String description;
  final String terms;
  final String inviteCode;
  final String shareMessage;
  final int requiredRides;
  final double rewardAmount;
  final int totalReferrals;
  final int pendingReferrals;
  final double totalEarned;
  final bool hasAppliedCode;
  final List<Map<String, dynamic>> referrals;

  factory ReferEarnDashboard.fromJson(Map<String, dynamic> json) {
    final program = json['program'] is Map
        ? Map<String, dynamic>.from(json['program'] as Map)
        : <String, dynamic>{};
    final stats = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : <String, dynamic>{};
    final referralsRaw = json['referrals'];
    return ReferEarnDashboard(
      enabled: json['enabled'] == true,
      title: (program['title'] ?? 'Refer & Earn').toString(),
      description: (program['description'] ?? '').toString(),
      terms: (program['terms'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      shareMessage: (json['shareMessage'] ?? '').toString(),
      requiredRides: (program['requiredRides'] as num?)?.toInt() ?? 0,
      rewardAmount: (program['rewardAmount'] as num?)?.toDouble() ?? 0,
      totalReferrals: (stats['totalReferrals'] as num?)?.toInt() ?? 0,
      pendingReferrals: (stats['pendingReferrals'] as num?)?.toInt() ?? 0,
      totalEarned: (stats['totalEarned'] as num?)?.toDouble() ?? 0,
      hasAppliedCode: json['hasAppliedCode'] == true,
      referrals: referralsRaw is List
          ? referralsRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : const [],
    );
  }
}

class ReferEarnService extends BaseApiService {
  ReferEarnService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<ReferEarnDashboard> fetch() {
    return get(
      ApiEndpoints.referEarn,
      parser: (data) => ReferEarnDashboard.fromJson(
        data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map),
      ),
    );
  }

  Future<ReferEarnDashboard> applyCode(String code) {
    return post(
      ApiEndpoints.referEarnApply,
      data: {'code': code.trim()},
      parser: (data) => ReferEarnDashboard.fromJson(
        data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map),
      ),
    );
  }
}

final referEarnServiceProvider = Provider<ReferEarnService>((ref) {
  return ReferEarnService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});

final referEarnProvider = FutureProvider<ReferEarnDashboard>((ref) {
  return ref.watch(referEarnServiceProvider).fetch();
});

class ReferEarnScreen extends ConsumerStatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  ConsumerState<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends ConsumerState<ReferEarnScreen> {
  final _codeController = TextEditingController();
  bool _applying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      context.showSnackBar('Enter a referral code', isError: true);
      return;
    }
    setState(() => _applying = true);
    try {
      await ref.read(referEarnServiceProvider).applyCode(code);
      ref.invalidate(referEarnProvider);
      if (mounted) context.showSnackBar('Referral code applied');
    } catch (e) {
      if (mounted) context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(referEarnProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.userMessage, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.invalidate(referEarnProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (!data.enabled) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Refer & Earn is not available right now.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(referEarnProvider),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.description.isNotEmpty
                            ? data.description
                            : 'Invite drivers. Earn ₹${data.rewardAmount.toStringAsFixed(0)} after they complete ${data.requiredRides} trips.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Earned',
                        value: '₹${data.totalEarned.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Referrals',
                        value: '${data.totalReferrals}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Pending',
                        value: '${data.pendingReferrals}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Your invite code',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.inviteCode,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: data.inviteCode));
                          if (context.mounted) {
                            context.showSnackBar('Code copied');
                          }
                        },
                        icon: const Icon(Icons.copy_rounded),
                      ),
                      IconButton(
                        tooltip: 'Copy invite message',
                        onPressed: () async {
                          final text = data.shareMessage.isNotEmpty
                              ? data.shareMessage
                              : 'Join Bull Wave Rides Captain with my code ${data.inviteCode}';
                          await Clipboard.setData(ClipboardData(text: text));
                          if (context.mounted) {
                            context.showSnackBar('Invite message copied');
                          }
                        },
                        icon: const Icon(Icons.share_rounded),
                      ),
                    ],
                  ),
                ),
                if (data.shareMessage.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share message preview',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.mutedForeground,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(data.shareMessage, style: const TextStyle(height: 1.35)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Reward: ₹${data.rewardAmount.toStringAsFixed(0)} after ${data.requiredRides} completed trips',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
                if (!data.hasAppliedCode) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Have a referral code?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Enter code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _applying ? null : _apply,
                        child: _applying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Optional — you can skip this if you already applied during registration.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                ],
                if (data.terms.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Terms',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.terms,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                ],
                if (data.referrals.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Your referrals',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...data.referrals.map((r) {
                    final status = (r['status'] ?? '').toString();
                    final completed = r['ridesCompleted'] ?? 0;
                    final required = r['requiredRides'] ?? 0;
                    final amount = (r['rewardAmount'] as num?)?.toDouble() ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              status == 'PAID'
                                  ? 'Reward credited · ₹${amount.toStringAsFixed(0)}'
                                  : 'Progress $completed / $required trips',
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              color: status == 'PAID'
                                  ? AppColors.success
                                  : AppColors.mutedForeground,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
