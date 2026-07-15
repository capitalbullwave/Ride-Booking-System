import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/core/utils/wallet_refresh.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class WalletWithdrawScreen extends ConsumerStatefulWidget {
  const WalletWithdrawScreen({super.key});

  @override
  ConsumerState<WalletWithdrawScreen> createState() => _WalletWithdrawScreenState();
}

class _WalletWithdrawScreenState extends ConsumerState<WalletWithdrawScreen> {
  final _amountController = TextEditingController();
  final _holderController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _upiController = TextEditingController();

  bool _savingBank = false;
  bool _submitting = false;
  bool _editingBank = false;
  String _payoutType = 'bank';

  @override
  void dispose() {
    _amountController.dispose();
    _holderController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  String _money(double v) =>
      NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(v);

  Future<void> _saveBank() async {
    final holder = _holderController.text.trim();
    if (holder.length < 2) {
      context.showSnackBar('Enter account holder name', isError: true);
      return;
    }

    setState(() => _savingBank = true);
    try {
      if (_payoutType == 'upi') {
        final upi = _upiController.text.trim();
        if (upi.isEmpty || !upi.contains('@')) {
          context.showSnackBar('Enter a valid UPI ID', isError: true);
          return;
        }
        await ref.read(walletRepositoryProvider).saveBank(
              paymentType: 'upi',
              accountHolderName: holder,
              upiId: upi,
            );
      } else {
        final account = _accountController.text.trim();
        final ifsc = _ifscController.text.trim();
        final bankName = _bankNameController.text.trim();
        if (account.length < 8 || ifsc.length < 5 || bankName.length < 2) {
          context.showSnackBar('Enter complete bank details', isError: true);
          return;
        }
        await ref.read(walletRepositoryProvider).saveBank(
              paymentType: 'bank',
              accountHolderName: holder,
              accountNumber: account,
              ifscCode: ifsc,
              bankName: bankName,
            );
      }
      await refreshWallet(ref);
      if (!mounted) return;
      setState(() => _editingBank = false);
      context.showSnackBar('Payout account saved');
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _savingBank = false);
    }
  }

  Future<void> _submitWithdraw(double available) async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount < 1) {
      context.showSnackBar('Enter a valid amount', isError: true);
      return;
    }
    if (amount > available) {
      context.showSnackBar('Amount exceeds wallet balance', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(walletRepositoryProvider).withdraw(amount);
      await refreshWallet(ref);
      if (!mounted) return;
      context.showSnackBar('Withdrawal request sent. Admin will process payment.');
      context.pop();
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(resolvedWalletProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw')),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallet) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BalanceBanner(amount: _money(wallet.balance)),
            const SizedBox(height: 24),
            if (!wallet.hasBankAccount || wallet.bank == null || _editingBank)
              _buildBankForm()
            else ...[
              Text(
                'Payout account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _BankCard(bank: wallet.bank!),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _editingBank = true),
                  child: const Text('Change account'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Withdraw amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Request withdrawal',
                isLoading: _submitting,
                onPressed: _submitting || wallet.balance < 1
                    ? null
                    : () => _submitWithdraw(wallet.balance),
              ),
              const SizedBox(height: 8),
              Text(
                'Request goes to admin. After approval, payment is sent to your saved account.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add payout account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Save a bank account or UPI. Withdrawal payment will be sent to this account after admin approval.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'bank', label: Text('Bank'), icon: Icon(Icons.account_balance)),
            ButtonSegment(value: 'upi', label: Text('UPI'), icon: Icon(Icons.payment)),
          ],
          selected: {_payoutType},
          onSelectionChanged: (s) => setState(() => _payoutType = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _holderController,
          decoration: const InputDecoration(
            labelText: 'Account holder name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        if (_payoutType == 'upi')
          TextField(
            controller: _upiController,
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              hintText: 'name@upi',
              border: OutlineInputBorder(),
            ),
          )
        else ...[
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Account number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ifscController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'IFSC code',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'Bank name',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        AppButton(
          label: 'Save account',
          isLoading: _savingBank,
          onPressed: _savingBank ? null : _saveBank,
        ),
        if (_editingBank)
          TextButton(
            onPressed: () => setState(() => _editingBank = false),
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.amount});
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                ),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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

class _BankCard extends StatelessWidget {
  const _BankCard({required this.bank});
  final UserBankInfo bank;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bank.accountHolder, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (bank.isUpi)
            Text(bank.upiId ?? bank.accountNumber)
          else ...[
            Text(bank.accountNumber),
            Text('${bank.bankName} · ${bank.ifsc}'),
          ],
        ],
      ),
    );
  }
}
