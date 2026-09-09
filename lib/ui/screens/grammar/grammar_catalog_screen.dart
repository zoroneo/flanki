import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return Scaffold(
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

          return CustomScrollView(
            slivers: [
              // Header & Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Subtitle + Ghost Action
                      LayoutBuilder(
                        builder: (context, headerConstraints) {
                          final isMobile = headerConstraints.maxWidth < 600;
                          final titleWidget = Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  LucideIcons.bookOpenText,
                                  size: 24,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.grammarAcademicTitle,
                                      style: theme.typography.h3.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.grammarAcademicSubtitle,
                                      style: theme.typography.small.copyWith(
                                        color: theme.colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isMobile && totalGhosts > 0) ...[
                                const SizedBox(width: 14),
                                PrimaryButton(
                                  onPressed: () => context.push(
                                    '/grammar/ghost_review/practice?mode=${GrammarPracticeMode.ghost.value}',
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.flame, size: 16),
                                      const SizedBox(width: 6),
                                      Text(l10n.grammarClearGhostsButton(totalGhosts)),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );

                          if (isMobile && totalGhosts > 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleWidget,
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: PrimaryButton(
                                    onPressed: () => context.push(
                                      '/grammar/ghost_review/practice?mode=${GrammarPracticeMode.ghost.value}',
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(LucideIcons.flame, size: 16),
                                        const SizedBox(width: 6),
                                        Text(l10n.grammarClearGhostsButton(totalGhosts)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return titleWidget;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Quick Stats Metrics
                      LayoutBuilder(
                        builder: (context, statsConstraints) {
                          final isCompact = statsConstraints.maxWidth < 600;
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
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Search & Level Filters
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              features: const [
                                InputFeature.leading(
                                  Icon(LucideIcons.search, size: 16),
                                ),
                              ],
                              placeholder: Text(l10n.grammarSearchPlaceholder),
                              onChanged: (val) => searchQuery.value = val,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Level Filter Buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              context,
                              label: l10n.grammarFilterAll(GrammarConstants.totalUnits),
                              isSelected: selectedLevel.value == null,
                              onTap: () => selectedLevel.value = null,
                            ),
                            ...GrammarLevel.values.map((lvl) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _buildFilterChip(
                                  context,
                                  label: lvl.getLocalizedName(l10n),
                                  isSelected: selectedLevel.value == lvl,
                                  onTap: () => selectedLevel.value = lvl,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Units Grid / List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
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
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required m.Color color,
    bool isCompact = false,
  }) {
    final theme = Theme.of(context);
    if (isCompact) {
      return Card(
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
      );
    }

    return Card(
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badges & Tags
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      levelText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      unit.category.code.toUpperCase(),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (summary.ghostCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary.ghostCount} Ghost',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  if (summary.dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${summary.dueCount} Due',
                        style: const TextStyle(
                          fontSize: 11,
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
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Mastery Progress Bar
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: summary.masteryPercentage / 100.0,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.grammarMasteryPercentage(summary.masteryPercentage.toStringAsFixed(0)),
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: summary.isMastered ? Colors.green : theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              LayoutBuilder(
                builder: (context, cardConstraints) {
                  final isCompactCard = cardConstraints.maxWidth < 450;
                  final progressWidget = Text(
                    l10n.grammarCompletedProgress(summary.completedCount, GrammarConstants.exercisesPerUnit),
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  );

                  final theoryButton = OutlineButton(
                    onPressed: () => context.push('/grammar/${unit.unitId}/theory'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.bookOpen, size: 14),
                        const SizedBox(width: 6),
                        Text(l10n.grammarTheoryButton),
                      ],
                    ),
                  );

                  final practiceButton = PrimaryButton(
                    onPressed: () => context.push('/grammar/${unit.unitId}/practice'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.play, size: 14),
                        const SizedBox(width: 6),
                        Text(l10n.grammarPracticeButton),
                      ],
                    ),
                  );

                  if (isCompactCard) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        progressWidget,
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: theoryButton),
                            const SizedBox(width: 8),
                            Expanded(child: practiceButton),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      progressWidget,
                      const Spacer(),
                      theoryButton,
                      const SizedBox(width: 8),
                      practiceButton,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
