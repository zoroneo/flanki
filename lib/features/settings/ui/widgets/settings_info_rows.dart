import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
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
          borderRadius: BorderRadius.circular(6),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 12),
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
          const SizedBox(width: 8),
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
                  const SizedBox(width: 8),
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
    if (updateState.status == UpdateStatus.checking) {
      return Text(
        l10n.checkingForUpdates,
        style: theme.typography.xSmall.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      );
    } else if (updateState.status == UpdateStatus.available) {
      return GestureDetector(
        onTap: onShowDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circleArrowUp, size: 12),
              const SizedBox(width: 4),
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
      );
    } else if (updateState.status == UpdateStatus.upToDate) {
      return GestureDetector(
        onTap: onCheckUpdate,
        child: Text(
          l10n.latestVersionStatus,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onCheckUpdate,
        child: Text(
          l10n.checkForUpdates,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    }
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
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              size: 16,
              color: theme.colorScheme.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
