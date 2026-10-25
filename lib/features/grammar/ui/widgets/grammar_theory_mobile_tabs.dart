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
      padding: AppEdgeInsets.all12,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: AppEdgeInsets.h8v2,
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
                padding: AppEdgeInsets.h8v2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.5),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(
                    color: theme.colorScheme.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  unit.category.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: AppTypography.caption,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v8,
          Text(
            unit.title,
            style: TextStyle(
              fontSize: AppTypography.navPlus,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: theme.colorScheme.foreground,
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        children: availableTabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tabType = entry.value;
          final isSelected = activeIndex == index;
          final (IconData icon, String label) = switch (tabType) {
            GrammarTheoryTabType.concept => (
              LucideIcons.lightbulb,
              l10n.grammarTabConcept,
            ),
            GrammarTheoryTabType.formulas => (
              LucideIcons.sigma,
              l10n.grammarTabFormulas,
            ),
            GrammarTheoryTabType.traps => (
              LucideIcons.triangleAlert,
              l10n.grammarTabTraps,
            ),
            GrammarTheoryTabType.guides => (
              LucideIcons.bookOpen,
              l10n.grammarTabGuides,
            ),
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppDurations.short,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.card
                      : Colors.transparent,
                  borderRadius: AppRadius.borderSm,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.foreground.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: AppIconSize.xs,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.mutedForeground,
                    ),
                    AppGaps.h4,
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.xSmall,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.foreground
                              : theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
