import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wavego_user/core/theme/app_colors.dart';

class RideScheduleSection extends StatelessWidget {
  const RideScheduleSection({
    super.key,
    required this.scheduledAt,
    required this.onChanged,
  });

  final DateTime? scheduledAt;
  final ValueChanged<DateTime?> onChanged;

  static String formatSchedule(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeLabel = DateFormat('h:mm a').format(dateTime);

    if (date == today) return 'Today · $timeLabel';
    if (date == tomorrow) return 'Tomorrow · $timeLabel';
    return '${DateFormat('d MMM').format(dateTime)} · $timeLabel';
  }

  Future<void> _pickSchedule(BuildContext context) async {
    final now = DateTime.now();
    final initial = scheduledAt ?? now.add(const Duration(minutes: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Select ride date',
    );
    if (!context.mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledAt ?? initial),
      helpText: 'Select ride time',
    );
    if (!context.mounted || time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (selected.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future date and time')),
      );
      return;
    }

    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final isScheduled = scheduledAt != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pickSchedule(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When to go',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isScheduled ? formatSchedule(scheduledAt!) : 'Leave now',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: isScheduled ? FontWeight.w500 : FontWeight.normal,
                        color: isScheduled
                            ? AppColors.foreground
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (isScheduled)
                IconButton(
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.mutedForeground,
                  tooltip: 'Leave now',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedForeground,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
