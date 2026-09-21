import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../../core/theme/app_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../sync/providers/cloud_backup_notifier.dart';
import '../../../../sync/ui/widgets/selective_sync_sheet.dart';

class CloudBackupActionButtons extends StatelessWidget {
  final CloudBackupNotifier notifier;
  final CloudBackupState backupState;
  final AppLocalizations l10n;

  const CloudBackupActionButtons({
    super.key,
    required this.notifier,
    required this.backupState,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        Button.primary(
          onPressed: backupState.isLoading
              ? null
              : () async {
                  final ok = await notifier.createCloudBackup();
                  if (context.mounted) {
                    showToast(
                      context: context,
                      builder: (context, overlay) => SurfaceCard(
                        child: Basic(
                          title: Text(
                            ok
                                ? l10n.backupSuccess
                                : (backupState.error != null
                                      ? l10n.backupFailed(backupState.error!)
                                      : l10n.syncFailed),
                          ),
                          leading: Icon(
                            ok ? LucideIcons.check : LucideIcons.circleAlert,
                            color: ok ? AppColors.success : AppColors.error,
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
          onPressed: () => _handleExportLocal(context),
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
          onPressed: () => _handleImportLocal(context),
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
    );
  }

  Future<void> _handleExportLocal(BuildContext context) async {
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

  Future<void> _handleImportLocal(BuildContext context) async {
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
