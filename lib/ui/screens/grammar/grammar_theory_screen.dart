import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/models/grammar/grammar_models.dart';
import '../../../core/services/grammar_service.dart';
import '../../../l10n/generated/app_localizations.dart';

class GrammarTheoryScreen extends ConsumerWidget {
  final String unitId;

  const GrammarTheoryScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final grammarAsync = ref.watch(grammarUnitsProvider);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft, size: 20),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(
            l10n.grammarTheoryScreenTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: [
            if (isMobile)
              IconButton.primary(
                icon: const Icon(LucideIcons.play, size: 16),
                onPressed: () => context.push('/grammar/$unitId/practice'),
              )
            else
              PrimaryButton(
                onPressed: () => context.push('/grammar/$unitId/practice'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.grammarPracticeCountButton(GrammarConstants.exercisesPerUnit)),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.play, size: 14),
                  ],
                ),
              ),
          ],
        ),
      ],
      child: grammarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.grammarErrorLoadUnit(err.toString()))),
        data: (units) {
          final unit = units.cast<GrammarUnit?>().firstWhere(
                (u) => u?.unitId == unitId,
                orElse: () => null,
              );

          if (unit == null) {
            return Center(child: Text(l10n.grammarUnitNotFound));
          }

          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 32 + bottomInset),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Unit Header Banner
                    _buildHeaderBanner(context, unit),
                    const SizedBox(height: 24),

                    // 1. Core Concept Section
                    _buildSectionCard(
                      context,
                      icon: LucideIcons.lightbulb,
                      iconColor: Colors.amber,
                      title: l10n.grammarCoreConceptTitle,
                      content: unit.coreConcept,
                    ),
                    const SizedBox(height: 20),

                    // 2. Formulas Section
                    if (unit.formulas.isNotEmpty) ...[
                      _buildFormulasSection(context, unit.formulas),
                      const SizedBox(height: 20),
                    ],

                    // 3. Common Traps Section
                    if (unit.commonTraps.isNotEmpty) ...[
                      _buildCommonTrapsSection(context, unit.commonTraps),
                      const SizedBox(height: 20),
                    ],

                    // 4. Extra Guides Section (if any)
                    if (unit.extraGuides.isNotEmpty) ...[
                      _buildExtraGuidesSection(context, unit.extraGuides),
                      const SizedBox(height: 20),
                    ],

                    // Bottom Action Button
                    const SizedBox(height: 12),
                    PrimaryButton(
                      size: ButtonSize.large,
                      onPressed: () => context.push('/grammar/$unitId/practice'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.play, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.grammarStartPracticeNowButton(GrammarConstants.exercisesPerUnit)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, GrammarUnit unit) {
    final theme = Theme.of(context);
    final levelLabel = unit.level.displayName;
    final levelColor = unit.level.color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unit.category.code.toUpperCase(),
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              unit.title,
              style: theme.typography.h3.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required m.Color iconColor,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              content,
              style: theme.typography.base.copyWith(
                height: 1.6,
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulasSection(BuildContext context, Map<String, String> formulas) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.sigma, size: 20, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  l10n.grammarFormulasTitle,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...formulas.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.value,
                      style: theme.typography.base.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonTrapsSection(BuildContext context, List<GrammarTrap> traps) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.triangleAlert, size: 20, color: Colors.orange),
                const SizedBox(width: 10),
                Text(
                  l10n.grammarCommonTrapsTitle,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...traps.map((trap) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trap.trap,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Wrong
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('❌ ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              trap.exampleWrong,
                              style: theme.typography.small.copyWith(
                                color: Colors.red,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Right
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✅ ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              trap.exampleRight,
                              style: theme.typography.small.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(LucideIcons.info, size: 15, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trap.note,
                            style: theme.typography.small.copyWith(
                              color: theme.colorScheme.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraGuidesSection(BuildContext context, Map<String, String> extraGuides) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.bookOpen, size: 20, color: Colors.purple),
                const SizedBox(width: 10),
                Text(
                  l10n.grammarExtraGuidesTitle,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...extraGuides.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value,
                      style: theme.typography.small.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
