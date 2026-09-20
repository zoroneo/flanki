import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../models/exam_models.dart';
import '../../providers/exam_catalog_notifier.dart';

class ExamPaperCard extends StatelessWidget {
  final ExamPaperModel paper;
  final ExamCatalogNotifier notifier;

  const ExamPaperCard({super.key, required this.paper, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildCategoryBadge(
                    theme,
                    '${paper.category.code} ${paper.level}',
                  ),
                  AppGaps.h8,
                  Text(
                    l10n.examDurationAndQuestions(
                      paper.durationMinutes,
                      paper.totalQuestions,
                    ),
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
              if (paper.isDownloaded)
                const Icon(
                  LucideIcons.circleCheck,
                  size: AppIconSize.sm,
                  color: AppColors.success,
                )
              else
                Icon(
                  LucideIcons.cloudDownload,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.mutedForeground,
                ),
            ],
          ),
          AppGaps.v8,
          Text(
            paper.title,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            paper.description,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppGaps.v8,
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!paper.isDownloaded)
                  OutlineButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: () => notifier.downloadExam(paper.id),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.download, size: AppIconSize.sm),
                        AppGaps.h4,
                        Text(l10n.downloadExam),
                      ],
                    ),
                  ),
                AppGaps.h8,
                PrimaryButton(
                  alignment: Alignment.center,
                  size: ButtonSize.small,
                  onPressed: () => context.push(AppRoutes.examTaking(paper.id)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.takeExam),
                      AppGaps.h4,
                      const Icon(LucideIcons.arrowRight, size: AppIconSize.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: AppRadius.borderLg,
      ),
      child: Text(
        text,
        style: theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.secondaryForeground,
        ),
      ),
    );
  }
}
