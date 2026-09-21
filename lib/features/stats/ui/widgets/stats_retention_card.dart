import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/stats_state.dart';

class StatsRetentionCard extends StatelessWidget {
  final StatsData stats;
  final double desiredRetention;
  final AppLocalizations l10n;

  const StatsRetentionCard({
    super.key,
    required this.stats,
    required this.desiredRetention,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final retentionPercentStr =
        '${(stats.retentionRate * 100).toStringAsFixed(1)}%';
    final isTargetReached = stats.retentionRate >= desiredRetention;
    final targetLabel = l10n.targetSuffix(
      '${(desiredRetention * 100).toInt()}%',
    );

    return Card(
      filled: true,
      padding: AppEdgeInsets.all20,
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
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isTargetReached
                                ? context.colors.success
                                : context.colors.warning)
                            .withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    isTargetReached
                        ? l10n.targetReached
                        : l10n.targetNotReached,
                    style: context.textStyles.captionBold.copyWith(
                      color: isTargetReached
                          ? context.colors.success
                          : context.colors.warning,
                    ),
                  ),
                ),
            ],
          ),
          AppGaps.v12,
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
              AppGaps.h8,
              Text(
                targetLabel,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          AppGaps.v16,
          Progress(progress: stats.retentionRate),
        ],
      ),
    );
  }
}
