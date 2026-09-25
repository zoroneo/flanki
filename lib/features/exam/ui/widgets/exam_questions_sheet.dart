import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_modal.dart';
import '../../providers/exam_session_notifier.dart';

class ExamQuestionsSheet {
  const ExamQuestionsSheet._();

  static void show({
    required BuildContext context,
    required ExamSessionState state,
    required ExamSessionNotifier notifier,
    required ThemeData theme,
  }) {
    final l10n = context.l10n;

    showAdaptiveModal(
      context: context,
      builder: (ctx, isDesktop) {
        return AdaptiveModalFrame(
          isDesktop: isDesktop,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.questionListTitle,
                    style: theme.typography.base.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton.ghost(
                    size: ButtonSize.small,
                    density: ButtonDensity.compact,
                    icon: const Icon(RadixIcons.cross1, size: AppIconSize.sm),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              AppGaps.v16,
              Wrap(
                spacing: AppSpacing.smPlus,
                runSpacing: AppSpacing.smPlus,
                children: List.generate(state.questions.length, (i) {
                  final q = state.questions[i];
                  final isAnswered = state.selectedAnswers.containsKey(q.id);
                  final isFlagged = state.flaggedQuestionIds.contains(q.id);
                  final isCurrent = state.currentIndex == i;

                  Color bg = theme.colorScheme.muted;
                  Color fg = theme.colorScheme.foreground;
                  if (isCurrent) {
                    bg = theme.colorScheme.primary;
                    fg = theme.colorScheme.primaryForeground;
                  } else if (isFlagged) {
                    bg = AppColors.warning;
                    fg = theme.colorScheme.primaryForeground;
                  } else if (isAnswered) {
                    bg = AppColors.success;
                    fg = theme.colorScheme.primaryForeground;
                  }

                  return m.Material(
                    type: m.MaterialType.transparency,
                    child: m.InkWell(
                      onTap: () {
                        notifier.jumpTo(i);
                        Navigator.pop(ctx);
                      },
                      borderRadius: AppRadius.borderMd,
                      child: Container(
                        width: AppDimensions.touchTargetMin,
                        height: AppDimensions.touchTargetMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: AppRadius.borderMd,
                          border: isCurrent
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: AppDimensions.borderSelected,
                                )
                              : null,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: theme.typography.small.copyWith(
                            color: fg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
