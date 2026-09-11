import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/models/grammar/grammar_models.dart';
import '../../../core/services/grammar_service.dart';
import '../../../core/storage/grammar_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

class GrammarCatalogScreen extends HookConsumerWidget {
  const GrammarCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final grammarAsync = ref.watch(grammarUnitsProvider);
    final repo = ref.watch(grammarRepositoryProvider);

    final selectedLevel = useState<GrammarLevel?>(null); // null = All, or specific GrammarLevel
    final searchQuery = useState<String>('');

    // Preload repository data on screen entry
    useEffect(() {
      repo.init();
      return null;
    }, const []);

    final totalGhosts = repo.totalGhostCount;
    final totalDues = repo.totalDueCount;
    final totalCompleted = repo.totalCompletedCount;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

        final crossAxisCount = getValueForScreenType<int>(
          context: context,
          mobile: 1,
          tablet: 2,
          desktop: sizingInfo.screenSize.width >= 1280 ? 3 : 2,
        );
        final spacing = getValueForScreenType<double>(
          context: context,
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        );
        final mainAxisExtent = getValueForScreenType<double>(
          context: context,
          mobile: 215.0,
          tablet: 230.0,
          desktop: 235.0,
        );
        final horizontalPadding = getValueForScreenType<double>(
          context: context,
          mobile: 16.0,
          tablet: 20.0,
          desktop: 28.0,
        );

