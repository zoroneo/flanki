import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../models/update_info.dart';
import '../../providers/update_notifier.dart';
import '../../data/desktop_update_service.dart';

class UpdateDialog extends ConsumerWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static VoidCallback? onDismissActiveToast;
  static VoidCallback? onDialogDismissed;
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
      onDialogDismissed?.call();
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
        padding: AppEdgeInsets.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.circleArrowUp,
                  size: AppIconSize.lg,
                  color: theme.colorScheme.primary,
                ),
                AppGaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.updateAvailable,
                        style: context.textStyles.bodySemiBold,
                      ),
                      AppGaps.v2,
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
            AppGaps.v16,
            if (updateInfo.releaseNotes != null &&
                updateInfo.releaseNotes!.isNotEmpty) ...[
              Text(
                l10n.updateChangelog,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppGaps.v8,
              Flexible(
                child: Container(
                  width: double.infinity,
                  padding: AppEdgeInsets.all12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.5),
                    borderRadius: AppRadius.borderMd,
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
              AppGaps.v16,
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
              AppGaps.v8,
              LinearProgressIndicator(value: updateState.downloadProgress),
              AppGaps.v16,
            ],
            if (updateState.status == UpdateStatus.error &&
                updateState.getLocalizedError(l10n) != null) ...[
              Container(
                padding: AppEdgeInsets.all8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  updateState.getLocalizedError(l10n)!,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.destructive,
                  ),
                ),
              ),
              AppGaps.v12,
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final hasDirectDownload = updateInfo.downloadUrl != null;

                final (
                  Widget primaryButton,
                  Widget? backgroundButton,
                  Widget outlineButton,
                ) = !hasDirectDownload
                    ? (
                        PrimaryButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            DesktopUpdateService.openUrl(updateInfo.releaseUrl);
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.openDownloadPage),
                        ),
                        null,
                        OutlineButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            notifier.dismiss();
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.later),
                        ),
                      )
                    : switch (updateState.status) {
                        UpdateStatus.readyToInstall => (
                          PrimaryButton(
                            alignment: Alignment.center,
                            onPressed: () => notifier.installAndRestart(),
                            child: Text(l10n.restartAndInstall),
                          ),
                          null,
                          OutlineButton(
                            alignment: Alignment.center,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(l10n.later),
                          ),
                        ),
                        UpdateStatus.downloading => (
                          PrimaryButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              // Close dialog and let download continue in background
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.downloadInBackground),
                          ),
                          null,
                          OutlineButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              notifier.cancelDownload();
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.cancelDownload),
                          ),
                        ),
                        _ => (
                          PrimaryButton(
                            alignment: Alignment.center,
                            onPressed: () => notifier.downloadUpdate(),
                            child: Text(l10n.downloadAndInstall),
                          ),
                          OutlineButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              notifier.downloadUpdate();
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.downloadInBackground),
                          ),
                          OutlineButton(
                            alignment: Alignment.center,
                            onPressed: () {
                              notifier.dismiss();
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.later),
                          ),
                        ),
                      };

                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      primaryButton,
                      if (backgroundButton != null) ...[
                        AppGaps.v8,
                        backgroundButton,
                      ],
                      AppGaps.v8,
                      outlineButton,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    outlineButton,
                    if (backgroundButton != null) ...[
                      AppGaps.h8,
                      backgroundButton,
                    ],
                    AppGaps.h8,
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
