import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../../core/services/cloud_backup_service.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../sync/providers/cloud_backup_notifier.dart';

class CloudBackupItemRow extends StatelessWidget {
  final CloudBackupMetadata backup;
  final CloudBackupNotifier notifier;
  final CloudBackupState backupState;
  final AppLocalizations l10n;

  const CloudBackupItemRow({
    super.key,
    required this.backup,
    required this.notifier,
    required this.backupState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            onPressed: () => _confirmRestore(context),
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

  Future<void> _confirmRestore(BuildContext context) async {
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
      final ok = await notifier.restoreFromCloud(backup.path);
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
}
