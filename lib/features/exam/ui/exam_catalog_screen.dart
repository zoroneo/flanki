import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/exam_models.dart';
import '../providers/exam_catalog_notifier.dart';

class ExamCatalogScreen extends HookConsumerWidget {
  const ExamCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final catalogState = ref.watch(examCatalogProvider);
    final notifier = ref.read(examCatalogProvider.notifier);

    final searchQuery = useState<String>('');

    final filteredPapers = catalogState.papers.where((p) {
      if (searchQuery.value.trim().isEmpty) return true;
      final q = searchQuery.value.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.level.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      headers: [
        AppBar(
          title: Text(l10n.examBank),
          trailing: [
            OutlineButton(
              size: ButtonSize.small,
              onPressed: () => context.push('/exams/wrong-notebook'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RadixIcons.bookmark, size: 14),
                  AppGaps.h8,
                  Text(l10n.wrongNotebook),
                ],
              ),
            ),
            AppGaps.h8,
            IconButton.outline(
              size: ButtonSize.small,
              icon: const Icon(RadixIcons.reload, size: 16),
              onPressed: () => notifier.refreshFromCloud(),
            ),
          ],
        ),
      ],
      child: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          final crossAxisCount = getValueForScreenType<int>(
            context: context,
            mobile: 1,
            tablet: 2,
            desktop: sizingInfo.screenSize.width >= 1280 ? 3 : 2,
          );
          final padding = getValueForScreenType<double>(
            context: context,
            mobile: AppSpacing.sm,
            tablet: AppSpacing.md,
            desktop: AppSpacing.lg,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search and Category Tabs
                _buildSearchAndFilters(
                  context,
                  ref,
                  notifier,
                  catalogState,
                  searchQuery,
                ),
                AppGaps.v16,

                if (catalogState.isLoading && catalogState.papers.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredPapers.isEmpty)
                  _buildEmptyState(theme, context)
                else
                  m.GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: m.SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 170,
                    ),
                    itemCount: filteredPapers.length,
                    itemBuilder: (context, index) {
                      final paper = filteredPapers[index];
                      return _buildExamCard(context, paper, notifier, theme);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    WidgetRef ref,
    ExamCatalogNotifier notifier,
    ExamCatalogState state,
    ValueNotifier<String> searchQuery,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          features: const [
            InputFeature.leading(Icon(RadixIcons.magnifyingGlass, size: 16)),
          ],
          placeholder: Text(l10n.searchExamsPlaceholder),
          onChanged: (val) => searchQuery.value = val,
        ),
        AppGaps.v12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: l10n.allFilter,
                isSelected: state.selectedCategory == null,
                onTap: () => notifier.filterCategory(null),
              ),
              AppGaps.h8,
              ...ExamCategory.values.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _buildFilterChip(
                    label: cat.code,
                    isSelected: state.selectedCategory == cat,
                    onTap: () => notifier.filterCategory(cat),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildBadge(ThemeData theme, String text) {
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

  Widget _buildExamCard(
    BuildContext context,
    ExamPaperModel paper,
    ExamCatalogNotifier notifier,
    ThemeData theme,
  ) {
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
                  _buildBadge(theme, '${paper.category.code} ${paper.level}'),
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
                  RadixIcons.checkCircled,
                  size: 16,
                  color: m.Colors.green,
                )
              else
                const Icon(m.Icons.cloud_download_outlined, size: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!paper.isDownloaded)
                OutlineButton(
                  size: ButtonSize.small,
                  onPressed: () => notifier.downloadExam(paper.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RadixIcons.download, size: 14),
                      AppGaps.h4,
                      Text(l10n.downloadExam),
                    ],
                  ),
                ),
              AppGaps.h8,
              PrimaryButton(
                size: ButtonSize.small,
                onPressed: () => context.push('/exams/${paper.id}/taking'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.takeExam),
                    AppGaps.h4,
                    const Icon(RadixIcons.arrowRight, size: 14),
                  ],
                ),
              ),
            ],
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
          children: [
            const Icon(RadixIcons.fileText, size: 48),
            AppGaps.v12,
            Text(
              l10n.noExamsFoundTitle,
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppGaps.v4,
            Text(
              l10n.noExamsFoundDesc,
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
