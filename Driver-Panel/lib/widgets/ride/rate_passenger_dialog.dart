import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

Future<Map<String, dynamic>?> showRatePassengerDialog(
  BuildContext context, {
  required String passengerName,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RatePassengerDialog(passengerName: passengerName),
  );
}

class RatePassengerDialog extends StatefulWidget {
  const RatePassengerDialog({super.key, required this.passengerName});

  final String passengerName;

  @override
  State<RatePassengerDialog> createState() => _RatePassengerDialogState();
}

class _RatePassengerDialogState extends State<RatePassengerDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitting = true);
    Navigator.of(context).pop({
      'rating': _rating,
      'comment': _commentController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate passenger'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How was your trip with ${widget.passengerName}?',
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
