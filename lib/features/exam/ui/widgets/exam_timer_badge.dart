import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/exam_models.dart';
import '../../providers/exam_session_notifier.dart';

class ExamTimerBadge extends ConsumerWidget {
  const ExamTimerBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remainingSec = ref.watch(
      examSessionProvider.select((s) => s.remainingSeconds),
    );

    final mins = remainingSec ~/ ExamConstants.secondsPerMinute;
    final secs = remainingSec % ExamConstants.secondsPerMinute;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isUrgent = remainingSec < ExamConstants.urgentTimerSeconds;

    final urgentColor = theme.colorScheme.destructive;
    final normalTextColor = theme.colorScheme.foreground;
    final badgeColor = isUrgent
        ? urgentColor.withValues(alpha: 0.12)
        : theme.colorScheme.muted.withValues(alpha: 0.45);
    final borderColor = isUrgent
        ? urgentColor.withValues(alpha: 0.4)
        : theme.colorScheme.border.withValues(alpha: 0.5);
    final contentColor = isUrgent ? urgentColor : normalTextColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: borderColor, width: AppDimensions.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(RadixIcons.clock, size: AppIconSize.sm, color: contentColor),
          AppGaps.h8,
          Text(
            timeStr,
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.w700,
              color: contentColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
