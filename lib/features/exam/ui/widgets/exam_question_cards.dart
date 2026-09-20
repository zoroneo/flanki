import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../models/exam_models.dart';

class ExamPassageCard extends StatelessWidget {
  final String passage;

  const ExamPassageCard({super.key, required this.passage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      padding: const EdgeInsets.all(AppSpacing.smPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.readingPassage,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppGaps.v6,
          Text(passage, style: theme.typography.small),
        ],
      ),
    );
  }
}

class ExamOptionCard extends StatelessWidget {
  final ExamQuestionOption opt;
  final bool isSelected;
  final VoidCallback onTap;

  const ExamOptionCard({
    super.key,
    required this.opt,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return m.Material(
      type: m.MaterialType.transparency,
      child: m.InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: AppEdgeInsets.h16v12,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : theme.colorScheme.card,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.muted,
                ),
                child: Text(
                  opt.id,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.foreground,
                  ),
                ),
              ),
              AppGaps.h12,
              Expanded(child: Text(opt.text, style: theme.typography.base)),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamQuestionPromptCard extends StatelessWidget {
  final ExamQuestionModel question;
  final bool isFlagged;
  final VoidCallback onToggleBookmark;

  const ExamQuestionPromptCard({
    super.key,
    required this.question,
    required this.isFlagged,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      l10n.questionNumberPrefix(question.questionNumber),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (question.points > 0) ...[
                    AppGaps.h8,
                    Text(
                      l10n.examScorePoints(question.points),
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
              m.Material(
                type: m.MaterialType.transparency,
                child: m.InkWell(
                  onTap: onToggleBookmark,
                  borderRadius: AppRadius.borderFull,
                  child: AnimatedContainer(
                    duration: AppDurations.short,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.smPlus,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isFlagged
                          ? AppColors.warning.withValues(alpha: 0.15)
                          : theme.colorScheme.muted.withValues(alpha: 0.35),
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                        color: isFlagged
                            ? AppColors.warning.withValues(alpha: 0.6)
                            : theme.colorScheme.border.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFlagged
                              ? RadixIcons.bookmarkFilled
                              : RadixIcons.bookmark,
                          size: AppIconSize.xs,
                          color: isFlagged
                              ? AppColors.warning
                              : theme.colorScheme.mutedForeground,
                        ),
                        AppGaps.h4,
                        Text(
                          isFlagged
                              ? l10n.bookmarkedQuestion
                              : l10n.bookmarkQuestion,
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: isFlagged
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isFlagged
                                ? AppColors.warning
                                : theme.colorScheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v8,
          Text(
            question.questionText,
            style: theme.typography.base.copyWith(
              fontWeight: FontWeight.w600,
              height: AppTypography.lineHeightNormal,
            ),
          ),
        ],
      ),
    );
  }
}
