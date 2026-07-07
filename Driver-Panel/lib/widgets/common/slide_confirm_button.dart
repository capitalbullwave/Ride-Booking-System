import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';

/// Rapido-style slide-to-confirm control for critical driver actions.
class SlideConfirmButton extends StatefulWidget {
  const SlideConfirmButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
    this.isLoading = false,
    this.height = 56,
  });

  final String label;
  final Future<void> Function() onConfirmed;
  final bool enabled;
  final bool isLoading;
  final double height;

  @override
  State<SlideConfirmButton> createState() => _SlideConfirmButtonState();
}

class _SlideConfirmButtonState extends State<SlideConfirmButton>
    with SingleTickerProviderStateMixin {
  static const double _horizontalPadding = 4;

  double _dragOffset = 0;
  bool _confirming = false;
  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() => _dragOffset = _resetAnimation.value);
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  double _handleSize(double trackHeight) => trackHeight - (_horizontalPadding * 2);

  void _animateTo(double target) {
    _resetAnimation = Tween<double>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    );
    _resetController
      ..reset()
      ..forward();
  }

  Future<void> _onDragEnd(double maxOffset) async {
    if (!widget.enabled || widget.isLoading || _confirming) return;

    final threshold = maxOffset * 0.82;
    if (_dragOffset < threshold) {
      _animateTo(0);
      return;
    }

    setState(() {
      _confirming = true;
      _dragOffset = maxOffset;
    });
    HapticFeedback.mediumImpact();

    try {
      await widget.onConfirmed();
    } finally {
      if (!mounted) return;
      setState(() {
        _confirming = false;
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled && !widget.isLoading && !_confirming;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final handleSize = _handleSize(widget.height);
        final maxOffset = (trackWidth - handleSize - (_horizontalPadding * 2))
            .clamp(0.0, double.infinity);
        final progress =
            maxOffset > 0 ? (_dragOffset / maxOffset).clamp(0.0, 1.0) : 0.0;

        return IgnorePointer(
          ignoring: !interactive && !widget.isLoading,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.5,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Opacity(
                    opacity: (1 - progress * 0.75).clamp(0.25, 1.0),
                    child: Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Positioned(
                    left: _horizontalPadding + _dragOffset,
                    top: _horizontalPadding,
                    child: GestureDetector(
                      onHorizontalDragUpdate: interactive
                          ? (details) {
                              setState(() {
                                _dragOffset = (_dragOffset + details.delta.dx)
                                    .clamp(0.0, maxOffset);
                              });
                            }
                          : null,
                      onHorizontalDragEnd:
                          interactive ? (_) => _onDragEnd(maxOffset) : null,
                      child: Container(
                        width: handleSize,
                        height: handleSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: widget.isLoading || _confirming
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
