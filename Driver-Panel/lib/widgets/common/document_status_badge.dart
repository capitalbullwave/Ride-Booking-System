import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';

enum DocumentStatus {
  verified,
  pending,
  rejected,
  expired,
  expiring,
}

DocumentStatus documentStatusFromString(String status, {bool isExpiring = false}) {
  if (isExpiring) return DocumentStatus.expiring;
  final normalized = status.toLowerCase();
  if (normalized.contains('reject')) return DocumentStatus.rejected;
  if (normalized.contains('expire')) return DocumentStatus.expired;
  if (normalized.contains('verify') || normalized.contains('approved')) {
    return DocumentStatus.verified;
  }
  return DocumentStatus.pending;
}

class DocumentStatusBadge extends StatelessWidget {
  const DocumentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final DocumentStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      DocumentStatus.verified => ('Verified', AppColors.success, Icons.verified_outlined),
      DocumentStatus.pending => ('Pending', AppColors.warning, Icons.schedule),
      DocumentStatus.rejected => ('Rejected', AppColors.error, Icons.cancel_outlined),
      DocumentStatus.expired => ('Expired', AppColors.error, Icons.event_busy),
      DocumentStatus.expiring => ('Expiring Soon', AppColors.warning, Icons.warning_amber_rounded),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: color),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
