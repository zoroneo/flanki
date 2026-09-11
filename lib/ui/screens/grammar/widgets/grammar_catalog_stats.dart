import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarCatalogStats extends StatelessWidget {
  final bool isCompact;
  final int totalCompleted;
  final int totalDues;
  final int totalGhosts;

  const GrammarCatalogStats({
    super.key,
    required this.isCompact,
    required this.totalCompleted,
    required this.totalDues,
    required this.totalGhosts,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricTotalUnits,
            value: l10n.grammarUnitsCount(GrammarConstants.totalUnits),
            icon: LucideIcons.layers,
            color: m.Colors.blue,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricCompletedExercises,
            value: '$totalCompleted / ${GrammarConstants.totalExercises}',
            icon: LucideIcons.circleCheck,
            color: m.Colors.green,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricDueGhosts,
            value: '$totalDues / $totalGhosts',
            icon: LucideIcons.shieldAlert,
            color: (totalGhosts > 0 || totalDues > 0) ? m.Colors.red : m.Colors.green,
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
}

class GrammarMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final m.Color color;
  final bool isCompact;
  final VoidCallback? onTap;

  const GrammarMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: theme.typography.small.copyWith(fontWeight: FontWeight.bold),
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
                          style: theme.typography.base.copyWith(fontWeight: FontWeight.bold),
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
}
