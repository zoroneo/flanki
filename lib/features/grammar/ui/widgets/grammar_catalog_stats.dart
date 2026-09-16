import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../models/grammar_models.dart';
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
    final theme = Theme.of(context);

    if (isCompact) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smPlus,
            vertical: AppSpacing.smPlus,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCompactColumn(
                  theme: theme,
                  icon: LucideIcons.layers,
                  iconColor: m.Colors.blue,
                  value: '${GrammarConstants.totalUnits}',
                  label: l10n.grammarMetricTotalUnits,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildCompactColumn(
                  theme: theme,
                  icon: LucideIcons.circleCheck,
                  iconColor: m.Colors.green,
                  value: '$totalCompleted / ${GrammarConstants.totalExercises}',
                  label: l10n.grammarMetricCompletedExercises,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: totalGhosts > 0
                      ? () => context.push(
                          AppRoutes.grammarPractice(
                            'ghost_review',
                            mode: GrammarPracticeMode.ghost.value,
                          ),
                        )
                      : null,
                  child: _buildCompactColumn(
                    theme: theme,
                    icon: LucideIcons.shieldAlert,
                    iconColor: (totalGhosts > 0 || totalDues > 0)
                        ? m.Colors.red
                        : m.Colors.green,
                    value: '$totalDues / $totalGhosts',
                    label: l10n.grammarMetricDueGhosts,
                    isAlert: totalGhosts > 0 || totalDues > 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        AppGaps.h12,
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricCompletedExercises,
            value: '$totalCompleted / ${GrammarConstants.totalExercises}',
            icon: LucideIcons.circleCheck,
            color: m.Colors.green,
            isCompact: isCompact,
          ),
        ),
        AppGaps.h12,
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricDueGhosts,
            value: '$totalDues / $totalGhosts',
            icon: LucideIcons.shieldAlert,
            color: (totalGhosts > 0 || totalDues > 0)
                ? m.Colors.red
                : m.Colors.green,
            isCompact: isCompact,
            onTap: totalGhosts > 0
                ? () => context.push(
                    AppRoutes.grammarPractice(
                      'ghost_review',
                      mode: GrammarPracticeMode.ghost.value,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: theme.colorScheme.border.withValues(alpha: 0.6),
    );
  }

  Widget _buildCompactColumn({
    required ThemeData theme,
    required IconData icon,
    required m.Color iconColor,
    required String value,
    required String label,
    bool isAlert = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: iconColor),
            AppGaps.h4,
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: isAlert ? m.Colors.red : theme.colorScheme.foreground,
                ),
              ),
            ),
          ],
        ),
        AppGaps.v2,
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.mutedForeground,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: AppEdgeInsets.all8,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Icon(icon, size: AppIconSize.sm, color: color),
                  ),
                  AppGaps.v8,
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppGaps.v2,
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
              padding: AppEdgeInsets.h16v12,
              child: Row(
                children: [
                  Container(
                    padding: AppEdgeInsets.all8,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: Icon(icon, size: AppIconSize.md, color: color),
                  ),
                  AppGaps.h12,
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
}
