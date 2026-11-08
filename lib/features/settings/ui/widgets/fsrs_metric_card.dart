import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Reusable metric card displaying before/after comparison with percentage improvement.
class FsrsMetricCard extends StatelessWidget {
  final String title;
  final double baseline;
  final double optimized;
  final double gainPercent;
  final String defaultLabel;

  const FsrsMetricCard({
    super.key,
    required this.title,
    required this.baseline,
    required this.optimized,
    required this.gainPercent,
    required this.defaultLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: AppEdgeInsets.all12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.v6,
          Row(
            children: [
              Text(
                optimized.toStringAsFixed(4),
                style: theme.typography.large.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppGaps.h6,
              Text(
                '(${gainPercent >= 0 ? '-' : '+'}${gainPercent.abs().toStringAsFixed(1)}%)',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: gainPercent >= 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.destructive,
                ),
              ),
            ],
          ),
          AppGaps.v2,
          Text(
            '$defaultLabel: ${baseline.toStringAsFixed(4)}',
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
