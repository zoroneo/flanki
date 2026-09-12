import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flanki/core/widgets/rich_card_content.dart';

/// Interactive tab definitions for grammar theory screen on mobile.
enum GrammarTheoryTabType {
  concept,
  formulas,
  traps,
  guides,
}

class GrammarTheoryMobileTabs extends HookWidget {
  final GrammarUnit unit;

  const GrammarTheoryMobileTabs({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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

    // Keep pageController and activeIndex in sync
    void onTabSelected(int index) {
      activeIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }

    return Column(
      children: [
        _buildHeaderBanner(theme, l10n),
        const SizedBox(height: 6),
        _buildTabBar(theme, l10n, availableTabs, activeIndex.value, onTabSelected),
        const SizedBox(height: 6),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            itemCount: availableTabs.length,
            onPageChanged: (index) => activeIndex.value = index,
            itemBuilder: (context, index) {
              final tabType = availableTabs[index];
              return _buildTabContent(context, theme, l10n, tabType);
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
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: levelColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              levelLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: levelColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Text(
              unit.category.code.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              unit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final isSelected = activeIndex == index;
          final tabType = availableTabs[index];
          final (IconData icon, String label, Color color) = switch (tabType) {
            GrammarTheoryTabType.concept => (
              LucideIcons.lightbulb,
              l10n.grammarTabConcept,
              m.Colors.amber,
            ),
            GrammarTheoryTabType.formulas => (
              LucideIcons.sigma,
              l10n.grammarTabFormulas,
              m.Colors.blue,
            ),
            GrammarTheoryTabType.traps => (
              LucideIcons.triangleAlert,
              l10n.grammarTabTraps,
              m.Colors.orange,
            ),
            GrammarTheoryTabType.guides => (
              LucideIcons.bookOpen,
              l10n.grammarTabGuides,
              m.Colors.purple,
            ),
          };

          return GestureDetector(
            onTap: () => onSelect(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.muted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
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
                    size: 13,
                    color: isSelected
                        ? theme.colorScheme.primaryForeground
                        : color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildTabContent(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    GrammarTheoryTabType tabType,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
      child: switch (tabType) {
        GrammarTheoryTabType.concept => _buildConceptStream(theme, l10n),
        GrammarTheoryTabType.formulas => _buildFormulasStream(theme, l10n),
        GrammarTheoryTabType.traps => _buildTrapsStream(theme, l10n),
        GrammarTheoryTabType.guides => _buildGuidesStream(theme, l10n),
      },
    );
  }

  Widget _buildConceptStream(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.lightbulb,
          iconColor: m.Colors.amber,
          title: l10n.grammarCoreConceptTitle,
          theme: theme,
        ),
        const SizedBox(height: 8),
        RichCardContent(
          content: unit.coreConcept,
          crossAxisAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.start,
          textStyle: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: theme.colorScheme.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildFormulasStream(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.sigma,
          iconColor: m.Colors.blue,
          title: l10n.grammarFormulasTitle,
          theme: theme,
        ),
        const SizedBox(height: 8),
        ...unit.formulas.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.border.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                RichCardContent(
                  content: entry.value,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.start,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrapsStream(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.triangleAlert,
          iconColor: m.Colors.orange,
          title: l10n.grammarCommonTrapsTitle,
          theme: theme,
        ),
        const SizedBox(height: 8),
        ...unit.commonTraps.map((trap) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichCardContent(
                  content: trap.trap,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.start,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildExampleBox(
                  icon: '❌ ',
                  content: trap.exampleWrong,
                  color: m.Colors.red,
                ),
                const SizedBox(height: 5),
                _buildExampleBox(
                  icon: '✅ ',
                  content: trap.exampleRight,
                  color: m.Colors.green,
                  isBold: true,
                ),
                if (trap.note.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.info,
                        size: 13,
                        color: m.Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: RichCardContent(
                          content: trap.note,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textAlign: TextAlign.start,
                          textStyle: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.mutedForeground,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGuidesStream(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.bookOpen,
          iconColor: m.Colors.purple,
          title: l10n.grammarExtraGuidesTitle,
          theme: theme,
        ),
        const SizedBox(height: 8),
        ...unit.extraGuides.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: m.Colors.purple,
                  ),
                ),
                const SizedBox(height: 4),
                RichCardContent(
                  content: entry.value,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textAlign: TextAlign.start,
                  textStyle: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleBox({
    required String icon,
    required String content,
    required m.MaterialColor color,
    bool isBold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          Expanded(
            child: RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
