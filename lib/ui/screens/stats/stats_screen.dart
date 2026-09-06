import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class StatsScreen extends HookConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Thống Kê & Tiến Độ'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
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
                    Text('TỶ LỆ GHI NHỚ (RETENTION)', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: m.Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Đạt mục tiêu',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: m.Colors.green,
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
                      '88.4%',
                      style: theme.typography.h1.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ 85% mong muốn (FSRS v5)',
                      style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Progress(
                  progress: 0.884,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Metric Grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Đã ôn hôm nay',
                  value: '42',
                  subtitle: '+12 so với hôm qua',
                  icon: m.Icons.task_alt_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Thời gian học',
                  value: '18p',
                  subtitle: '~25.7s mỗi thẻ',
                  icon: m.Icons.timer_outlined,
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
                    Text('Lịch Sử Hoạt Động (Heatmap)', style: theme.typography.semiBold),
                    Text('14 ngày liên tục', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 16),
                _HeatmapGrid(theme: theme),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Ít', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                    const SizedBox(width: 6),
                    _HeatmapDot(level: 0, theme: theme),
                    const SizedBox(width: 4),
                    _HeatmapDot(level: 1, theme: theme),
                    const SizedBox(width: 4),
                    _HeatmapDot(level: 2, theme: theme),
                    const SizedBox(width: 4),
                    _HeatmapDot(level: 3, theme: theme),
                    const SizedBox(width: 6),
                    Text('Nhiều', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final m.IconData icon;

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
          Text(value, style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 10, color: theme.colorScheme.mutedForeground)),
        ],
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final ThemeData theme;

  const _HeatmapGrid({required this.theme});

  @override
  Widget build(BuildContext context) {
    // 5 weeks x 7 days sample grid
    final levels = [
      [0, 1, 2, 3, 2, 3, 1],
      [1, 2, 0, 3, 3, 2, 2],
      [2, 3, 1, 2, 1, 3, 3],
      [3, 2, 3, 1, 2, 2, 3],
      [2, 3, 3, 3, 2, 3, 2],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: levels.map((week) {
        return Column(
          children: week.map((level) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: _HeatmapDot(level: level, theme: theme, size: 14),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _HeatmapDot extends StatelessWidget {
  final int level;
  final ThemeData theme;
  final double size;

  const _HeatmapDot({
    required this.level,
    required this.theme,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      theme.colorScheme.muted,
      m.Colors.green.shade200,
      m.Colors.green.shade500,
      m.Colors.green.shade800,
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