        return Scaffold(
          headers: [
            AppBar(
              title: Text(l10n.grammarAcademicTitle),
              trailing: [
                if (totalGhosts > 0)
                  GhostButton(
                    density: ButtonDensity.compact,
                    size: ButtonSize.small,
                    onPressed: () => context.push(
                      '/grammar/ghost_review/practice?mode=${GrammarPracticeMode.ghost.value}',
                    ),
                    leading: const Icon(
                      LucideIcons.flame,
                      size: 16,
                      color: m.Colors.orange,
                    ),
                    child: Text(
                      isMobile
                          ? '$totalGhosts Ghost'
                          : l10n.grammarClearGhostsButton(totalGhosts),
                      maxLines: 1,
                    ),
                  ),
              ],
            ),
          ],
          child: grammarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text(l10n.grammarErrorLoadCatalog(err.toString()))),
            data: (units) {
              final filteredUnits = units.where((u) {
                if (selectedLevel.value != null && u.level != selectedLevel.value) {
                  return false;
                }
                if (searchQuery.value.isNotEmpty) {
                  final query = searchQuery.value.toLowerCase();
                  final matchesTitle = u.title.toLowerCase().contains(query);
                  final matchesCatName = u.category.displayName.toLowerCase().contains(query);
                  final matchesCatCode = u.category.code.toLowerCase().contains(query);
                  return matchesTitle || matchesCatName || matchesCatCode;
                }
                return true;
              }).toList();

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: CustomScrollView(
                    slivers: [
                      // Stats & Filters
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Quick Stats Metrics
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: _buildStats(
                                context,
                                isCompact: isMobile,
                                totalCompleted: totalCompleted,
                                totalDues: totalDues,
                                totalGhosts: totalGhosts,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Search & Level Filters
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: _buildSearchField(context, searchQuery),
                            ),
                            const SizedBox(height: 14),

                            // Level Filter Buttons
                            if (isMobile)
                              _buildLevelFilters(
                                context,
                                selectedLevel: selectedLevel,
                                isMobile: true,
                                horizontalPadding: horizontalPadding,
                              )
                            else
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: _buildLevelFilters(
                                  context,
                                  selectedLevel: selectedLevel,
                                  isMobile: false,
                                  horizontalPadding: horizontalPadding,
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Units Grid / Empty State
                      if (filteredUnits.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.searchX,
                                  size: 44,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.grammarUnitNotFound,
                                  style: TextStyle(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 32),
                          sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: spacing,
                              crossAxisSpacing: spacing,
                              mainAxisExtent: mainAxisExtent,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final unit = filteredUnits[index];
                                final summary = repo.getUnitSummary(unit.unitId);
                                return _buildUnitCard(context, unit, summary);
                              },
                              childCount: filteredUnits.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStats(
    BuildContext context, {
    required bool isCompact,
    required int totalCompleted,
    required int totalDues,
    required int totalGhosts,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.grammarMetricTotalUnits,
            value: '${GrammarConstants.totalUnits} Units',
            icon: LucideIcons.layers,
            color: Colors.blue,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.grammarMetricCompletedExercises,
            value: '$totalCompleted / ${GrammarConstants.totalExercises}',
            icon: LucideIcons.circleCheck,
            color: Colors.green,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.grammarMetricDueGhosts,
            value: '$totalDues / $totalGhosts',
            icon: LucideIcons.shieldAlert,
            color: (totalGhosts > 0 || totalDues > 0) ? Colors.red : Colors.green,
            isCompact: isCompact,
            onTap: totalGhosts > 0
                ? () => context.push(
                      '/grammar/ghost_review/practice?mode=${GrammarPracticeMode.ghost.value}',
                    )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, ValueNotifier<String> searchQuery) {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      features: const [
        InputFeature.leading(
          Icon(LucideIcons.search, size: 16),
        ),
      ],
      placeholder: Text(l10n.grammarSearchPlaceholder),
      onChanged: (val) => searchQuery.value = val,
    );
  }

  Widget _buildLevelFilters(
    BuildContext context, {
    required ValueNotifier<GrammarLevel?> selectedLevel,
    required bool isMobile,
    double horizontalPadding = 16.0,
  }) {
    final l10n = AppLocalizations.of(context)!;

    final chips = [
      _buildFilterChip(
        context,
        label: l10n.grammarFilterAll(GrammarConstants.totalUnits),
        isSelected: selectedLevel.value == null,
        onTap: () => selectedLevel.value = null,
      ),
      ...GrammarLevel.values.map((lvl) {
        return _buildFilterChip(
          context,
          label: lvl.getLocalizedName(l10n),
          isSelected: selectedLevel.value == lvl,
          onTap: () => selectedLevel.value = lvl,
        );
      }),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              chips[i],
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required m.Color color,
    bool isCompact = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final cardWidget = isCompact
        ? Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.xSmall.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: theme.typography.base.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          label,
                          style: theme.typography.xSmall.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, GrammarUnit unit, UnitProgressSummary summary) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final levelColor = unit.level.color;
    final levelText = unit.level.getLocalizedName(l10n);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badges & Tags
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: levelColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        levelText,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          unit.category.code.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ),
                    if (summary.ghostCount > 0 || summary.dueCount > 0)
                      const Spacer(),
                    if (summary.ghostCount > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${summary.ghostCount} Ghost',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    if (summary.dueCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${summary.dueCount} Due',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  unit.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mastery Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: summary.masteryPercentage / 100.0,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.grammarMasteryPercentage(summary.masteryPercentage.toStringAsFixed(0)),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: summary.isMastered ? Colors.green : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Buttons & Progress counter
                LayoutBuilder(
                  builder: (context, cardConstraints) {
                    final isNarrow = cardConstraints.maxWidth < 360;
                    final progressWidget = Text(
                      l10n.grammarCompletedProgress(
                        summary.completedCount,
                        GrammarConstants.exercisesPerUnit,
                      ),
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                        fontSize: 11,
                      ),
                    );

                    final theoryButton = OutlineButton(
                      size: ButtonSize.small,
                      onPressed: () => context.push('/grammar/${unit.unitId}/theory'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.bookOpen, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.grammarTheoryButton,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );

                    final practiceButton = PrimaryButton(
                      size: ButtonSize.small,
                      onPressed: () => context.push('/grammar/${unit.unitId}/practice'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.play, size: 13),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              l10n.grammarPracticeButton,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          progressWidget,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: theoryButton),
                              const SizedBox(width: 6),
                              Expanded(child: practiceButton),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        progressWidget,
                        const Spacer(),
                        theoryButton,
                        const SizedBox(width: 6),
                        practiceButton,
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
