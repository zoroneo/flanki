import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';

class DeckStatsBar extends StatelessWidget {
  final int totalDue;
  final int totalNew;
  final int streakDays;
  final double desiredRetention;
  final VoidCallback? onTap;

  const DeckStatsBar({
    super.key,
    required this.totalDue,
    required this.totalNew,
    required this.streakDays,
    required this.desiredRetention,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => context.go(AppRoutes.stats),
      child: Card(
        filled: true,
        padding: AppEdgeInsets.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStreakHeader(context, theme, l10n),
            AppGaps.v16,
            _buildCountBoxes(theme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHeader(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.flame,
              color: context.colors.streakFlame,
              size: AppIconSize.lg,
            ),
            AppGaps.h8,
            Text(
              l10n.streakDaysBadge(streakDays),
              style: theme.typography.h4.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.targetRetentionBadge('${(desiredRetention * 100).toInt()}%'),
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.foreground.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            AppGaps.h4,
            Icon(
              LucideIcons.chevronRight,
              size: AppIconSize.sm,
              color: theme.colorScheme.mutedForeground,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountBoxes(ThemeData theme, dynamic l10n) {
    return Row(
      children: [
        Expanded(
          child: StatMiniBox(
            label: l10n.dueCards,
            value: '$totalDue',
            color: totalDue > 0
                ? theme.colorScheme.destructive
                : theme.colorScheme.foreground,
            icon: LucideIcons.clock,
          ),
        ),
        AppGaps.h12,
        Expanded(
          child: StatMiniBox(
            label: l10n.newCards,
            value: '$totalNew',
            color: theme.colorScheme.primary,
            icon: LucideIcons.sparkles,
          ),
        ),
      ],
    );
  }
}

class StatMiniBox extends StatelessWidget {
  final String label;
  final String value;
  final m.Color color;
  final IconData icon;

  const StatMiniBox({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.h16v12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.md, color: color),
          AppGaps.h12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: context.textStyles.largeBold.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: AppTypography.lineHeightBadge,
                ),
              ),
              AppGaps.v2,
              Text(
                label,
                style: context.textStyles.sub.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
