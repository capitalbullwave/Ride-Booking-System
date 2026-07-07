import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/models/coupon_models.dart';

Future<AppliedCoupon?> showBookingOffersSheet({
  required BuildContext context,
  required List<RideCoupon> coupons,
  required double orderAmount,
  required Future<AppliedCoupon> Function(String code) onValidate,
  AppliedCoupon? current,
}) {
  return showModalBottomSheet<AppliedCoupon?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _BookingOffersSheet(
      coupons: coupons,
      orderAmount: orderAmount,
      onValidate: onValidate,
      current: current,
    ),
  );
}

class _BookingOffersSheet extends StatefulWidget {
  const _BookingOffersSheet({
    required this.coupons,
    required this.orderAmount,
    required this.onValidate,
    this.current,
  });

  final List<RideCoupon> coupons;
  final double orderAmount;
  final Future<AppliedCoupon> Function(String code) onValidate;
  final AppliedCoupon? current;

  @override
  State<_BookingOffersSheet> createState() => _BookingOffersSheetState();
}

class _BookingOffersSheetState extends State<_BookingOffersSheet> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final applied = await widget.onValidate(trimmed);
      if (!mounted) return;
      Navigator.of(context).pop(applied);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Offers & coupons',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _loading ? null : () => _applyCode(_codeController.text),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply'),
              ),
            ],
          ),
          if (widget.current != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle, color: AppColors.primary),
              title: Text(widget.current!.coupon.code),
              subtitle: Text('₹${widget.current!.discountAmount.round()} saved'),
              trailing: TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Remove'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (widget.coupons.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No offers available right now',
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.coupons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final coupon = widget.coupons[index];
                  return Material(
                    color: AppColors.muted,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _loading ? null : () => _applyCode(coupon.code),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.percent,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon.code,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    coupon.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    coupon.subtitle,
                                    style: const TextStyle(
                                      color: AppColors.mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
