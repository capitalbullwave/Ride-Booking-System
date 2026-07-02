import 'package:flutter/material.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

/// Read-only field that opens a searchable bottom sheet to pick one option.
class SearchableDropdownField extends StatelessWidget {
  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.value,
    this.validator,
    this.enabled = true,
    this.hint = 'Select',
    this.searchHint = 'Search...',
    this.emptyMessage = 'No options found',
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final String hint;
  final String searchHint;
  final String emptyMessage;

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled || options.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchablePickerSheet(
        title: label,
        options: options,
        selected: value,
        searchHint: searchHint,
        emptyMessage: emptyMessage,
      ),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final display = (value != null && value!.isNotEmpty) ? value! : hint;
    final isPlaceholder = value == null || value!.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: value,
          validator: validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: enabled ? () => _openPicker(context) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: enabled ? AppColors.primary : AppColors.textLight,
                      ),
                      errorText: field.errorText,
                    ),
                    child: Text(
                      display,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isPlaceholder
                                ? AppColors.textSecondary
                                : AppColors.foreground,
                          ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SearchablePickerSheet extends StatefulWidget {
  const _SearchablePickerSheet({
    required this.title,
    required this.options,
    required this.searchHint,
    required this.emptyMessage,
    this.selected,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final String searchHint;
  final String emptyMessage;

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.trim().isEmpty) return widget.options;
    final q = _query.trim().toLowerCase();
    return widget.options
        .where((option) => option.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        widget.emptyMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final isSelected = option == widget.selected;
                        return ListTile(
                          title: Text(option),
                          trailing: isSelected
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () => Navigator.pop(context, option),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
