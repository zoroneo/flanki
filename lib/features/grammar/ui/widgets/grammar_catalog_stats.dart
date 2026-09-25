import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../models/grammar_models.dart';

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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = context.colors;

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
                  colors: colors,
                  icon: LucideIcons.layers,
                  iconColor: colors.info,
                  value: '${GrammarConstants.totalUnits}',
                  label: l10n.grammarMetricTotalUnits,
                ),
              ),
              _buildDivider(theme),
              Expanded(
                child: _buildCompactColumn(
                  theme: theme,
                  colors: colors,
                  icon: LucideIcons.circleCheck,
                  iconColor: colors.success,
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
                    colors: colors,
                    icon: LucideIcons.shieldAlert,
                    iconColor: (totalGhosts > 0 || totalDues > 0)
                        ? colors.error
                        : colors.success,
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
            color: colors.info,
            isCompact: isCompact,
          ),
        ),
        AppGaps.h12,
        Expanded(
          child: GrammarMetricCard(
            label: l10n.grammarMetricCompletedExercises,
            value: '$totalCompleted / ${GrammarConstants.totalExercises}',
            icon: LucideIcons.circleCheck,
            color: colors.success,
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
                ? colors.error
                : colors.success,
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
      width: AppDimensions.hairline,
      height: AppDimensions.statDividerHeight,
      margin: AppEdgeInsets.h4,
      color: theme.colorScheme.border.withValues(alpha: 0.6),
    );
  }

  Widget _buildCompactColumn({
    required ThemeData theme,
    required AppColorsExtension colors,
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
            Icon(icon, size: AppIconSize.statIcon, color: iconColor),
            AppGaps.h4,
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypography.navPlus,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: isAlert ? colors.error : theme.colorScheme.foreground,
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
            fontSize: AppTypography.caption,
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
                      fontSize: AppTypography.caption,
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
