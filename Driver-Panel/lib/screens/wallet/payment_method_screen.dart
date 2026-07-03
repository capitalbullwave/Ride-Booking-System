import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/validators.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/repositories/wallet_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/forms/app_text_field.dart';

enum _PaymentType { bank, upi }

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({super.key, this.existingBank});

  final BankInfo? existingBank;

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  _PaymentType _paymentType = _PaymentType.bank;
  bool _saving = false;
  bool _loading = true;
  bool _isEditing = false;
  BankInfo? _bank;
  String? _loadError;

  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _confirmAccountController;
  late final TextEditingController _ifscController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _accountController = TextEditingController();
    _confirmAccountController = TextEditingController();
    _ifscController = TextEditingController();
    _bankNameController = TextEditingController();
    _upiController = TextEditingController();
    _loadBankDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  bool _isUpiAccount(BankInfo bank) {
    final upi = bank.upiId?.trim() ?? '';
    final bankName = bank.bankName?.toLowerCase() ?? '';
    final ifsc = bank.ifsc?.toUpperCase() ?? '';
    return bankName == 'upi' ||
        ifsc == 'UPI0000000' ||
        (upi.isNotEmpty &&
            (bank.accountNumber == null ||
                bank.accountNumber!.startsWith('UPI')));
  }

  Future<void> _loadBankDetails() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final fetched =
          await ref.read(walletRepositoryProvider).getBankDetails();
      final bank = fetched ?? widget.existingBank;

      if (!mounted) return;

      if (bank != null) {
        _bank = bank;
        _paymentType =
            _isUpiAccount(bank) ? _PaymentType.upi : _PaymentType.bank;
        _isEditing = false;
        _prefillFromBank(bank, forEdit: false);
      } else {
        _bank = null;
        _isEditing = true;
      }

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
        _bank = widget.existingBank;
        if (_bank != null) {
          _isEditing = false;
          _prefillFromBank(_bank!, forEdit: false);
        } else {
          _isEditing = true;
        }
      });
    }
  }

  void _prefillFromBank(BankInfo bank, {required bool forEdit}) {
    _nameController.text = bank.accountHolder ?? '';
    _ifscController.text = bank.ifsc ?? '';
    _bankNameController.text =
        bank.bankName == 'UPI' ? '' : (bank.bankName ?? '');
    _upiController.text = bank.upiId ?? '';

    if (forEdit) {
      _accountController.clear();
      _confirmAccountController.clear();
    } else if (!_isUpiAccount(bank)) {
      _accountController.text = bank.accountNumber ?? '';
      _confirmAccountController.text = bank.accountNumber ?? '';
    } else {
      _accountController.clear();
      _confirmAccountController.clear();
    }
  }

  void _startEditing() {
    if (_bank == null) return;
    _prefillFromBank(_bank!, forEdit: true);
    setState(() => _isEditing = true);
  }

  String? _confirmAccount(String? value) {
    if (_paymentType != _PaymentType.bank) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Re-enter account number';
    }
    if (value.trim() != _accountController.text.trim()) {
      return 'Account numbers do not match';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final request = BankDetailsRequest(
        paymentType: _paymentType == _PaymentType.bank ? 'bank' : 'upi',
        accountHolderName: _nameController.text.trim(),
        accountNumber: _paymentType == _PaymentType.bank
            ? _accountController.text.trim()
            : null,
        ifscCode: _paymentType == _PaymentType.bank
            ? _ifscController.text.trim().toUpperCase()
            : null,
        bankName: _paymentType == _PaymentType.bank
            ? _bankNameController.text.trim()
            : null,
        upiId: _paymentType == _PaymentType.upi
            ? _upiController.text.trim()
            : null,
      );

      final saved =
          await ref.read(walletRepositoryProvider).saveBankDetails(request);

      if (!mounted) return;
      setState(() {
        _bank = saved;
        _isEditing = false;
        _prefillFromBank(saved, forEdit: false);
      });

      await AppDialog.showSuccess(
        context: context,
        title: 'Payment method saved',
        message: _paymentType == _PaymentType.bank
            ? 'Your bank account has been linked successfully.'
            : 'Your UPI ID has been linked successfully.',
      );
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        AppDialog.showError(context: context, message: e.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: _isEditing && _bank != null
                  ? 'Update Payment Method'
                  : 'Payment Method',
              onClose: () => context.pop(),
            ),
            Expanded(
              child: _loading
                  ? const _PaymentMethodSkeleton()
                  : _loadError != null && _bank == null
                      ? ErrorStateWidget(
                          message: 'Could not load payment details',
                          onRetry: _loadBankDetails,
                        )
                      : _isEditing
                          ? _buildEditForm()
                          : _buildViewMode(),
            ),
            if (_isEditing && !_loading)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: AppButton(
                  label: 'CONFIRM',
                  variant: AppButtonVariant.secondary,
                  isLoading: _saving,
                  onPressed: _submit,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    final bank = _bank!;
    final isUpi = _isUpiAccount(bank);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified, color: AppColors.success, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isUpi ? 'UPI account linked' : 'Bank account linked',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _PaymentTypeToggle(
          paymentType: isUpi ? _PaymentType.upi : _PaymentType.bank,
          onChanged: (_) {},
          enabled: false,
        ),
        const SizedBox(height: 20),
        Text(
          'Your earnings are transferred to this account:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 16),
        _ViewField(
          label: 'Full name (Same as Bank Account)',
          value: bank.accountHolder ?? '—',
        ),
        if (!isUpi) ...[
          _ViewField(
            label: 'Account Number',
            value: bank.accountNumber ?? '—',
            subtitle:
                'Full account number is masked for your security. Re-enter to change.',
          ),
          _ViewField(label: 'IFSC code', value: bank.ifsc ?? '—'),
          _ViewField(label: 'Name of Bank', value: bank.bankName ?? '—'),
        ] else ...[
          _ViewField(label: 'UPI ID', value: bank.upiId ?? '—'),
        ],
        if (!isUpi && bank.upiId != null && bank.upiId!.isNotEmpty) ...[
          const SizedBox(height: 4),
          _ViewField(label: 'Linked UPI ID', value: bank.upiId!),
        ],
        const SizedBox(height: 28),
        AppButton(
          label: 'Change Account Details',
          icon: Icons.edit_outlined,
          variant: AppButtonVariant.outline,
          onPressed: _startEditing,
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    final isUpdate = _bank != null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (isUpdate)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _paymentType == _PaymentType.bank
                          ? 'Re-enter your account number to update linked bank details. Other fields are pre-filled.'
                          : 'Update your UPI ID below. Earnings will be sent to the new UPI.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          _PaymentTypeToggle(
            paymentType: _paymentType,
            onChanged: (type) => setState(() => _paymentType = type),
          ),
          const SizedBox(height: 20),
          Text(
            'Your earnings will be transferred to the account details you provide below:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 24),
          if (_paymentType == _PaymentType.bank) ...[
            AppTextField(
              controller: _nameController,
              label: 'Full name (Same as Bank Account)',
              hint: 'Enter your name',
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.maxLength(v, 150, 'Full name'),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _accountController,
              label: 'Account Number',
              hint: isUpdate
                  ? 'Enter new account number'
                  : 'Enter Account Number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(18),
              ],
              validator: Validators.accountNumber,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _confirmAccountController,
              label: 'Re-Enter account number',
              hint: 'Re-Enter account number',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(18),
              ],
              validator: _confirmAccount,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _ifscController,
              label: 'IFSC code',
              hint: 'Enter IFSC Code',
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              validator: Validators.ifsc,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _bankNameController,
              label: 'Name of Bank',
              hint: 'Enter Bank name',
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.maxLength(v, 100, 'Bank name'),
            ),
          ] else ...[
            AppTextField(
              controller: _nameController,
              label: 'Full name',
              hint: 'Enter your name',
              textCapitalization: TextCapitalization.words,
              validator: (v) => Validators.maxLength(v, 150, 'Full name'),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _upiController,
              label: 'UPI ID',
              hint: 'Enter UPI ID (e.g. name@upi)',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.upiId,
            ),
          ],
          if (isUpdate) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                if (_bank != null) {
                  _prefillFromBank(_bank!, forEdit: false);
                  setState(() => _isEditing = false);
                }
              },
              child: const Text('Cancel changes'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 26),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ViewField extends StatelessWidget {
  const _ViewField({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentTypeToggle extends StatelessWidget {
  const _PaymentTypeToggle({
    required this.paymentType,
    required this.onChanged,
    this.enabled = true,
  });

  final _PaymentType paymentType;
  final ValueChanged<_PaymentType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.85,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _tab(
              label: 'Bank Account',
              selected: paymentType == _PaymentType.bank,
              onTap: enabled ? () => onChanged(_PaymentType.bank) : null,
            ),
            _tab(
              label: 'UPI ID',
              selected: paymentType == _PaymentType.upi,
              onTap: enabled ? () => onChanged(_PaymentType.upi) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab({
    required String label,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodSkeleton extends StatelessWidget {
  const _PaymentMethodSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          ShimmerLoading(height: 48, borderRadius: 10),
          SizedBox(height: 24),
          ShimmerLoading(height: 16, width: 280),
          SizedBox(height: 20),
          ShimmerLoading(height: 72, borderRadius: 18),
          SizedBox(height: 16),
          ShimmerLoading(height: 72, borderRadius: 18),
          SizedBox(height: 16),
          ShimmerLoading(height: 72, borderRadius: 18),
        ],
      ),
    );
  }
}
