import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../router/app_router.dart';
import '../models/exam_models.dart';
import '../providers/exam_catalog_notifier.dart';
import 'widgets/exam_paper_card.dart';

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
          title: Text(
            l10n.examBank,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.h4.copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: [
            Tooltip(
              tooltip: (context) =>
                  TooltipContainer(child: Text(l10n.wrongNotebook)),
              child: IconButton.outline(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.bookmark, size: AppIconSize.sm),
                onPressed: () => context.push(AppRoutes.wrongNotebook),
              ),
            ),
            AppGaps.h8,
            Tooltip(
              tooltip: (context) =>
                  TooltipContainer(child: Text(l10n.refreshTooltip)),
              child: IconButton.outline(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.rotateCw, size: AppIconSize.sm),
                onPressed: () => notifier.refreshFromCloud(),
              ),
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
          final isMobile =
              sizingInfo.deviceScreenType == DeviceScreenType.mobile;
          final padding = getValueForScreenType<double>(
            context: context,
            mobile: AppSpacing.pageMobile,
            tablet: AppSpacing.pageTablet,
            desktop: AppSpacing.pageDesktop,
          );
          final vSpacing = isMobile ? AppGaps.v12 : AppGaps.v16;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              vSpacing,
              _buildSearchAndFilters(
                context,
                ref,
                notifier,
                catalogState,
                searchQuery,
                theme,
                padding,
                vSpacing,
              ),
              vSpacing,
              Expanded(
                child: catalogState.isLoading && catalogState.papers.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : filteredPapers.isEmpty
                    ? SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: _buildEmptyState(theme, context),
                      )
                    : m.GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          0,
                          padding,
                          AppDimensions.bottomNavClearance,
                        ),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            m.SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisExtent: 170,
                            ),
                        itemCount: filteredPapers.length,
                        itemBuilder: (context, index) {
                          final paper = filteredPapers[index];
                          return ExamPaperCard(
                            paper: paper,
                            notifier: notifier,
                          );
                        },
                      ),
              ),
            ],
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
    ThemeData theme,
    double horizontalPadding,
    SizedBox vSpacing,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: TextField(
            features: const [
              InputFeature.leading(
                Icon(LucideIcons.search, size: AppIconSize.sm),
              ),
            ],
            placeholder: Text(l10n.searchExamsPlaceholder),
            onChanged: (val) => searchQuery.value = val,
          ),
        ),
        vSpacing,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              _buildFilterChip(
                theme: theme,
                label: l10n.allFilter,
                isSelected: state.selectedCategory == null,
                onTap: () => notifier.filterCategory(null),
              ),
              AppGaps.h8,
              ...ExamCategory.values.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _buildFilterChip(
                    theme: theme,
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
    required ThemeData theme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smPlus,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.typography.xSmall.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
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
            const Icon(LucideIcons.fileText, size: AppSpacing.xxxl),
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
