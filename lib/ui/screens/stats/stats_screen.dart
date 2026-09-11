import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/stats_notifier.dart';

class StatsScreen extends HookConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final stats = ref.watch(statsNotifierProvider);
    final studySettings = ref.watch(studySettingsProvider);

    useEffect(() {
      Future.microtask(
        () => ref.read(statsNotifierProvider.notifier).refresh(),
      );
      return null;
    }, const []);

    final retentionPercentStr =
        '${(stats.retentionRate * 100).toStringAsFixed(1)}%';
    final isTargetReached =
        stats.retentionRate >= studySettings.desiredRetention;
    final targetLabel = l10n.targetSuffix(
      '${(studySettings.desiredRetention * 100).toInt()}%',
    );

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final horizontalPadding = getValueForScreenType<double>(
          context: context,
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        );

        return Scaffold(
          headers: [AppBar(title: Text(l10n.statsTitle))],
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16.0),
                children: [
                  // Retention & FSRS Overview Card
                  Card(
                    filled: true,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.retentionRate,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                            if (stats.totalReviews > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (isTargetReached
                                          ? m.Colors.green
                                          : m.Colors.orange)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isTargetReached
                                      ? l10n.targetReached
                                      : l10n.targetNotReached,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isTargetReached
                                        ? m.Colors.green
                                        : m.Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              retentionPercentStr,
                              style: theme.typography.h1.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              targetLabel,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Progress(progress: stats.retentionRate),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3 Metric Grid
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: l10n.reviewedToday,
                          value: '${stats.reviewedToday}',
                          subtitle: l10n.reviewedDiff,
                          icon: LucideIcons.checkCheck,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: l10n.studyTime,
                          value: l10n.studyMinutesUnit(stats.studyTimeMinutes),
                          subtitle: l10n.studyTimePerCard,
                          icon: LucideIcons.timer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Study Activity Heatmap (GitHub / Anki style)
                  Card(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.studyHistory,
                                style: theme.typography.semiBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.streakDays(stats.streakDays),
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _HeatmapGrid(theme: theme, levels: stats.heatmapLevels),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.less,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _HeatmapDot(level: 0, theme: theme),
                            const SizedBox(width: 4),
                            _HeatmapDot(level: 1, theme: theme),
                            const SizedBox(width: 4),
                            _HeatmapDot(level: 2, theme: theme),
                            const SizedBox(width: 4),
                            _HeatmapDot(level: 3, theme: theme),
                            const SizedBox(width: 6),
                            Text(
                              l10n.more,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 110,
                  ), // Safe scroll clearance for bottom navigation
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final ThemeData theme;
  final List<List<int>> levels;

  const _HeatmapGrid({required this.theme, required this.levels});

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: levels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (context, w) {
          final week = levels[w];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int d = 0; d < week.length; d++) ...[
                if (d > 0) const SizedBox(height: 5),
                _HeatmapDot(level: week[d], theme: theme, size: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeatmapDot extends StatelessWidget {
  final int level;
  final ThemeData theme;
  final double size;

  const _HeatmapDot({required this.level, required this.theme, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final colors = [
      theme.colorScheme.muted,
      isDark ? m.Colors.green.shade900 : m.Colors.green.shade200,
      isDark ? m.Colors.green.shade600 : m.Colors.green.shade500,
      isDark ? m.Colors.green.shade400 : m.Colors.green.shade800,
    ];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[level.clamp(0, 3)],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
