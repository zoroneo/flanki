import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/services/cloud_backup_service.dart';
import '../../../../core/services/cloud_storage_stats_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../decks/ui/widgets/selective_sync_sheet.dart';
import '../../../sync/providers/cloud_backup_notifier.dart';

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
          _buildStatsGrid(theme, l10n, stats),

          AppGaps.v16,

          // Backup Actions
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Button.primary(
                onPressed: backupState.isLoading
                    ? null
                    : () async {
                        final ok = await backupNotifier.createCloudBackup();
                        if (context.mounted) {
                          showToast(
                            context: context,
                            builder: (context, overlay) => SurfaceCard(
                              child: Basic(
                                title: Text(
                                  ok
                                      ? l10n.backupSuccess
                                      : (backupState.error != null
                                            ? l10n.backupFailed(
                                                backupState.error!,
                                              )
                                            : l10n.syncFailed),
                                ),
                                leading: Icon(
                                  ok
                                      ? LucideIcons.check
                                      : LucideIcons.circleAlert,
                                  color: ok
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (backupState.isLoading) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      AppGaps.h8,
                    ] else ...[
                      const Icon(LucideIcons.cloudUpload, size: AppIconSize.sm),
                      AppGaps.h8,
                    ],
                    Text(l10n.createBackupNow),
                  ],
                ),
              ),
              Button.outline(
                onPressed: () => SelectiveSyncSheet.show(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.cloudCog, size: AppIconSize.sm),
                    AppGaps.h8,
                    Text(l10n.manageDeckSync),
                  ],
                ),
              ),
              Button.ghost(
                onPressed: () =>
                    _handleExportLocal(context, backupNotifier, l10n),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.download, size: AppIconSize.sm),
                    AppGaps.h8,
                    Text(l10n.exportLocalBackup),
                  ],
                ),
              ),
              Button.ghost(
                onPressed: () => _handleImportLocal(
                  context,
                  backupNotifier,
                  backupState,
                  l10n,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.upload, size: AppIconSize.sm),
                    AppGaps.h8,
                    Text(l10n.importLocalBackup),
                  ],
                ),
              ),
            ],
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
              (backup) => _buildBackupRow(
                context,
                theme,
                l10n,
                backup,
                backupNotifier,
                backupState,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    ThemeData theme,
    AppLocalizations l10n,
    StorageStatsModel? stats,
  ) {
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

  Widget _buildBackupRow(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    CloudBackupMetadata backup,
    CloudBackupNotifier notifier,
    CloudBackupState backupState,
  ) {
    return Container(
      padding: AppEdgeInsets.all8,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.archive, size: AppIconSize.xs),
          AppGaps.h8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  backup.formattedSize,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Button.ghost(
            onPressed: () => _confirmRestore(
              context,
              notifier,
              backupState,
              backup.path,
              l10n,
            ),
            child: Text(l10n.restoreBackup),
          ),
          IconButton.ghost(
            icon: const Icon(LucideIcons.trash2, size: AppIconSize.xs),
            onPressed: () => notifier.deleteCloudBackup(backup.path),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(
    BuildContext context,
    CloudBackupNotifier notifier,
    CloudBackupState backupState,
    String path,
    AppLocalizations l10n,
  ) async {
    final confirmed = await m.showDialog<bool>(
      context: context,
      builder: (context) => m.AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmMessage),
        actions: [
          Button.ghost(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          Button.primary(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.restoreBackup),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final ok = await notifier.restoreFromCloud(path);
      if (context.mounted) {
        final err = backupState.error ?? l10n.unknown;
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: Text(ok ? l10n.restoreSuccess : l10n.restoreFailed(err)),
              leading: Icon(
                ok ? LucideIcons.check : LucideIcons.circleAlert,
                color: ok ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleExportLocal(
    BuildContext context,
    CloudBackupNotifier notifier,
    AppLocalizations l10n,
  ) async {
    final file = await notifier.exportLocalBackup();
    if (context.mounted && file != null) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: Text(l10n.backupSuccess),
            subtitle: Text(file.path),
            leading: const Icon(LucideIcons.check, color: AppColors.success),
          ),
        ),
      );
    }
  }

  Future<void> _handleImportLocal(
    BuildContext context,
    CloudBackupNotifier notifier,
    CloudBackupState backupState,
    AppLocalizations l10n,
  ) async {
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        final ok = await notifier.restoreLocalBackup(File(path));
        if (context.mounted) {
          final err = backupState.error ?? l10n.importApkgInvalidFormat;
          showToast(
            context: context,
            builder: (context, overlay) => SurfaceCard(
              child: Basic(
                title: Text(ok ? l10n.restoreSuccess : l10n.restoreFailed(err)),
                leading: Icon(
                  ok ? LucideIcons.check : LucideIcons.circleAlert,
                  color: ok ? AppColors.success : AppColors.error,
                ),
              ),
            ),
          );
        }
      }
    }
  }
}
