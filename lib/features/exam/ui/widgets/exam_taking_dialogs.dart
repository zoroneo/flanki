import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/exam_session_notifier.dart';

class ExamTakingDialogs {
  const ExamTakingDialogs._();

  static void showConfirmSubmit({
    required BuildContext context,
    required ExamSessionState state,
    required ExamSessionNotifier notifier,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unanswered = state.questions.length - state.answeredCount;
    final isWarning = unanswered > 0;

    m.showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Card(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            (isWarning
                                    ? AppColors.warning
                                    : theme.colorScheme.primary)
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWarning
                            ? RadixIcons.exclamationTriangle
                            : RadixIcons.check,
                        size: AppIconSize.md,
                        color: isWarning
                            ? AppColors.warning
                            : theme.colorScheme.primary,
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: Text(
                        l10n.confirmSubmitExamTitle,
                        style: theme.typography.large.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.v12,
                Text(
                  isWarning
                      ? l10n.confirmSubmitUnfinished(unanswered)
                      : l10n.confirmSubmitFinished,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
                AppGaps.v20,
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        alignment: Alignment.center,
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          l10n.continueExam,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: PrimaryButton(
                        alignment: Alignment.center,
                        onPressed: () {
                          Navigator.pop(ctx);
                          notifier.submitExam();
                        },
                        child: Text(
                          l10n.submitExamNow,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showConfirmExit(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    m.showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Card(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.destructive.withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        RadixIcons.exclamationTriangle,
                        size: AppIconSize.md,
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: Text(
                        l10n.confirmExitExamTitle,
                        style: theme.typography.large.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.v12,
                Text(
                  l10n.confirmExitExamDesc,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    height: AppTypography.lineHeightNormal,
                  ),
                ),
                AppGaps.v20,
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        alignment: Alignment.center,
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          l10n.stayInExam,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: DestructiveButton(
                        alignment: Alignment.center,
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: Text(l10n.exitExam, textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
