import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class FsrsOptimizerProgressCard extends StatelessWidget {
  const FsrsOptimizerProgressCard({
    super.key,
    required this.totalReviews,
    required this.minReviews,
    required this.canOptimize,
    required this.readyMessage,
    required this.notReadyMessage,
  });

  final int totalReviews;
  final int minReviews;
  final bool canOptimize;
  final String readyMessage;
  final String notReadyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (totalReviews / minReviews).clamp(0.0, 1.0);

    return SurfaceCard(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                canOptimize ? readyMessage : notReadyMessage,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: canOptimize
                      ? theme.colorScheme.primary
                      : theme.colorScheme.foreground,
                ),
              ),
              Text(
                '$totalReviews / $minReviews',
                style: theme.typography.small.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppGaps.v8,
          m.LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.muted,
            color: canOptimize
                ? theme.colorScheme.primary
                : theme.colorScheme.destructive,
            minHeight: AppDimensions.indicatorDotSize,
          ),
        ],
      ),
    );
  }
}
