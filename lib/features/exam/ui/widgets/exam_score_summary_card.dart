import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/exam_models.dart';

class ExamScoreSummaryCard extends StatelessWidget {
  final ExamSubmissionModel submission;
  final ExamPaperModel paper;
  final dynamic l10n;

  const ExamScoreSummaryCard({
    super.key,
    required this.submission,
    required this.paper,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassed = submission.isPassed;
    final mins = submission.durationSeconds ~/ ExamConstants.secondsPerMinute;
    final secs = submission.durationSeconds % ExamConstants.secondsPerMinute;
    final durationStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: isPassed ? context.colors.success : context.colors.error,
              borderRadius: AppRadius.borderXl,
            ),
            child: Text(
              isPassed ? l10n.examPassed : l10n.examFailed,
              style: context.textStyles.xSmallBold.copyWith(
                color: theme.colorScheme.primaryForeground,
              ),
            ),
          ),
          AppGaps.v12,
          Text(
            l10n.examScorePoints(submission.score),
            style: context.textStyles.display.copyWith(
              color: isPassed
                  ? context.colors.success
                  : theme.colorScheme.foreground,
            ),
          ),
          AppGaps.v8,
          Text(
            paper.title,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
          AppGaps.v16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                l10n.correctCountStat,
                '${submission.totalCorrect}/${submission.totalQuestions}',
                theme,
              ),
              _buildStatColumn(l10n.durationStat, durationStr, theme),
              _buildStatColumn(
                l10n.passingScoreStat,
                '${paper.passingScore}',
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.typography.large.copyWith(fontWeight: FontWeight.bold),
        ),
        AppGaps.v4,
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
