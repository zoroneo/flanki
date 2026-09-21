import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class StatsMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const StatsMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              Icon(
                icon,
                size: AppIconSize.sm,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          AppGaps.v8,
          Text(
            value,
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGaps.v4,
          Text(
            subtitle,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
