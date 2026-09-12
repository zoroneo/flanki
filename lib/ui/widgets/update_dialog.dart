import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/notifiers/locale_notifier.dart';
import '../../core/models/update_info.dart';
import '../../core/notifiers/update_notifier.dart';
import '../../core/services/desktop_update_service.dart';

class UpdateDialog extends ConsumerWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static VoidCallback? onDismissActiveToast;
  static bool isShowing = false;

  static Future<void> show(BuildContext context, UpdateInfo info) async {
    if (isShowing) return;
    isShowing = true;
    onDismissActiveToast?.call();
    try {
      await m.showDialog(
        context: context,
        builder: (context) => m.Dialog(
          backgroundColor: m.Colors.transparent,
          child: UpdateDialog(updateInfo: info),
        ),
      );
    } finally {
      isShowing = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final updateState = ref.watch(updateProvider);
    final notifier = ref.read(updateProvider.notifier);

    return ModalContainer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.circleArrowUp,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.updateAvailable,
                        style: theme.typography.semiBold.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${updateInfo.currentVersion} → v${updateInfo.latestVersion}',
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (updateInfo.releaseNotes != null &&
                updateInfo.releaseNotes!.isNotEmpty) ...[
              Text(
                l10n.updateChangelog,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: theme.colorScheme.border),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      updateInfo.releaseNotes!,
                      style: theme.typography.small,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (updateState.status == UpdateStatus.downloading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.downloadingUpdate, style: theme.typography.xSmall),
                  Text(
                    '${(updateState.downloadProgress * 100).toInt()}%',
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: updateState.downloadProgress),
              const SizedBox(height: 16),
            ],
            if (updateState.status == UpdateStatus.error &&
                updateState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  updateState.errorType == UpdateErrorType.downloadFailed ||
                          updateState.errorMessage ==
                              'Failed to download installer'
                      ? l10n.updateDownloadFailed
                      : updateState.errorMessage!,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.destructive,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final primaryButton = switch (updateState.status) {
                  _ when updateInfo.downloadUrl == null => PrimaryButton(
                    alignment: Alignment.center,
                    onPressed: () {
                      DesktopUpdateService.openUrl(updateInfo.releaseUrl);
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.openDownloadPage),
                  ),
                  UpdateStatus.readyToInstall => PrimaryButton(
                    alignment: Alignment.center,
                    onPressed: () => notifier.installAndRestart(),
                    child: Text(l10n.restartAndInstall),
                  ),
                  UpdateStatus.downloading => PrimaryButton(
                    alignment: Alignment.center,
                    onPressed: null,
                    child: Text(l10n.syncing),
                  ),
                  _ => PrimaryButton(
                    alignment: Alignment.center,
                    onPressed: () => notifier.downloadUpdate(),
                    child: Text(l10n.downloadAndInstall),
                  ),
                };

                final outlineButton = OutlineButton(
                  alignment: Alignment.center,
                  onPressed: () {
                    notifier.dismiss();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.later),
                );

                if (constraints.maxWidth < 340) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      primaryButton,
                      const SizedBox(height: 8),
                      outlineButton,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    outlineButton,
                    const SizedBox(width: 8),
                    primaryButton,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
