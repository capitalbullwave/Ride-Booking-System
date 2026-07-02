import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/repositories/wallet_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  WalletInfo? _wallet;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final wallet = await repo.getWallet();
      final transactions = await repo.getTransactions();
      setState(() {
        _wallet = wallet;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _withdraw() async {
    if (_wallet == null) return;
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Withdraw Funds',
      message: 'Withdraw ${DateFormatter.currency(_wallet!.currentBalance)} to your bank account?',
    );
    if (confirmed != true) return;

    try {
      await ref.read(walletRepositoryProvider).withdraw(
        WithdrawRequest(amount: _wallet!.currentBalance, paymentMethod: 'bank'),
      );
      if (mounted) {
        AppDialog.showSuccess(context: context, title: 'Success', message: 'Withdrawal initiated successfully');
        _load();
      }
    } catch (e) {
      if (mounted) AppDialog.showError(context: context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _wallet == null
              ? ErrorStateWidget(message: 'Failed to load wallet', onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Balance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(DateFormatter.currency(_wallet!.currentBalance), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            if (_wallet!.pendingBalance > 0) ...[
                              const SizedBox(height: 8),
                              Text('Pending: ${DateFormatter.currency(_wallet!.pendingBalance)}', style: const TextStyle(color: Colors.white70)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(label: 'Withdraw', icon: Icons.account_balance, onPressed: _withdraw),
                      const SizedBox(height: 24),
                      if (_wallet!.bank != null) ...[
                        Text('Bank Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.account_balance),
                            title: Text(_wallet!.bank!.bankName ?? 'Bank'),
                            subtitle: Text('${_wallet!.bank!.accountHolder}\n****${_wallet!.bank!.accountNumber?.substring(_wallet!.bank!.accountNumber!.length > 4 ? _wallet!.bank!.accountNumber!.length - 4 : 0)}'),
                          ),
                        ),
                        if (_wallet!.bank!.upiId != null)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.payment),
                              title: const Text('UPI'),
                              subtitle: Text(_wallet!.bank!.upiId!),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                      Text('Transaction History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_transactions.isEmpty)
                        const EmptyStateWidget(title: 'No transactions yet')
                      else
                        ..._transactions.map((t) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              t.type == 'credit' ? Icons.arrow_downward : Icons.arrow_upward,
                              color: t.type == 'credit' ? AppColors.success : AppColors.error,
                            ),
                            title: Text(t.description ?? t.type),
                            subtitle: Text(t.createdAt.split('T').first),
                            trailing: Text(
                              '${t.type == 'credit' ? '+' : '-'}${DateFormatter.currency(t.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t.type == 'credit' ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
    );
  }
}
