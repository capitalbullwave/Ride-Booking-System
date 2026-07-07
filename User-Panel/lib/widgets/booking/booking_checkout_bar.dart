import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/models/coupon_models.dart';

class BookingCheckoutBar extends StatelessWidget {
  const BookingCheckoutBar({
    super.key,
    required this.paymentLabel,
    required this.bookLabel,
    required this.onPaymentTap,
    required this.onOffersTap,
    required this.onBookTap,
    this.appliedCoupon,
    this.isLoading = false,
    this.enabled = true,
  });

  final String paymentLabel;
  final String bookLabel;
  final VoidCallback onPaymentTap;
  final VoidCallback onOffersTap;
  final VoidCallback onBookTap;
  final AppliedCoupon? appliedCoupon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (appliedCoupon != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${appliedCoupon!.coupon.code} applied • ₹${appliedCoupon!.discountAmount.round()} saved',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: _CheckoutTile(
                icon: Icons.currency_rupee,
                label: paymentLabel,
                onTap: onPaymentTap,
                roundedLeft: true,
              )),
              Container(width: 1, height: 44, color: AppColors.border),
              Expanded(child: _CheckoutTile(
                icon: Icons.percent,
                label: 'Offers',
                onTap: onOffersTap,
                roundedLeft: false,
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: enabled && !isLoading ? onBookTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
              disabledForegroundColor: Colors.white70,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(
                    bookLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutTile extends StatelessWidget {
  const _CheckoutTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.roundedLeft,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool roundedLeft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: roundedLeft ? const Radius.circular(14) : Radius.zero,
        right: !roundedLeft ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
