import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Floating quick-focus tag with magnetic edge docking and spring physics.
/// Designed after iOS AssistiveTouch and Android Chat Heads.
class DraggableQuickFocusTag extends HookWidget {
  final ThemeData theme;
  final bool isFocused;
  final double cardWidth;
  final double cardHeight;
  final Offset? initialOffset;
  final ValueChanged<Offset>? onPositionChanged;
  final VoidCallback onTap;

  const DraggableQuickFocusTag({
    super.key,
    required this.theme,
    required this.isFocused,
    required this.cardWidth,
    required this.cardHeight,
    this.initialOffset,
    this.onPositionChanged,
    required this.onTap,
  });

  static const double tagSize = 44.0;
  static const double edgeMargin = 12.0;

  @override
  Widget build(BuildContext context) {
    final snapController = useAnimationController(
      duration: const Duration(milliseconds: 320),
    );
    final curvedAnimation = useMemoized(
      () => CurvedAnimation(parent: snapController, curve: Curves.easeOutBack),
      [snapController],
    );

    final isDragging = useState<bool>(false);
    final posNotifier = useValueNotifier<Offset>(
      initialOffset ?? Offset(cardWidth - tagSize, (cardHeight - tagSize) / 2),
    );
    final snapTween = useRef<Tween<Offset>>(
      Tween<Offset>(begin: posNotifier.value, end: posNotifier.value),
    );

    useEffect(() {
      final cur = posNotifier.value;
      final midX = (cardWidth - tagSize) / 2;
      final isRight = cur.dx >= midX;
      final clampedX = isRight ? (cardWidth - tagSize) : 0.0;
      final clampedY = cur.dy.clamp(
        edgeMargin,
        (cardHeight - tagSize - edgeMargin).clamp(edgeMargin, double.infinity),
      );
      if (cur.dx != clampedX || cur.dy != clampedY) {
        posNotifier.value = Offset(clampedX, clampedY);
      }
      return null;
    }, [cardWidth, cardHeight]);

    void snapToNearestEdge({double velocityX = 0, double velocityY = 0}) {
      final startPos = posNotifier.value;

      final double targetX;
      if (velocityX > 400) {
        targetX = cardWidth - tagSize;
      } else if (velocityX < -400) {
        targetX = 0.0;
      } else {
        final midX = (cardWidth - tagSize) / 2;
        targetX = (startPos.dx >= midX) ? (cardWidth - tagSize) : 0.0;
      }

      final double targetY = (startPos.dy + (velocityY * 0.06)).clamp(
        edgeMargin,
        (cardHeight - tagSize - edgeMargin).clamp(edgeMargin, double.infinity),
      );

      final endPos = Offset(targetX, targetY);

      snapTween.value = Tween<Offset>(begin: startPos, end: endPos);
      isDragging.value = false;

      snapController.forward(from: 0.0).then((_) {
        posNotifier.value = endPos;
        HapticFeedback.lightImpact();
        onPositionChanged?.call(endPos);
      });
    }

    final mergedListenable = useMemoized(
      () => Listenable.merge([curvedAnimation, posNotifier]),
      [curvedAnimation, posNotifier],
    );

    return AnimatedBuilder(
      animation: mergedListenable,
      builder: (context, _) {
        final currentPos = snapController.isAnimating
            ? snapTween.value.evaluate(curvedAnimation)
            : posNotifier.value;

        final isAtRight = currentPos.dx >= (cardWidth - tagSize - 3.0);
        final isAtLeft = currentPos.dx <= 3.0;
        final isAirborne = isDragging.value || (!isAtRight && !isAtLeft);

        final borderRadius = isAirborne
            ? AppRadius.borderLg
            : isAtRight
            ? const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              );

        return Positioned(
          left: currentPos.dx,
          top: currentPos.dy,
          child: RepaintBoundary(
            child: AnimatedOpacity(
              opacity: isFocused ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: isFocused,
                child: GestureDetector(
                  onPanDown: (_) {
                    if (snapController.isAnimating) {
                      snapController.stop();
                      posNotifier.value = currentPos;
                    }
                  },
                  onPanStart: (_) {
                    snapController.stop();
                    isDragging.value = true;
                    HapticFeedback.selectionClick();
                  },
                  onPanUpdate: (details) {
                    final cur = posNotifier.value;
                    final newX = (cur.dx + details.delta.dx).clamp(
                      0.0,
                      cardWidth - tagSize,
                    );
                    final newY = (cur.dy + details.delta.dy).clamp(
                      edgeMargin,
                      (cardHeight - tagSize - edgeMargin).clamp(
                        edgeMargin,
                        double.infinity,
                      ),
                    );
                    posNotifier.value = Offset(newX, newY);
                  },
                  onPanEnd: (details) {
                    snapToNearestEdge(
                      velocityX: details.velocity.pixelsPerSecond.dx,
                      velocityY: details.velocity.pixelsPerSecond.dy,
                    );
                  },
                  onPanCancel: () {
                    if (isDragging.value) {
                      snapToNearestEdge();
                    }
                  },
                  onTap: () {
                    if (!isDragging.value && !snapController.isAnimating) {
                      onTap();
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedScale(
                    scale: isDragging.value ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: tagSize,
                          height: tagSize,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: isDragging.value ? 0.85 : 0.55,
                            ),
                            borderRadius: borderRadius,
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: isDragging.value ? 0.7 : 0.4,
                              ),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDragging.value ? 0.35 : 0.18,
                                ),
                                blurRadius: isDragging.value ? 14 : 8,
                                offset: isDragging.value
                                    ? const Offset(0, 4)
                                    : const Offset(-1, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.keyboard,
                              size: 22,
                              color: theme.colorScheme.primaryForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
