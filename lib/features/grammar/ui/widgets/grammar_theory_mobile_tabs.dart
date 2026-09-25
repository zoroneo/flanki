import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';
import 'grammar_theory_tab_views.dart';

/// Interactive tab definitions for grammar theory screen on mobile.
enum GrammarTheoryTabType { concept, formulas, traps, guides }

class GrammarTheoryMobileTabs extends HookWidget {
  final GrammarUnit unit;

  const GrammarTheoryMobileTabs({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Dynamically assemble available tabs based on unit data
    final availableTabs = useMemoized(() {
      final tabs = <GrammarTheoryTabType>[GrammarTheoryTabType.concept];
      if (unit.formulas.isNotEmpty) tabs.add(GrammarTheoryTabType.formulas);
      if (unit.commonTraps.isNotEmpty) tabs.add(GrammarTheoryTabType.traps);
      if (unit.extraGuides.isNotEmpty) tabs.add(GrammarTheoryTabType.guides);
      return tabs;
    }, [unit]);

    final activeIndex = useState<int>(0);
    final pageController = usePageController(initialPage: 0);

    void onTabSelected(int index) {
      activeIndex.value = index;
      pageController.animateToPage(
        index,
        duration: AppDurations.modal,
        curve: Curves.easeInOut,
      );
    }

    return Column(
      children: [
        _buildHeaderBanner(theme, l10n),
        AppGaps.v6,
        _buildTabBar(
          theme,
          l10n,
          availableTabs,
          activeIndex.value,
          onTabSelected,
        ),
        AppGaps.v6,
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: availableTabs.length,
            onPageChanged: (index) => activeIndex.value = index,
            itemBuilder: (context, index) {
              final tabType = availableTabs[index];
              return switch (tabType) {
                GrammarTheoryTabType.concept => GrammarConceptTabView(
                  unit: unit,
                ),
                GrammarTheoryTabType.formulas => GrammarFormulasTabView(
                  unit: unit,
                ),
                GrammarTheoryTabType.traps => GrammarTrapsTabView(unit: unit),
                GrammarTheoryTabType.guides => GrammarGuidesTabView(unit: unit),
              };
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBanner(ThemeData theme, AppLocalizations l10n) {
    final levelLabel = unit.level.getLocalizedName(l10n);
    final levelColor = unit.level.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      padding: AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: levelColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              levelLabel,
              style: TextStyle(
                fontSize: AppTypography.caption,
                fontWeight: FontWeight.bold,
                color: levelColor,
              ),
            ),
          ),
          AppGaps.h8,
          Container(
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Text(
              unit.category.code.toUpperCase(),
              style: const TextStyle(
                fontSize: AppTypography.caption,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppGaps.h8,
          Expanded(
            child: Text(
              unit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppTypography.nav,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(
    ThemeData theme,
    AppLocalizations l10n,
    List<GrammarTheoryTabType> availableTabs,
    int activeIndex,
    ValueChanged<int> onSelect,
  ) {
    return Container(
      height: AppDimensions.horizontalTabsHeight,
      padding: AppEdgeInsets.h16,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableTabs.length,
        separatorBuilder: (_, _) => AppGaps.h8,
        itemBuilder: (context, index) {
          final isSelected = activeIndex == index;
          final tabType = availableTabs[index];
          final colors = context.colors;
          final (IconData icon, String label, Color color) = switch (tabType) {
            GrammarTheoryTabType.concept => (
              LucideIcons.lightbulb,
              l10n.grammarTabConcept,
              colors.cramAmber,
            ),
            GrammarTheoryTabType.formulas => (
              LucideIcons.sigma,
              l10n.grammarTabFormulas,
              colors.info,
            ),
            GrammarTheoryTabType.traps => (
              LucideIcons.triangleAlert,
              l10n.grammarTabTraps,
              colors.warning,
            ),
            GrammarTheoryTabType.guides => (
              LucideIcons.bookOpen,
              l10n.grammarTabGuides,
              colors.accentPurple,
            ),
          };

          return GestureDetector(
            onTap: () => onSelect(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppDurations.short,
              padding: AppEdgeInsets.h12v8,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.muted.withValues(alpha: 0.4),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: AppIconSize.xs,
                    color: isSelected
                        ? theme.colorScheme.primaryForeground
                        : color,
                  ),
                  AppGaps.h4,
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppTypography.xSmall,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primaryForeground
                          : theme.colorScheme.foreground,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
