import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/update_notifier.dart';
import '../../data/desktop_update_service.dart';

class LanguageOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: AppRadius.borderSm,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            overflow: TextOverflow.visible,
            style: theme.typography.small.copyWith(
              fontSize: 12,
              height: 1.2,
              leadingDistribution: TextLeadingDistribution.even,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.primaryForeground
                  : theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.h12,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.small.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VersionInfoRow extends StatelessWidget {
  final String label;
  final String version;
  final UpdateState updateState;
  final VoidCallback onCheckUpdate;
  final VoidCallback onShowDialog;

  const VersionInfoRow({
    super.key,
    required this.label,
    required this.version,
    required this.updateState,
    required this.onCheckUpdate,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isSupported = DesktopUpdateService.isSupported;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
          AppGaps.h8,
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  version,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSupported) ...[
                  AppGaps.h8,
                  _buildUpdateStatusWidget(theme, l10n),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusWidget(ThemeData theme, dynamic l10n) {
    return switch (updateState.status) {
      UpdateStatus.checking => Text(
        l10n.checkingForUpdates,
        style: theme.typography.xSmall.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      UpdateStatus.available => GestureDetector(
        onTap: onShowDialog,
        child: Container(
          padding: AppEdgeInsets.h8v4,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circleArrowUp, size: AppIconSize.xs),
              AppGaps.h4,
              Text(
                l10n.newVersionBadge(
                  updateState.updateInfo?.latestVersion ?? '',
                ),
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      UpdateStatus.downloading => () {
        final pct = (updateState.downloadProgress * 100).toInt().clamp(0, 100);
        return GestureDetector(
          onTap: onShowDialog,
          child: Container(
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    value: updateState.downloadProgress > 0
                        ? updateState.downloadProgress
                        : null,
                  ),
                ),
                AppGaps.h4,
                Text(
                  '$pct%',
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }(),
      UpdateStatus.readyToInstall => GestureDetector(
        onTap: onShowDialog,
        child: Container(
          padding: AppEdgeInsets.h8v4,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: AppRadius.borderSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circleCheck, size: AppIconSize.xs),
              AppGaps.h4,
              Text(
                l10n.restartAndInstall,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      UpdateStatus.upToDate => GestureDetector(
        onTap: onCheckUpdate,
        child: Text(
          l10n.latestVersionStatus,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      _ => GestureDetector(
        onTap: onCheckUpdate,
        child: Text(
          l10n.checkForUpdates,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    };
  }
}

class ClickableInfoRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ClickableInfoRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: AppIconSize.sm,
              color: theme.colorScheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
