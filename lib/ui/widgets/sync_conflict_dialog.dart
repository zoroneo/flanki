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
  final bool isBottomSheet;

  const SyncConflictDialog({
    super.key,
    this.localLastSync,
    this.serverMod,
    this.isBottomSheet = false,
  });

  /// Displays the sync conflict resolution UI.
  /// On mobile devices (width < 600), renders as an adaptive bottom sheet.
  /// On desktop/tablet, renders as a centered modal dialog.
  static Future<SyncConflictChoice?> show(
    BuildContext context, {
    DateTime? localLastSync,
    DateTime? serverMod,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return m.showModalBottomSheet<SyncConflictChoice>(
        context: context,
        useRootNavigator: true,
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        builder: (ctx) => m.Material(
          type: m.MaterialType.transparency,
          child: SyncConflictDialog(
            localLastSync: localLastSync,
            serverMod: serverMod,
            isBottomSheet: true,
          ),
        ),
      );
    }

    return m.showDialog<SyncConflictChoice>(
      context: context,
      builder: (context) => m.Dialog(
        backgroundColor: m.Colors.transparent,
        insetPadding: const m.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SyncConflictDialog(
            localLastSync: localLastSync,
            serverMod: serverMod,
            isBottomSheet: false,
          ),
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

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isBottomSheet)
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.mutedForeground.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.destructive.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.cloudAlert,
                size: 20,
                color: theme.colorScheme.destructive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.syncConflictTitle,
                style: theme.typography.h4.copyWith(fontSize: 16),
              ),
            ),
            IconButton.ghost(
              icon: const Icon(LucideIcons.x, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.syncConflictDesc,
          style: theme.typography.small.copyWith(
            color: theme.colorScheme.mutedForeground,
            fontSize: 12.5,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.history,
                    size: 13,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.previousSyncLabel,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(context, localLastSync),
                    style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    LucideIcons.cloud,
                    size: 13,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.ankiWebUpdateLabel,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(context, serverMod),
                    style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.selectVersionToKeep,
          style: theme.typography.semiBold.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        _buildOptionCard(
          context: context,
          theme: theme,
          icon: LucideIcons.cloudUpload,
          iconColor: theme.colorScheme.primary,
          title: l10n.uploadToCloudTitle,
          desc: l10n.uploadToCloudDesc,
          onTap: () => Navigator.of(context).pop(SyncConflictChoice.upload),
        ),
        const SizedBox(height: 8),
        _buildOptionCard(
          context: context,
          theme: theme,
          icon: LucideIcons.cloudDownload,
          iconColor: theme.colorScheme.primary,
          title: l10n.downloadFromCloudTitle,
          desc: l10n.downloadFromCloudDesc,
          onTap: () => Navigator.of(context).pop(SyncConflictChoice.download),
        ),
        const SizedBox(height: 14),
        OutlineButton(
          alignment: Alignment.center,
          onPressed: () => Navigator.of(context).pop(),
          child: Center(
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );

    if (isBottomSheet) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.colorScheme.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: content,
          ),
        ),
      );
    }

    return ModalContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return m.Material(
      color: theme.colorScheme.card,
      borderRadius: BorderRadius.circular(10),
      child: m.InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.semiBold.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevronRight,
                size: 15,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
