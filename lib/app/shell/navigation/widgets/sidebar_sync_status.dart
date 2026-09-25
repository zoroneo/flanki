import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class SidebarSyncStatus extends StatelessWidget {
  final bool isAuthenticated;
  final AppLocalizations l10n;

  const SidebarSyncStatus({
    super.key,
    required this.isAuthenticated,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppEdgeInsets.all16,
      child: Container(
        padding: AppEdgeInsets.all12,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: theme.colorScheme.border.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.statusDotSize,
              height: AppDimensions.statusDotSize,
              decoration: BoxDecoration(
                color: isAuthenticated
                    ? context.colors.success
                    : theme.colorScheme.mutedForeground,
                shape: BoxShape.circle,
              ),
            ),
            AppGaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.syncAnkiWeb,
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isAuthenticated ? l10n.connected : l10n.offlineMode,
                    style: context.textStyles.captionMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
