import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Scenario model representing a real-world sentence pair for live morphing.
class TenseLabScenario {
  final String verbTag;
  final String simpleSentence;
  final String simpleVerb;
  final String simpleNuance;
  final String continuousSentence;
  final String continuousVerb;
  final String continuousNuance;

  const TenseLabScenario({
    required this.verbTag,
    required this.simpleSentence,
    required this.simpleVerb,
    required this.simpleNuance,
    required this.continuousSentence,
    required this.continuousVerb,
    required this.continuousNuance,
  });
}

const kDefaultTenseScenarios = [
  TenseLabScenario(
    verbTag: 'LIVE (Nơi cư trú)',
    simpleSentence: 'I live in Hanoi.',
    simpleVerb: 'live',
    simpleNuance: 'Định cư cố định / Quê hương (Permanent)',
    continuousSentence: 'I am living in Hanoi right now.',
    continuousVerb: 'am living',
    continuousNuance: 'Tạm trú ngắn hạn / Chưa kết thúc (Temporary)',
  ),
  TenseLabScenario(
    verbTag: 'WORK (Công việc)',
    simpleSentence: 'She works for Google.',
    simpleVerb: 'works',
    simpleNuance: 'Công việc biên chế chính thức (Permanent)',
    continuousSentence: 'She is working on a new project.',
    continuousVerb: 'is working',
    continuousNuance: 'Dự án tiến trình tạm thời (In-progress)',
  ),
  TenseLabScenario(
    verbTag: 'THINK (Suy nghĩ)',
    simpleSentence: 'I think you are right.',
    simpleVerb: 'think',
    simpleNuance: 'Quan điểm / Niềm tin tĩnh (Stative)',
    continuousSentence: 'I am thinking about quitting.',
    continuousVerb: 'am thinking',
    continuousNuance: 'Não bộ đang chủ động xử lý (Dynamic)',
  ),
];

/// Interactive Tense Lab (Brilliant & Lingolia inspired).
/// Features:
/// 1. Interactive Time Scrubber: Smooth horizontal touch scrub between Simple & Continuous.
/// 2. Live Text Morphing: Sentence dynamically updates and highlights verb changes.
/// 3. Spatial Point vs. Span 2.5D graphics with animated particle stream & ambient shadows.
/// 4. Haptic tactile feedback on snap points.
class GrammarIsometricTimeline25D extends StatefulWidget {
  final bool isMobile;
  final bool enableLoop;

  const GrammarIsometricTimeline25D({
    super.key,
    this.isMobile = true,
    this.enableLoop = true,
  });

  @override
  State<GrammarIsometricTimeline25D> createState() =>
      _GrammarIsometricTimeline25DState();
}

