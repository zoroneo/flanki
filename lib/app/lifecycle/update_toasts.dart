import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/features/settings/models/update_info.dart';
import 'package:flanki/features/settings/providers/update_notifier.dart';
import 'package:flanki/features/settings/ui/widgets/update_dialog.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class BackgroundDownloadToast extends ConsumerWidget {
  final UpdateInfo info;
  final VoidCallback onDismiss;

  const BackgroundDownloadToast({
    super.key,
    required this.info,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final progress = ref.watch(
      updateProvider.select((s) => s.downloadProgress),
    );
    final pct = (progress * 100).toInt().clamp(0, 100);

    return SurfaceCard(
      padding: AppEdgeInsets.h12v8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: AppDimensions.toastSpinnerSize,
                height: AppDimensions.toastSpinnerSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.spinnerStrokeWidth,
                ),
              ),
              AppGaps.h12,
              Expanded(
                child: Text(
                  '${l10n.downloadingUpdate} ($pct%)',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGaps.h8,
              GhostButton(
                size: ButtonSize.small,
                onPressed: () {
                  onDismiss();
                  UpdateDialog.show(context, info);
                },
                child: Text(l10n.updateAction),
              ),
              AppGaps.h4,
              IconButton.ghost(
                size: ButtonSize.small,
                icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                onPressed: () {
                  ref.read(updateProvider.notifier).cancelDownload();
                  onDismiss();
                },
              ),
            ],
          ),
          AppGaps.v8,
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}

class UpdateAvailableToast extends StatelessWidget {
  final UpdateInfo info;
  final VoidCallback onDismiss;
  final VoidCallback onDownloadInBackground;
  final VoidCallback onOpenUpdateDialog;

  const UpdateAvailableToast({
    super.key,
    required this.info,
    required this.onDismiss,
    required this.onDownloadInBackground,
    required this.onOpenUpdateDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SurfaceCard(
      padding: AppEdgeInsets.h12v8,
      child: Row(
        children: [
          Icon(
            LucideIcons.circleArrowUp,
            size: AppIconSize.md,
            color: theme.colorScheme.primary,
          ),
          AppGaps.h12,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.updateBannerTitle(info.latestVersion),
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppGaps.v2,
                Text(
                  l10n.updateBannerSubtitle,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppGaps.h12,
          if (info.downloadUrl != null) ...[
            OutlineButton(
              alignment: Alignment.center,
              size: ButtonSize.small,
              onPressed: onDownloadInBackground,
              child: Text(l10n.downloadInBackground),
            ),
            AppGaps.h8,
          ],
          PrimaryButton(
            alignment: Alignment.center,
            size: ButtonSize.small,
            onPressed: onOpenUpdateDialog,
            child: Text(l10n.updateAction),
          ),
          AppGaps.h4,
          IconButton.ghost(
            size: ButtonSize.small,
            icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class UpdateReadyToast extends StatelessWidget {
  final UpdateInfo info;
  final VoidCallback onDismiss;
  final VoidCallback onInstallAndRestart;
  final VoidCallback onOpenUpdateDialog;

  const UpdateReadyToast({
    super.key,
    required this.info,
    required this.onDismiss,
    required this.onInstallAndRestart,
    required this.onOpenUpdateDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SurfaceCard(
      padding: AppEdgeInsets.h12v8,
      child: Row(
        children: [
          Icon(
            LucideIcons.circleCheck,
            size: AppIconSize.md,
            color: theme.colorScheme.primary,
          ),
          AppGaps.h12,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.updateReadyTitle,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppGaps.v2,
                Text(
                  l10n.updateReadySubtitle(info.latestVersion),
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppGaps.h12,
          PrimaryButton(
            alignment: Alignment.center,
            size: ButtonSize.small,
            onPressed: onInstallAndRestart,
            child: Text(l10n.updateReadyAction),
          ),
          AppGaps.h8,
          GhostButton(
            size: ButtonSize.small,
            onPressed: onOpenUpdateDialog,
            child: Text(l10n.updateAction),
          ),
          AppGaps.h4,
          IconButton.ghost(
            size: ButtonSize.small,
            icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class UpdateFailedToast extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  const UpdateFailedToast({
    super.key,
    required this.onDismiss,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SurfaceCard(
      padding: AppEdgeInsets.h12v8,
      child: Row(
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: AppIconSize.md,
            color: theme.colorScheme.destructive,
          ),
          AppGaps.h12,
          Expanded(
            child: Text(
              l10n.updateDownloadFailed,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.destructive,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppGaps.h12,
          PrimaryButton(
            alignment: Alignment.center,
            size: ButtonSize.small,
            onPressed: onRetry,
            child: Text(l10n.downloadAndInstall),
          ),
          AppGaps.h4,
          IconButton.ghost(
            size: ButtonSize.small,
            icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
