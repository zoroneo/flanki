import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_modal.dart';
import 'sync_conflict_option_tile.dart';

enum SyncConflictChoice { merge, upload, download }

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
  /// On mobile devices, renders as an adaptive bottom sheet.
  /// On desktop/tablet, renders as a centered modal dialog.
  static Future<SyncConflictChoice?> show(
    BuildContext context, {
    DateTime? localLastSync,
    DateTime? serverMod,
  }) {
    return showAdaptiveModal<SyncConflictChoice>(
      context: context,
      useRootNavigator: true,
      builder: (ctx, isDesktop) => SyncConflictDialog(
        localLastSync: localLastSync,
        serverMod: serverMod,
        isBottomSheet: !isDesktop,
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
              width: AppDimensions.modalGrabHandleWidth,
              height: AppDimensions.modalGrabHandleHeight,
              margin: const EdgeInsets.only(
                top: AppSpacing.smPlus,
                bottom: AppSpacing.smPlus,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.mutedForeground.withValues(
                  alpha: 0.25,
                ),
                borderRadius: AppRadius.borderXs,
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: AppEdgeInsets.all8,
              decoration: BoxDecoration(
                color: theme.colorScheme.destructive.withValues(alpha: 0.12),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                LucideIcons.cloudAlert,
                size: AppIconSize.md,
                color: theme.colorScheme.destructive,
              ),
            ),
            AppGaps.h8,
            Expanded(
              child: Text(
                l10n.syncConflictTitle,
                style: context.textStyles.bodySemiBold,
              ),
            ),
            IconButton.ghost(
              icon: const Icon(LucideIcons.x, size: AppIconSize.md),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        AppGaps.v8,
        Text(
          l10n.syncConflictDesc,
          style: context.textStyles.xSmallMuted.copyWith(height: 1.35),
        ),
        AppGaps.v12,
        Container(
          padding: AppEdgeInsets.h12v8,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.4),
            borderRadius: AppRadius.borderMd,
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
                    size: AppIconSize.xs,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(
                      l10n.previousSyncLabel,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  AppGaps.h8,
                  Text(
                    _formatDateTime(context, localLastSync),
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppGaps.v4,
              Row(
                children: [
                  Icon(
                    LucideIcons.cloud,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(
                      l10n.ankiWebUpdateLabel,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                  AppGaps.h8,
                  Text(
                    _formatDateTime(context, serverMod),
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppGaps.v12,
        Text(l10n.selectVersionToKeep, style: context.textStyles.nav),
        AppGaps.v8,
        ConflictOptionCard(
          icon: LucideIcons.gitMerge,
          iconColor: theme.colorScheme.primary,
          title: l10n.mergeCollectionsTitle,
          desc: l10n.mergeCollectionsDesc,
          badge: l10n.recommendedBadge,
          onTap: () => Navigator.of(context).pop(SyncConflictChoice.merge),
        ),
        AppGaps.v8,
        ConflictOptionCard(
          icon: LucideIcons.cloudUpload,
          iconColor: theme.colorScheme.primary,
          title: l10n.uploadToCloudTitle,
          desc: l10n.uploadToCloudDesc,
          onTap: () => Navigator.of(context).pop(SyncConflictChoice.upload),
        ),
        AppGaps.v8,
        ConflictOptionCard(
          icon: LucideIcons.cloudDownload,
          iconColor: theme.colorScheme.primary,
          title: l10n.downloadFromCloudTitle,
          desc: l10n.downloadFromCloudDesc,
          onTap: () => Navigator.of(context).pop(SyncConflictChoice.download),
        ),
        AppGaps.v12,
        OutlineButton(
          alignment: Alignment.center,
          onPressed: () => Navigator.of(context).pop(),
          child: Center(child: Text(l10n.cancel)),
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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.lg),
          ),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.border,
              width: AppDimensions.hairline,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.none,
              AppSpacing.md,
              AppSpacing.smPlus,
            ),
            child: content,
          ),
        ),
      );
    }

    return ModalContainer(
      child: SingleChildScrollView(
        padding: AppEdgeInsets.all20,
        child: content,
      ),
    );
  }
}
