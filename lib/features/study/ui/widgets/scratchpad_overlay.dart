import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/theme/app_tokens.dart';

class StrokeLine {
  final List<m.Offset> points;
  final m.Color color;
  final double strokeWidth;

  const StrokeLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class ScratchpadOverlay extends HookWidget {
  final VoidCallback onClose;

  const ScratchpadOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.colors;
    final lines = useState<List<StrokeLine>>([]);
    final currentPoints = useState<List<m.Offset>>([]);
    final selectedColor = useState<m.Color>(appColors.scratchAmber);

    final colors = [
      appColors.scratchAmber,
      appColors.scratchCyan,
      appColors.scratchWhite,
      appColors.scratchRed,
    ];

    return Positioned.fill(
      child: Container(
        color: AppColors.black.withValues(alpha: 0.25),
        child: Stack(
          children: [
            // Interactive drawing canvas
            GestureDetector(
              onPanStart: (details) {
                currentPoints.value = [details.localPosition];
              },
              onPanUpdate: (details) {
                currentPoints.value = [
                  ...currentPoints.value,
                  details.localPosition,
                ];
              },
              onPanEnd: (details) {
                if (currentPoints.value.isNotEmpty) {
                  lines.value = [
                    ...lines.value,
                    StrokeLine(
                      points: currentPoints.value,
                      color: selectedColor.value,
                      strokeWidth: 3.5,
                    ),
                  ];
                  currentPoints.value = [];
                }
              },
              child: CustomPaint(
                painter: _ScratchpadPainter(
                  lines: lines.value,
                  currentPoints: currentPoints.value,
                  currentColor: selectedColor.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            // Top mini floating toolbar
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smPlus,
                  vertical: AppSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background.withValues(alpha: 0.95),
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: theme.colorScheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...colors.map((c) {
                      final isSelected = selectedColor.value == c;
                      return GestureDetector(
                        onTap: () => selectedColor.value = c,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          width: AppSpacing.lg,
                          height: AppSpacing.lg,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: theme.colorScheme.foreground,
                                    width: 2,
                                  )
                                : Border.all(
                                    color: AppColors.scratchBorder,
                                    width: 1,
                                  ),
                          ),
                        ),
                      );
                    }),
                    AppGaps.h8,
                    // Clear canvas button
                    IconButton.ghost(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: AppIconSize.md,
                      ),
                      onPressed: () {
                        lines.value = [];
                        currentPoints.value = [];
                      },
                    ),
                    // Close whiteboard
                    IconButton.ghost(
                      icon: const Icon(LucideIcons.x, size: AppIconSize.md),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScratchpadPainter extends m.CustomPainter {
  final List<StrokeLine> lines;
  final List<m.Offset> currentPoints;
  final m.Color currentColor;

  const _ScratchpadPainter({
    required this.lines,
    required this.currentPoints,
    required this.currentColor,
  });

  @override
  void paint(m.Canvas canvas, m.Size size) {
    // Render existing finished strokes
    for (final line in lines) {
      final paint = m.Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = m.StrokeCap.round
        ..strokeJoin = m.StrokeJoin.round
        ..style = m.PaintingStyle.stroke;

      if (line.points.length > 1) {
        final path = m.Path();
        path.moveTo(line.points.first.dx, line.points.first.dy);
        for (int i = 1; i < line.points.length; i++) {
          path.lineTo(line.points[i].dx, line.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else if (line.points.isNotEmpty) {
        canvas.drawCircle(line.points.first, line.strokeWidth / 2, paint);
      }
    }

    // Render active drawing stroke
    if (currentPoints.isNotEmpty) {
      final paint = m.Paint()
        ..color = currentColor
        ..strokeWidth = 3.5
        ..strokeCap = m.StrokeCap.round
        ..strokeJoin = m.StrokeJoin.round
        ..style = m.PaintingStyle.stroke;

      if (currentPoints.length > 1) {
        final path = m.Path();
        path.moveTo(currentPoints.first.dx, currentPoints.first.dy);
        for (int i = 1; i < currentPoints.length; i++) {
          path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
        }
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(currentPoints.first, 1.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchpadPainter oldDelegate) => true;
}
