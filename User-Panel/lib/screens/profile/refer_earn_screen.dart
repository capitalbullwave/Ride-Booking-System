import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/core/constants/api_endpoints.dart';
import 'package:wavego_user/core/network/dio_client.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/services/base_api_service.dart';

class _ReferEarnData {
  _ReferEarnData({
    required this.enabled,
    required this.title,
    required this.description,
    required this.terms,
    required this.inviteCode,
    required this.shareMessage,
    required this.requiredRides,
    required this.rewardAmount,
    required this.totalEarned,
    required this.totalReferrals,
    required this.pendingReferrals,
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
  final double totalEarned;
  final int totalReferrals;
  final int pendingReferrals;
  final bool hasAppliedCode;
  final List<Map<String, dynamic>> referrals;

  factory _ReferEarnData.fromJson(Map<String, dynamic> json) {
    final program = json['program'] is Map
        ? Map<String, dynamic>.from(json['program'] as Map)
        : <String, dynamic>{};
    final stats = json['stats'] is Map
        ? Map<String, dynamic>.from(json['stats'] as Map)
        : <String, dynamic>{};
    final referralsRaw = json['referrals'];
    return _ReferEarnData(
      enabled: json['enabled'] == true,
      title: (program['title'] ?? 'Refer & Earn').toString(),
      description: (program['description'] ?? '').toString(),
      terms: (program['terms'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      shareMessage: (json['shareMessage'] ?? '').toString(),
      requiredRides: (program['requiredRides'] as num?)?.toInt() ?? 0,
      rewardAmount: (program['rewardAmount'] as num?)?.toDouble() ?? 0,
      totalEarned: (stats['totalEarned'] as num?)?.toDouble() ?? 0,
      totalReferrals: (stats['totalReferrals'] as num?)?.toInt() ?? 0,
      pendingReferrals: (stats['pendingReferrals'] as num?)?.toInt() ?? 0,
      hasAppliedCode: json['hasAppliedCode'] == true,
      referrals: referralsRaw is List
          ? referralsRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
          : const [],
    );
  }
}

class ReferEarnApiService extends BaseApiService {
  ReferEarnApiService(super.dio);

  Future<_ReferEarnData> fetch() {
    return get(
      ApiEndpoints.referEarn,
      parser: (raw) => _ReferEarnData.fromJson(
        raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map),
      ),
    );
  }

  Future<_ReferEarnData> applyCode(String code) {
    return post(
      ApiEndpoints.referEarnApply,
      data: {'code': code.trim()},
      parser: (raw) => _ReferEarnData.fromJson(
        raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map),
      ),
    );
  }
}

final referEarnApiProvider = Provider((ref) {
  return ReferEarnApiService(ref.watch(dioClientProvider).dio);
});

final referEarnProvider = FutureProvider<_ReferEarnData>((ref) {
  return ref.watch(referEarnApiProvider).fetch();
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
      await ref.read(referEarnApiProvider).applyCode(code);
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
        error: (e, _) => Center(child: Text(e.userMessage)),
        data: (data) {
          if (!data.enabled) {
            return const Center(child: Text('Refer & Earn is not available right now.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(data.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                data.description.isNotEmpty
                    ? data.description
                    : 'Share your code. Earn ₹${data.rewardAmount.toStringAsFixed(0)} when friends complete ${data.requiredRides} rides.',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _Chip(label: 'Earned', value: '₹${data.totalEarned.toStringAsFixed(0)}')),
                  const SizedBox(width: 8),
                  Expanded(child: _Chip(label: 'Referrals', value: '${data.totalReferrals}')),
                  const SizedBox(width: 8),
                  Expanded(child: _Chip(label: 'Pending', value: '${data.pendingReferrals}')),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Your invite code', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.inviteCode,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: data.inviteCode));
                        if (mounted) context.showSnackBar('Code copied');
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      onPressed: () async {
                        final text = data.shareMessage.isNotEmpty
                            ? data.shareMessage
                            : 'Join Bull Wave Rides with my code ${data.inviteCode}';
                        await Clipboard.setData(ClipboardData(text: text));
                        if (mounted) context.showSnackBar('Invite message copied');
                      },
                      icon: const Icon(Icons.share_outlined),
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
                    color: AppColors.muted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
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
                'Reward: ₹${data.rewardAmount.toStringAsFixed(0)} after ${data.requiredRides} completed rides',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (!data.hasAppliedCode) ...[
                const SizedBox(height: 24),
                const Text('Have a referral code?', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(hintText: 'Enter code'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _applying ? null : _apply,
                      child: _applying
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Apply'),
                    ),
                  ],
                ),
              ],
              if (data.terms.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(data.terms, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