class _GrammarIsometricTimeline25DState
    extends State<GrammarIsometricTimeline25D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  // Scrub offset: 0.0 = Simple (Permanent), 1.0 = Continuous (Temporary)
  double _scrubValue = 0.0;
  int _scenarioIdx = 0;
  bool _isLastHapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.enableLoop) {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onScrubUpdated(double normalizedX) {
    setState(() {
      _scrubValue = normalizedX.clamp(0.0, 1.0);
    });

    // Haptic feedback when crossing the midpoint (0.5)
    final isContinuous = _scrubValue > 0.5;
    if (isContinuous != _isLastHapticTriggered) {
      _isLastHapticTriggered = isContinuous;
      HapticFeedback.selectionClick();
    }
  }

  void _snapTo(bool continuous) {
    HapticFeedback.lightImpact();
    setState(() {
      _scrubValue = continuous ? 1.0 : 0.0;
      _isLastHapticTriggered = continuous;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final isContinuous = _scrubValue >= 0.5;
    final activeColor = Color.lerp(colors.success, colors.info, _scrubValue)!;
    final scenario = kDefaultTenseScenarios[_scenarioIdx];

    return Container(
      padding: widget.isMobile ? AppEdgeInsets.all12 : AppEdgeInsets.all16,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.border
              : theme.colorScheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Scenario Switcher Chip
          Row(
            children: [
              Container(
                padding: AppEdgeInsets.h8v2,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: activeColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.flaskConical,
                      size: AppIconSize.xs,
                      color: activeColor,
                    ),
                    AppGaps.h4,
                    Text(
                      l10n.grammarTenseLabTitle,
                      style: TextStyle(
                        fontSize: AppTypography.caption,
                        fontWeight: FontWeight.w700,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Scenario rotator button
              OutlineButton(
                density: ButtonDensity.compact,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _scenarioIdx =
                        (_scenarioIdx + 1) % kDefaultTenseScenarios.length;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scenario.verbTag,
                      style: TextStyle(
                        fontSize: AppTypography.caption,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                    AppGaps.h4,
                    Icon(
                      LucideIcons.refreshCw,
                      size: AppIconSize.xs,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGaps.v12,

          // Live Text Morphing Card (Sentence transforms dynamically)
          _buildLiveSentenceCard(
            context,
            theme,
            colors,
            l10n,
            scenario,
            isContinuous,
            activeColor,
          ),
          AppGaps.v12,

          // 2.5D Spatial Time Scrubber Viewport
          LayoutBuilder(
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final localPos = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    _onScrubUpdated(localPos.dx / viewportWidth);
                  }
                },
                onTapDown: (details) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final localPos = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    _onScrubUpdated(localPos.dx / viewportWidth);
                  }
                },
                child: Container(
                  height: 145,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0B132B)
                        : const Color(0xFFF1F5F9),
                    borderRadius: AppRadius.borderMd,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Canvas 3D isometric timeline with isolated repaint boundary
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _animController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: _IsometricLabPainter(
                                  scrubProgress: _scrubValue,
                                  accentColor: activeColor,
                                  loopProgress: _animController.value,
                                  pastLabel: l10n.grammarPastStation,
                                  nowLabel: l10n.grammarNowStation,
                                  futureLabel: l10n.grammarFutureStation,
                                  isDark: isDark,
                                ),
                                size: Size.infinite,
                              );
                            },
                          ),
                        ),
                      ),
                      // Instruction overlay
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.card.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.hand,
                                  size: AppIconSize.xs,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                AppGaps.h4,
                                Text(
                                  l10n.grammarDragToShiftTime,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          AppGaps.v10,

          // Quick Snap Tense Selector Bar
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  density: ButtonDensity.compact,
                  onPressed: () => _snapTo(false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.anchor,
                        size: AppIconSize.xs,
                        color: !isContinuous
                            ? colors.success
                            : theme.colorScheme.mutedForeground,
                      ),
                      AppGaps.h6,
                      Text(
                        l10n.grammarSimplePermanent,
                        style: TextStyle(
                          fontSize: AppTypography.xSmall,
                          fontWeight: !isContinuous
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: !isContinuous
                              ? colors.success
                              : theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppGaps.h8,
              Expanded(
                child: OutlineButton(
                  density: ButtonDensity.compact,
                  onPressed: () => _snapTo(true),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.activity,
                        size: AppIconSize.xs,
                        color: isContinuous
                            ? colors.info
                            : theme.colorScheme.mutedForeground,
                      ),
                      AppGaps.h6,
                      Text(
                        l10n.grammarContinuousTemporary,
                        style: TextStyle(
                          fontSize: AppTypography.xSmall,
                          fontWeight: isContinuous
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isContinuous
                              ? colors.info
                              : theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Live Sentence Box that morphs dynamically with AnimatedSwitcher
  Widget _buildLiveSentenceCard(
    BuildContext context,
    ThemeData theme,
    AppColorsExtension colors,
    AppLocalizations l10n,
    TenseLabScenario scenario,
    bool isContinuous,
    Color activeColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: AppEdgeInsets.all12,
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: activeColor.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isContinuous ? LucideIcons.timer : LucideIcons.shieldCheck,
                size: AppIconSize.xsPlus,
                color: activeColor,
              ),
              AppGaps.h6,
              Text(
                isContinuous
                    ? '${l10n.grammarPresentContinuous} (Present Continuous)'
                    : '${l10n.grammarPresentSimple} (Present Simple)',
                style: TextStyle(
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                ),
              ),
              const Spacer(),
              Text(
                isContinuous
                    ? l10n.grammarDynamicAspect
                    : l10n.grammarStativeAspect,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
            ],
          ),
          AppGaps.v6,

          // Morphing Sentence
          AnimatedSwitcher(
            duration: AppDurations.normal,
            transitionBuilder: (child, anim) {
              return FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              );
            },
            child: Row(
              key: ValueKey<bool>(isContinuous),
              children: [
                Expanded(
                  child: Text(
                    l10n.grammarExamplePrefix(
                      isContinuous
                          ? scenario.continuousSentence
                          : scenario.simpleSentence,
                    ),
                    style: TextStyle(
                      fontSize: AppTypography.small,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGaps.v4,

          // Subtle nuance explainer
          Text(
            l10n.grammarNuancePrefix(
              isContinuous ? scenario.continuousNuance : scenario.simpleNuance,
            ),
            style: TextStyle(
              fontSize: AppTypography.caption,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// 2.5D Isometric Painter that renders:
/// - Isometric ground depth grid
/// - Highway 3D timeline axis with ambient ground shadow
/// - Moving particle stream
/// - Point Anchor (Simple) vs. Dynamic Scanning Wave Window (Continuous)
class _IsometricLabPainter extends CustomPainter {
  final double scrubProgress;
  final Color accentColor;
  final double loopProgress;
  final bool isDark;
  final String pastLabel;
  final String nowLabel;
  final String futureLabel;

  _IsometricLabPainter({
    required this.scrubProgress,
    required this.accentColor,
    required this.loopProgress,
    required this.isDark,
    required this.pastLabel,
    required this.nowLabel,
    required this.futureLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 6;

    // 1. Draw 3D Ground Perspective Grid Lines
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
          .withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    // Perspective depth rays radiating outward
    for (int i = -5; i <= 5; i++) {
      final xOffset = i * 38.0;
      canvas.drawLine(
        Offset(centerX + xOffset * 0.45, centerY - 48),
        Offset(centerX + xOffset * 1.55, centerY + 58),
        gridPaint,
      );
    }

    // Horizontal latitude lines with perspective scale
    for (double y = -36; y <= 50; y += 22) {
      final widthFactor = (y + 50) / 86 * 1.7 + 0.4;
      canvas.drawLine(
        Offset(centerX - 130 * widthFactor, centerY + y),
        Offset(centerX + 130 * widthFactor, centerY + y),
        gridPaint,
      );
    }

    // 2. Timeline Axis (3D Beam running horizontally across Past -> Now -> Future)
    final axisY = centerY;
    const startX = 35.0;
    final endX = size.width - 35.0;

    // Ambient Ground Shadow for the beam
    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: isDark ? 0.35 : 0.12)
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(
      Offset(startX, axisY + 12),
      Offset(endX, axisY + 12),
      shadowPaint,
    );

    // Main 3D Highway Beam
    final beamPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, axisY), Offset(endX, axisY), beamPaint);

    // Active illuminated core
    final corePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, axisY), Offset(endX, axisY), corePaint);

    // 3. Flowing particles along the timeline (Animation)
    final particlePaint = Paint()..color = accentColor;
    for (int p = 0; p < 5; p++) {
      final particleT = (loopProgress + p * 0.2) % 1.0;
      final px = startX + (endX - startX) * particleT;
      canvas.drawCircle(Offset(px, axisY), 2.0, particlePaint);
    }

    // 4. Time Stations / Labels (Past, Now, Future)
    _drawStationNode(canvas, Offset(startX + 30, axisY), pastLabel, isDark);
    _drawStationNode(
      canvas,
      Offset(centerX, axisY),
      nowLabel,
      isDark,
      isNow: true,
    );
    _drawStationNode(canvas, Offset(endX - 30, axisY), futureLabel, isDark);

    // 5. Interactive Scrubber Position & 3D Visual Metaphor
    final scrubX = startX + 30 + (endX - startX - 60) * scrubProgress;

    if (scrubProgress < 0.5) {
      // SIMPLE MODE: Solid Anchor Pin (Permanent Fact)
      final anchorPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;

      // Glow halo
      canvas.drawCircle(
        Offset(scrubX, axisY),
        16,
        Paint()
          ..color = accentColor.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Anchor head
      canvas.drawCircle(Offset(scrubX, axisY), 8, anchorPaint);
      canvas.drawCircle(
        Offset(scrubX, axisY),
        3.5,
        Paint()..color = isDark ? Colors.black : Colors.white,
      );
    } else {
      // CONTINUOUS MODE: Elastic Scanning Wave Window (Temporary / In-progress)
      final waveRadius = 26.0 + math.sin(loopProgress * 2 * math.pi) * 6.0;

      // Holographic glowing disk
      final waveRect = Rect.fromCenter(
        center: Offset(scrubX, axisY),
        width: waveRadius * 2.6,
        height: 28,
      );

      final diskPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(waveRect, const Radius.circular(14)),
        diskPaint,
      );

      final waveRingPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(waveRect, const Radius.circular(14)),
        waveRingPaint,
      );

      // Vertical Laser Scanning Line
      canvas.drawLine(
        Offset(scrubX, axisY - 24),
        Offset(scrubX, axisY + 24),
        Paint()
          ..color = accentColor
          ..strokeWidth = 2.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawStationNode(
    Canvas canvas,
    Offset pos,
    String label,
    bool isDark, {
    bool isNow = false,
  }) {
    final dotPaint = Paint()
      ..color = (isNow
          ? accentColor
          : (isDark
                ? const Color(0xFFFFFFFF).withValues(alpha: 0.38)
                : const Color(0xFF000000).withValues(alpha: 0.26)))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, isNow ? 5 : 3.5, dotPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isNow
              ? accentColor
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          fontSize: isNow ? 10.5 : 9.5,
          fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(pos.dx - textPainter.width / 2, pos.dy - (isNow ? 26 : 22)),
    );
  }

  @override
  bool shouldRepaint(covariant _IsometricLabPainter oldDelegate) {
    return oldDelegate.scrubProgress != scrubProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.loopProgress != loopProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.pastLabel != pastLabel ||
        oldDelegate.nowLabel != nowLabel ||
        oldDelegate.futureLabel != futureLabel;
  }
}

// ==========================================
// FLUTTER WIDGET PREVIEW DEFINITIONS
// ==========================================

@Preview(name: 'Interactive Tense Lab Preview')
Widget grammarIsometricTimelinePreview() {
  return const ShadcnApp(
    home: Scaffold(
      child: Center(
        child: SizedBox(
          width: 440,
          child: Padding(
            padding: AppEdgeInsets.all16,
            child: GrammarIsometricTimeline25D(isMobile: true),
          ),
        ),
      ),
    ),
  );
}
