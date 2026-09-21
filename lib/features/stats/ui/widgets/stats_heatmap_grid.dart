import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';

class StatsHeatmapGrid extends StatelessWidget {
  final List<List<int>> levels;
  final int streakDays;
  final AppLocalizations l10n;

  const StatsHeatmapGrid({
    super.key,
    required this.levels,
    required this.streakDays,
    required this.l10n,
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
              Expanded(
                child: Text(
                  l10n.studyHistory,
                  style: theme.typography.semiBold,
                ),
              ),
              AppGaps.h8,
              Text(
                l10n.streakDays(streakDays),
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
          AppGaps.v16,
          _buildHeatmapLayout(theme),
          AppGaps.v12,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.less,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              AppGaps.h6,
              for (int lvl = 0; lvl <= 4; lvl++) ...[
                Container(
                  width: AppDimensions.legendColorDotSize,
                  height: AppDimensions.legendColorDotSize,
                  decoration: BoxDecoration(
                    color: _levelColor(theme, lvl),
                    borderRadius: AppRadius.borderXs,
                  ),
                ),
                AppGaps.h4,
              ],
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
    );
  }

  Widget _buildHeatmapLayout(ThemeData theme) {
    const rows = 7;
    final cols = levels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const cellSpacing = 3.0;
        final cellSize = cols > 0
            ? ((availableWidth - (cols - 1) * cellSpacing) / cols).clamp(
                6.0,
                14.0,
              )
            : 10.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int col = 0; col < cols; col++) ...[
                if (col > 0) const SizedBox(width: cellSpacing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int row = 0; row < rows; row++) ...[
                      if (row > 0) const SizedBox(height: cellSpacing),
                      _buildCell(theme, col, row, cellSize),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCell(ThemeData theme, int col, int row, double size) {
    final colDays = levels[col];
    final level = row < colDays.length ? colDays[row] : 0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _levelColor(theme, level),
        borderRadius: AppRadius.borderXs,
      ),
    );
  }

  Color _levelColor(ThemeData theme, int level) {
    final primary = theme.colorScheme.primary;
    switch (level) {
      case 1:
        return primary.withValues(alpha: 0.25);
      case 2:
        return primary.withValues(alpha: 0.50);
      case 3:
        return primary.withValues(alpha: 0.75);
      case 4:
        return primary;
      default:
        return theme.colorScheme.muted.withValues(alpha: 0.3);
    }
  }
}
