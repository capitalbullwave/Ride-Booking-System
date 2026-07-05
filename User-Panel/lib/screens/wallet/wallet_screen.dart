import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/wallet_refresh.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const _headerHeight = 132.0;
  static const _cardOverlap = 28.0;
  static const _cardHeight = 148.0;

  String _formatFare(double amount) =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(resolvedWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: walletAsync.when(
        loading: () {
          if (walletAsync.hasValue) {
            return _walletBody(context, walletAsync.value!);
          }
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallet) => _walletBody(context, wallet),
      ),
    );
  }

  Widget _walletBody(BuildContext context, WalletSummary wallet) {
    return SafeArea(
          bottom: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _WalletHeader()),
                  SliverToBoxAdapter(
                    child: SizedBox(height: _cardHeight - _cardOverlap + 20),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(
                          'Payment methods',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...wallet.paymentMethods.map(
                          (method) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PaymentMethodTile(
                              method: method,
                              onTap: () => context.push(
                                RouteNames.walletPaymentDetail,
                                extra: method,
                              ),
                            ),
                          ),
                        ),
                        AppButton(
                          label: 'Add payment method',
                          variant: AppButtonVariant.outline,
                          icon: Icons.add,
                          onPressed: () => context.push(RouteNames.walletAddPayment),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                top: _headerHeight - _cardOverlap,
                child: SizedBox(
                  height: _cardHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _BalanceCard(
                          label: 'Balance',
                          amount: _formatFare(wallet.balance),
                          icon: Icons.account_balance,
                          badge: 'Payouts',
                          onTap: () => context.push(RouteNames.walletBalance),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BalanceCard(
                          label: 'Bonus',
                          amount: _formatFare(wallet.bonusBalance),
                          icon: Icons.card_giftcard,
                          badge: 'Rewards',
                          onTap: () => context.push(RouteNames.walletBonus),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Wallet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage balances and how you pay for rides.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final String label;
  final String amount;
  final IconData icon;
  final String badge;
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.method, required this.onTap});

  final PaymentMethod method;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.type == 'upi' ? Icons.payment : Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (method.lastFour != null)
                      Text(
                        '•••• ${method.lastFour}',
                        style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
