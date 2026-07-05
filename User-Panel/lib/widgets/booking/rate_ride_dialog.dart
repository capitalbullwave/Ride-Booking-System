import 'package:flutter/material.dart';
import 'package:wavego_user/core/theme/app_colors.dart';

Future<Map<String, dynamic>?> showRateRideDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RateRideDialog(title: title, subtitle: subtitle),
  );
}

class RateRideDialog extends StatefulWidget {
  const RateRideDialog({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<RateRideDialog> createState() => _RateRideDialogState();
}

class _RateRideDialogState extends State<RateRideDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    if (!mounted) return;
    Navigator.of(context).pop({
      'rating': _rating,
      'comment': _commentController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.subtitle,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            _StarRatingRow(
              rating: _rating,
              enabled: !_submitting,
              onSelect: (star) => setState(() => _rating = star),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(null),
          child: const Text('Skip'),
        ),
        TextButton(
          onPressed: _submitting ? null : _submit,
          child: Text(_submitting ? 'Submitting...' : 'Submit'),
        ),
      ],
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({
    required this.rating,
    required this.enabled,
    required this.onSelect,
  });

  final int rating;
  final bool enabled;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        children: List.generate(5, (index) {
          final star = index + 1;
          return InkWell(
            onTap: enabled ? () => onSelect(star) : null,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                star <= rating ? Icons.star : Icons.star_border,
                color: AppColors.warning,
                size: 32,
              ),
            ),
          );
        }),
      ),
    );
  }
}
