import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class ExamSectionHeader extends StatelessWidget {
  final String? paperTitle;
  final String sectionTitle;
  final int currentIndex;
  final int totalQuestions;

  const ExamSectionHeader({
    super.key,
    this.paperTitle,
    required this.sectionTitle,
    required this.currentIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Exam Title + Question progress badge
          Row(
            children: [
              if (paperTitle != null && paperTitle!.isNotEmpty)
                Expanded(
                  child: Text(
                    paperTitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                ),
              AppGaps.h8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smPlus,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  l10n.questionProgress(currentIndex + 1, totalQuestions),
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          // Row 2: Full Section Title (up to 2 lines without truncation)
          if (sectionTitle.isNotEmpty) ...[
            AppGaps.v4,
            Text(
              sectionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.mutedForeground,
                fontWeight: FontWeight.w500,
                height: AppTypography.lineHeightNormal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
