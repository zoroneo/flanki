import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../models/exam_models.dart';
import '../providers/wrong_notebook_notifier.dart';

class WrongNotebookScreen extends HookConsumerWidget {
  const WrongNotebookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final state = ref.watch(wrongNotebookProvider);
    final notifier = ref.read(wrongNotebookProvider.notifier);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(RadixIcons.arrowLeft, size: AppIconSize.sm),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(l10n.wrongNotebook),
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            // Status Filters
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: l10n.allCountFilter(state.questions.length),
                      isSelected: state.filterStatus == null,
                      onTap: () => notifier.filterStatus(null),
                    ),
                    AppGaps.h8,
                    ...WrongQuestionStatus.values.map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _buildFilterChip(
                          label: status.getLocalizedLabel(l10n),
                          isSelected: state.filterStatus == status,
                          onTap: () => notifier.filterStatus(status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: AppDimensions.hairline),

            Expanded(
              child: () {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.questions.isEmpty) {
                  return _buildEmptyState(theme, context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: state.questions.length,
                  separatorBuilder: (_, index) => AppGaps.v12,
                  itemBuilder: (context, index) {
                    final item = state.questions[index];
                    return _buildWrongItemCard(context, item, notifier, theme);
                  },
                );
              }(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return isSelected
        ? PrimaryButton(
            size: ButtonSize.small,
            onPressed: onTap,
            child: Text(label),
          )
        : OutlineButton(
            size: ButtonSize.small,
            onPressed: onTap,
            child: Text(label),
          );
  }

  Widget _buildWrongItemCard(
    BuildContext context,
    WrongQuestionModel item,
    WrongNotebookNotifier notifier,
    ThemeData theme,
  ) {
    final l10n = context.l10n;
    return Card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: switch (item.status) {
                    WrongQuestionStatus.mastered => AppColors.success,
                    WrongQuestionStatus.reviewing => AppColors.warning,
                    WrongQuestionStatus.newQuestion => AppColors.error,
                  },
                  borderRadius: AppRadius.borderLg,
                ),
                child: Text(
                  item.status.getLocalizedLabel(l10n),
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              Text(
                l10n.examPrefixLabel(item.examId),
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          AppGaps.v8,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderMd,
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  RadixIcons.crossCircled,
                  size: AppIconSize.sm,
                  color: AppColors.error,
                ),
                AppGaps.h8,
                Text(
                  l10n.selectedAnswerPrefix(
                    item.userAnswer.isEmpty
                        ? l10n.unansweredPlaceholder
                        : item.userAnswer,
                  ),
                  style: theme.typography.small.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (item.explanation.isNotEmpty) ...[
            AppGaps.v8,
            Text(
              l10n.explanationPrefix(item.explanation),
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
          AppGaps.v12,
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (item.status != WrongQuestionStatus.reviewing)
                  OutlineButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: () => notifier.markStatus(
                      item.id,
                      WrongQuestionStatus.reviewing,
                    ),
                    child: Text(l10n.reviewMistakeButton),
                  ),
                AppGaps.h8,
                if (item.status != WrongQuestionStatus.mastered)
                  PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: () => notifier.markStatus(
                      item.id,
                      WrongQuestionStatus.mastered,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RadixIcons.check, size: AppIconSize.sm),
                        AppGaps.h4,
                        Text(l10n.masteredMistakeButton),
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

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              RadixIcons.checkCircled,
              size: AppSpacing.xxxl,
              color: AppColors.success,
            ),
            AppGaps.v12,
            Text(
              l10n.noWrongQuestionsTitle,
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppGaps.v4,
            Text(
              l10n.noWrongQuestionsDesc,
              textAlign: TextAlign.center,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
