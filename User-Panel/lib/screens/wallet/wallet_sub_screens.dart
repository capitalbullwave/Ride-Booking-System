import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final String type;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        date: json['date'] as String? ?? '',
        type: json['type'] as String? ?? 'debit',
      );
}

final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final raw = await rootBundle.loadString('assets/mock/wallet_transactions.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
});

String _formatAmount(double amount) =>
    NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount.abs());

class WalletBalanceScreen extends ConsumerWidget {
  const WalletBalanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Balance')),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallet) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(
              label: 'Available balance',
              amount: _formatAmount(wallet.balance),
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 24),
            Text(
              'Recent transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            txAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Unable to load transactions'),
              data: (txns) => Column(
                children: txns
                    .where((t) => t.type != 'bonus')
                    .map((txn) => _TransactionTile(txn: txn))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Add money',
              icon: Icons.add,
              onPressed: () => context.showSnackBar('Add money — coming soon'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletBonusScreen extends ConsumerWidget {
  const WalletBonusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final txAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bonus & Rewards')),
      body: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (wallet) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCard(
              label: 'Bonus balance',
              amount: _formatAmount(wallet.bonusBalance),
              icon: Icons.card_giftcard,
              accent: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
              ),
              child: const Text(
                'Use bonus credits on your next ride. Promo rewards are applied automatically at checkout.',
                style: TextStyle(color: AppColors.foreground, height: 1.45),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reward history',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            txAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Unable to load rewards'),
              data: (txns) => Column(
                children: txns
                    .where((t) => t.type == 'bonus')
                    .map((txn) => _TransactionTile(txn: txn))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodDetailScreen extends StatelessWidget {
  const PaymentMethodDetailScreen({super.key, required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(method.label)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    method.type == 'upi' ? Icons.payment : Icons.account_balance_wallet,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    method.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (method.lastFour != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '•••• ${method.lastFour}',
                      style: const TextStyle(color: AppColors.mutedForeground),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (method.type == 'upi')
              AppButton(
                label: 'Change UPI ID',
                variant: AppButtonVariant.outline,
                onPressed: () => context.showSnackBar('UPI update — coming soon'),
              ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Set as default',
              onPressed: () => context.showSnackBar('${method.label} set as default'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Remove payment method',
              variant: AppButtonVariant.danger,
              onPressed: () {
                Navigator.pop(context);
                context.showSnackBar('${method.label} removed');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  String _selected = 'upi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payment Method')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PaymentOption(
              icon: Icons.payment,
              label: 'UPI',
              subtitle: 'Google Pay, PhonePe, Paytm',
              isSelected: _selected == 'upi',
              onTap: () => setState(() => _selected = 'upi'),
            ),
            const SizedBox(height: 12),
            _PaymentOption(
              icon: Icons.credit_card,
              label: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay',
              isSelected: _selected == 'card',
              onTap: () => setState(() => _selected = 'card'),
            ),
            const SizedBox(height: 12),
            _PaymentOption(
              icon: Icons.account_balance,
              label: 'Bank account',
              subtitle: 'For refunds and payouts',
              isSelected: _selected == 'bank',
              onTap: () => setState(() => _selected = 'bank'),
            ),
            const Spacer(),
            AppButton(
              label: 'Continue',
              onPressed: () => context.push(
                RouteNames.walletAddPaymentSetup,
                extra: _selected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentSetupScreen extends StatefulWidget {
  const AddPaymentSetupScreen({super.key, required this.methodType});

  final String methodType;

  @override
  State<AddPaymentSetupScreen> createState() => _AddPaymentSetupScreenState();
}

class _AddPaymentSetupScreenState extends State<AddPaymentSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();

  String get _title => switch (widget.methodType) {
        'upi' => 'Link UPI',
        'card' => 'Add Card',
        'bank' => 'Add Bank Account',
        _ => 'Payment Details',
      };

  String get _subtitle => switch (widget.methodType) {
        'upi' => 'Enter your UPI ID to link Google Pay, PhonePe or Paytm.',
        'card' => 'Enter your card details securely.',
        'bank' => 'Add bank account for refunds and payouts.',
        _ => 'Enter your payment details.',
      };

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.push(
      RouteNames.walletAddPaymentSuccess,
      extra: widget.methodType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(_iconForType(widget.methodType), color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _subtitle,
                      style: const TextStyle(color: AppColors.foreground, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ..._fieldsForType(),
            const SizedBox(height: 32),
            AppButton(label: 'Add payment method', onPressed: _submit),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) => switch (type) {
        'upi' => Icons.payment,
        'card' => Icons.credit_card,
        'bank' => Icons.account_balance,
        _ => Icons.account_balance_wallet,
      };

  List<Widget> _fieldsForType() {
    return switch (widget.methodType) {
      'upi' => [
          TextFormField(
            controller: _upiController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'UPI ID',
              hintText: 'yourname@upi',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your UPI ID';
              if (!v.contains('@')) return 'Enter a valid UPI ID';
              return null;
            },
          ),
        ],
      'card' => [
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
            decoration: const InputDecoration(
              labelText: 'Card number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: (v) {
              if (v == null || v.length < 16) return 'Enter a valid 16-digit card number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name on card',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter name on card' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Expiry (MMYY)',
                    hintText: '1228',
                  ),
                  validator: (v) => v == null || v.length != 4 ? 'Enter MMYY' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(labelText: 'CVV'),
                  validator: (v) => v == null || v.length != 3 ? 'Enter CVV' : null,
                ),
              ),
            ],
          ),
        ],
      'bank' => [
          TextFormField(
            controller: _accountHolderController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Account holder name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter account holder name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Account number',
              prefixIcon: Icon(Icons.numbers),
            ),
            validator: (v) => v == null || v.length < 9 ? 'Enter a valid account number' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ifscController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'IFSC code',
              hintText: 'SBIN0001234',
              prefixIcon: Icon(Icons.account_balance),
            ),
            validator: (v) => v == null || v.length < 11 ? 'Enter a valid IFSC code' : null,
          ),
        ],
      _ => [],
    };
  }
}

class AddPaymentSuccessScreen extends StatelessWidget {
  const AddPaymentSuccessScreen({super.key, required this.methodType});

  final String methodType;

  String get _label => switch (methodType) {
        'upi' => 'UPI linked successfully',
        'card' => 'Card added successfully',
        'bank' => 'Bank account added',
        _ => 'Payment method added',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 24),
              Text(
                _label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your payment method is ready to use for rides and wallet top-ups.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mutedForeground, height: 1.45),
              ),
              const Spacer(),
              AppButton(
                label: 'Back to Wallet',
                onPressed: () => context.go(RouteNames.wallet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
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
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    this.accent,
  });

  final String label;
  final String amount;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (accent ?? AppColors.primary).withValues(alpha: 0.12),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent ?? AppColors.primary, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.mutedForeground)),
              Text(
                amount,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.txn});

  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(txn.subtitle, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                Text(txn.date, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${_formatAmount(txn.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.success : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
