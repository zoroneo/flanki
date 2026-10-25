import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/cloud_backup_notifier.dart';
import 'backup/cloud_backup_action_buttons.dart';
import 'backup/cloud_backup_item_row.dart';
import 'backup/storage_breakdown_grid.dart';

/// Settings card displaying storage usage, cloud backup snapshots, and selective sync.
/// Optimizes rebuild scope: header is static, while stats, actions, and snapshots
/// are isolated via dedicated fine-grained consumers.
class CloudBackupCard extends StatelessWidget {
  const CloudBackupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Static)
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

          // Storage Breakdown Stats (Isolated)
          Text(
            l10n.storageStatsTitle,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.v8,
          Consumer(
            builder: (context, ref, _) {
              final stats = ref.watch(
                cloudBackupNotifierProvider.select((s) => s.stats),
              );
              return StorageBreakdownGrid(stats: stats, l10n: l10n);
            },
          ),

          AppGaps.v16,

          // Backup Actions (Isolated to upload/download/quota progress)
          Consumer(
            builder: (context, ref, _) {
              final backupState = ref.watch(cloudBackupNotifierProvider);
              final backupNotifier = ref.read(
                cloudBackupNotifierProvider.notifier,
              );
              return CloudBackupActionButtons(
                notifier: backupNotifier,
                backupState: backupState,
                l10n: l10n,
              );
            },
          ),

          // Cloud Snapshots List (Isolated to backups list changes)
          Consumer(
            builder: (context, ref, _) {
              final backups = ref.watch(
                cloudBackupNotifierProvider.select((s) => s.backups),
              );
              if (backups.isEmpty) return const SizedBox.shrink();

              final backupNotifier = ref.read(
                cloudBackupNotifierProvider.notifier,
              );
              final backupState = ref.read(cloudBackupNotifierProvider);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  ...backups.map(
                    (backup) => CloudBackupItemRow(
                      backup: backup,
                      notifier: backupNotifier,
                      backupState: backupState,
                      l10n: l10n,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
