import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../../core/services/cloud_storage_stats_service.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class StorageBreakdownGrid extends StatelessWidget {
  final StorageStatsModel? stats;
  final AppLocalizations l10n;

  const StorageBreakdownGrid({
    super.key,
    required this.stats,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        final cardCount = stats?.localCardCount ?? 0;
        final dbSize = StorageStatsModel.formatBytes(
          stats?.localDatabaseBytes ?? 0,
        );
        final mediaCount = stats?.localMediaCount ?? 0;
        final mediaSize = StorageStatsModel.formatBytes(
          stats?.localMediaBytes ?? 0,
        );
        final backupCount = stats?.cloudBackupCount ?? 0;
        final backupSize = StorageStatsModel.formatBytes(
          stats?.cloudBackupBytes ?? 0,
        );
        final totalLocal = StorageStatsModel.formatBytes(
          stats?.totalLocalBytes ?? 0,
        );

        final items = [
          _statPill(
            theme,
            LucideIcons.layers,
            l10n.databaseStorage,
            '$cardCount cards ($dbSize)',
          ),
          _statPill(
            theme,
            LucideIcons.music,
            l10n.mediaStorage,
            '$mediaCount files ($mediaSize)',
          ),
          _statPill(
            theme,
            LucideIcons.cloud,
            l10n.backupStorage,
            '$backupCount files ($backupSize)',
          ),
          _statPill(
            theme,
            LucideIcons.hardDrive,
            l10n.localStorageUsed,
            totalLocal,
          ),
        ];

        if (isWide) {
          return Row(
            children: items
                .map(
                  (w) => Expanded(
                    child: Padding(padding: AppEdgeInsets.h4, child: w),
                  ),
                )
                .toList(),
          );
        }
        return Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) AppGaps.v6,
              items[i],
            ],
          ],
        );
      },
    );
  }

  Widget _statPill(ThemeData theme, IconData icon, String title, String value) {
    return Container(
      padding: AppEdgeInsets.h8v4,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.xs,
            color: theme.colorScheme.mutedForeground,
          ),
          AppGaps.h6,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
