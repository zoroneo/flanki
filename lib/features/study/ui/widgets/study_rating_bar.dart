import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/fsrs/fsrs_engine_service.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';

class StudyRatingBar extends StatelessWidget {
  final Map<ReviewRating, String> intervals;
  final bool isMobile;
  final ValueChanged<ReviewRating> onRate;

  const StudyRatingBar({
    super.key,
    required this.intervals,
    required this.isMobile,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: RatingButton(
            label: l10n.ratingAgain,
            shortcutHint: isMobile ? null : '1',
            interval:
                intervals[ReviewRating.again] ??
                '< ${l10n.intervalMinutes(FsrsEngineService.fallbackAgainMinutes)}',
            backgroundColor: AppColors.ratingAgain,
            onTap: () => onRate(ReviewRating.again),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: RatingButton(
            label: l10n.ratingHard,
            shortcutHint: isMobile ? null : '2',
            interval:
                intervals[ReviewRating.hard] ??
                l10n.intervalDays(FsrsEngineService.fallbackHardIntervalDays),
            backgroundColor: AppColors.ratingHard,
            onTap: () => onRate(ReviewRating.hard),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: RatingButton(
            label: l10n.ratingGood,
            shortcutHint: isMobile ? null : '3',
            interval:
                intervals[ReviewRating.good] ??
                l10n.intervalDays(FsrsEngineService.fallbackGoodIntervalDays),
            backgroundColor: AppColors.ratingGood,
            onTap: () => onRate(ReviewRating.good),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: RatingButton(
            label: l10n.ratingEasy,
            shortcutHint: isMobile ? null : '4',
            interval:
                intervals[ReviewRating.easy] ??
                l10n.intervalDays(FsrsEngineService.fallbackEasyIntervalDays),
            backgroundColor: AppColors.ratingEasy,
            onTap: () => onRate(ReviewRating.easy),
          ),
        ),
      ],
    );
  }
}

class RatingButton extends HookWidget {
  final String label;
  final String interval;
  final String? shortcutHint;
  final m.Color backgroundColor;
  final VoidCallback onTap;

  const RatingButton({
    super.key,
    required this.label,
    required this.interval,
    this.shortcutHint,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPressed = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => isPressed.value = true,
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        onTap: onTap,
        child: AnimatedScale(
          scale: isPressed.value ? AppThemeValues.ratingButtonPressedScale : 1.0,
          duration: AppDurations.quick,
          curve: Curves.easeOutCubic,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppDimensions.ratingButtonMinHeight,
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadius.borderMd,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLabelRow(),
                AppGaps.v2,
                Text(
                  interval,
                  style: TextStyle(
                    color: m.Colors.white.withValues(alpha: 0.85),
                    fontSize: AppTypography.caption,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: m.Colors.white,
            fontSize: AppTypography.nav,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (shortcutHint != null) ...[
          AppGaps.h4,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 1,
            ),
            decoration: BoxDecoration(
              color: m.Colors.black.withValues(alpha: 0.25),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              shortcutHint!,
              style: const TextStyle(
                color: m.Colors.white,
                fontSize: AppTypography.badge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
