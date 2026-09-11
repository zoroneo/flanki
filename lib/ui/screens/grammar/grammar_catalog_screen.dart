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
import 'widgets/grammar_catalog_stats.dart';
import 'widgets/grammar_level_filters.dart';
import 'widgets/grammar_unit_card.dart';

class GrammarCatalogScreen extends HookConsumerWidget {
  const GrammarCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final grammarAsync = ref.watch(grammarUnitsProvider);
    final repo = ref.watch(grammarRepositoryProvider);

    final selectedLevel = useState<GrammarLevel?>(null);
    final searchQuery = useState<String>('');

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
            _buildAppBar(context, l10n, totalGhosts, isMobile),
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
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: GrammarCatalogStats(
                                isCompact: isMobile,
                                totalCompleted: totalCompleted,
                                totalDues: totalDues,
                                totalGhosts: totalGhosts,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: _buildSearchField(l10n, searchQuery),
                            ),
                            const SizedBox(height: 14),
                            if (isMobile)
                              GrammarLevelFilters(
                                selectedLevel: selectedLevel,
                                isMobile: true,
                                horizontalPadding: horizontalPadding,
                              )
                            else
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: GrammarLevelFilters(
                                  selectedLevel: selectedLevel,
                                  isMobile: false,
                                  horizontalPadding: horizontalPadding,
                                ),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (filteredUnits.isEmpty)
                        _buildEmptyState(theme, l10n)
                      else
                        _buildUnitsGrid(
                          filteredUnits: filteredUnits,
                          repo: repo,
                          horizontalPadding: horizontalPadding,
                          crossAxisCount: crossAxisCount,
                          spacing: spacing,
                          mainAxisExtent: mainAxisExtent,
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

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n, int totalGhosts, bool isMobile) {
    return AppBar(
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
                  ? l10n.grammarGhostsCount(totalGhosts)
                  : l10n.grammarClearGhostsButton(totalGhosts),
              maxLines: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(AppLocalizations l10n, ValueNotifier<String> searchQuery) {
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

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return SliverFillRemaining(
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
              style: TextStyle(color: theme.colorScheme.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitsGrid({
    required List<GrammarUnit> filteredUnits,
    required GrammarRepository repo,
    required double horizontalPadding,
    required int crossAxisCount,
    required double spacing,
    required double mainAxisExtent,
  }) {
    return SliverPadding(
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
            return GrammarUnitCard(unit: unit, summary: summary);
          },
          childCount: filteredUnits.length,
        ),
      ),
    );
  }
}
