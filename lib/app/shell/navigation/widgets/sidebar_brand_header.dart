import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class SidebarBrandHeader extends StatelessWidget {
  final AppLocalizations l10n;

  const SidebarBrandHeader({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.brandIconDesktop,
            height: AppDimensions.brandIconDesktop,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: AppRadius.borderMd,
            ),
            child: Center(
              child: Icon(
                LucideIcons.zap,
                color: theme.colorScheme.primaryForeground,
                size: AppIconSize.md,
              ),
            ),
          ),
          AppGaps.h12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flanki',
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                l10n.desktopSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
