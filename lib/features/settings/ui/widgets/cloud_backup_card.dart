import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/cloud_backup_notifier.dart';
import 'backup/cloud_backup_action_buttons.dart';
import 'backup/cloud_backup_item_row.dart';
import 'backup/storage_breakdown_grid.dart';

/// Settings card displaying storage usage, cloud backup snapshots, and selective sync.
class CloudBackupCard extends ConsumerWidget {
  const CloudBackupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final backupState = ref.watch(cloudBackupNotifierProvider);
    final backupNotifier = ref.read(cloudBackupNotifierProvider.notifier);
    final stats = backupState.stats;

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                LucideIcons.hardDriveDownload,
                size: AppIconSize.md,
                color: theme.colorScheme.primary,
              ),
              AppGaps.h8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cloudBackupTitle,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.cloudBackupSubtitle,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppGaps.v16,
          const Divider(),
          AppGaps.v12,

          // Storage Breakdown Stats
          Text(
            l10n.storageStatsTitle,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.v8,
          StorageBreakdownGrid(stats: stats, l10n: l10n),

          AppGaps.v16,

          // Backup Actions
          CloudBackupActionButtons(
            notifier: backupNotifier,
            backupState: backupState,
            l10n: l10n,
          ),

          // Cloud Snapshots List
          if (backupState.backups.isNotEmpty) ...[
            AppGaps.v16,
            const Divider(),
            AppGaps.v12,
            Text(
              l10n.backupStorage,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            AppGaps.v8,
            ...backupState.backups.map(
              (backup) => CloudBackupItemRow(
                backup: backup,
                notifier: backupNotifier,
                backupState: backupState,
                l10n: l10n,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
