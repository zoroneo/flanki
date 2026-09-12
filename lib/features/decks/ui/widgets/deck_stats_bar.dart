import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';

class DeckStatsBar extends StatelessWidget {
  final int totalDue;
  final int totalNew;
  final int streakDays;
  final double desiredRetention;

  const DeckStatsBar({
    super.key,
    required this.totalDue,
    required this.totalNew,
    required this.streakDays,
    required this.desiredRetention,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      filled: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStreakHeader(theme, l10n),
          const SizedBox(height: 16),
          _buildCountBoxes(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildStreakHeader(ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.flame, color: m.Colors.deepOrange, size: 22),
            const SizedBox(width: 6),
            Text(
              l10n.streakDaysBadge(streakDays),
              style: theme.typography.h4.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Text(
          l10n.targetRetentionBadge('${(desiredRetention * 100).toInt()}%'),
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.foreground.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
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
        const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
