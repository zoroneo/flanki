import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/exam_models.dart';

class ExamQuestionResultCard extends StatelessWidget {
  final ExamQuestionModel question;
  final String? userAnswer;
  final dynamic l10n;

  const ExamQuestionResultCard({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAns = userAnswer;
    final isCorrect =
        userAns != null &&
        userAns.trim().toUpperCase() ==
            question.correctAnswer.trim().toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.smPlus),
      child: Card(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.questionNumberPrefix(question.questionNumber),
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCorrect)
                  Row(
                    children: [
                      const Icon(
                        RadixIcons.checkCircled,
                        size: AppIconSize.sm,
                        color: AppColors.success,
                      ),
                      AppGaps.h4,
                      Text(
                        l10n.correctBadge,
                        style: theme.typography.xSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      const Icon(
                        RadixIcons.crossCircled,
                        size: AppIconSize.sm,
                        color: AppColors.error,
                      ),
                      AppGaps.h4,
                      Text(
                        l10n.incorrectBadge,
                        style: theme.typography.xSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            AppGaps.v8,
            Text(question.questionText, style: theme.typography.small),
            AppGaps.v12,
            ...question.options.map((opt) {
              final isUserPick =
                  userAns != null &&
                  userAns.trim().toUpperCase() == opt.id.trim().toUpperCase();
              final isActualCorrect =
                  opt.id.trim().toUpperCase() ==
                  question.correctAnswer.trim().toUpperCase();

              BoxDecoration optDecoration;
              if (isActualCorrect) {
                optDecoration = BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.1),
                  border: Border.all(color: context.colors.success),
                  borderRadius: AppRadius.borderSm,
                );
              } else if (isUserPick && !isCorrect) {
                optDecoration = BoxDecoration(
                  color: context.colors.error.withValues(alpha: 0.1),
                  border: Border.all(color: context.colors.error),
                  borderRadius: AppRadius.borderSm,
                );
              } else {
                optDecoration = BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.2),
                  borderRadius: AppRadius.borderSm,
                );
              }

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: optDecoration,
                child: Row(
                  children: [
                    Text(
                      '${opt.id}. ',
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: theme.typography.xSmall.copyWith(
                          fontWeight: (isActualCorrect || isUserPick)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isActualCorrect)
                      Icon(
                        RadixIcons.check,
                        size: AppIconSize.xsPlus,
                        color: context.colors.success,
                      ),
                    if (isUserPick && !isCorrect)
                      Icon(
                        RadixIcons.cross2,
                        size: AppIconSize.xsPlus,
                        color: context.colors.error,
                      ),
                  ],
                ),
              );
            }),
            if (question.explanation.isNotEmpty) ...[
              AppGaps.v8,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.3),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  '${l10n.explanationPrefix} ${question.explanation}',
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
