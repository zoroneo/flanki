import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/localization/locale_notifier.dart';

enum SyncConflictChoice {
  upload,
  download,
}

class SyncConflictDialog extends StatelessWidget {
  final DateTime? localLastSync;
  final DateTime? serverMod;

  const SyncConflictDialog({
    super.key,
    this.localLastSync,
    this.serverMod,
  });

  static Future<SyncConflictChoice?> show(
    BuildContext context, {
    DateTime? localLastSync,
    DateTime? serverMod,
  }) {
    return m.showDialog<SyncConflictChoice>(
      context: context,
      builder: (context) => m.Dialog(
        backgroundColor: m.Colors.transparent,
        insetPadding: const m.EdgeInsets.all(16),
        child: SyncConflictDialog(
          localLastSync: localLastSync,
          serverMod: serverMod,
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime? dt) {
    if (dt == null) return context.l10n.unknownTime;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ModalContainer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.cloudAlert,
                  size: 24,
                  color: theme.colorScheme.destructive,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.syncConflictTitle,
                    style: theme.typography.h4,
                  ),
                ),
                IconButton.ghost(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.syncConflictDesc,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.previousSyncLabel,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                      Text(
                        _formatDateTime(context, localLastSync),
                        style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.ankiWebUpdateLabel,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                      Text(
                        _formatDateTime(context, serverMod),
                        style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.selectVersionToKeep,
              style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Option 1: Upload to AnkiWeb
            GestureDetector(
              onTap: () => Navigator.of(context).pop(SyncConflictChoice.upload),
              child: SurfaceCard(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.cloudUpload, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.uploadToCloudTitle,
                              style: theme.typography.semiBold.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.uploadToCloudDesc,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Option 2: Download from AnkiWeb
            GestureDetector(
              onTap: () => Navigator.of(context).pop(SyncConflictChoice.download),
              child: SurfaceCard(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.cloudDownload, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.downloadFromCloudTitle,
                              style: theme.typography.semiBold.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.downloadFromCloudDesc,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
