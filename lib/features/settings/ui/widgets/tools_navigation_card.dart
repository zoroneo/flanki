import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';

class ToolsNavigationCard extends StatelessWidget {
  const ToolsNavigationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.learningTools,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v8,
        Card(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildNavTile(
                theme: theme,
                icon: LucideIcons.chartColumn,
                title: l10n.statsTitle,
                subtitle: l10n.navStats,
                onTap: () => context.go(AppRoutes.stats),
              ),
              const Divider(),
              _buildNavTile(
                theme: theme,
                icon: LucideIcons.fileSearch,
                title: l10n.navBrowser,
                subtitle: l10n.searchDecks,
                onTap: () => context.go(AppRoutes.browser),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: AppEdgeInsets.all16,
        child: Row(
          children: [
            Icon(icon, size: AppIconSize.md, color: theme.colorScheme.primary),
            AppGaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGaps.v2,
                  Text(
                    subtitle,
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
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
