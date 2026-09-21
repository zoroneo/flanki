import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class DesktopTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DesktopTypeOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smPlus,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.muted.withValues(alpha: 0.3),
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSize.md,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
            AppGaps.h8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (isSelected
                                ? context.textStyles.navBold
                                : context.textStyles.nav.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ))
                            .copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.foreground,
                            ),
                  ),
                  AppGaps.v2,
                  Text(subtitle, style: context.textStyles.subMuted),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: AppIconSize.sm,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class TypeSelectButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeSelectButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smPlus,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted,
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: context.textStyles.xSmallBold.copyWith(
                color: isSelected
                    ? theme.colorScheme.primaryForeground
                    : theme.colorScheme.foreground,
              ),
            ),
            AppGaps.v2,
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.textStyles.badge.copyWith(
                color: isSelected
                    ? theme.colorScheme.primaryForeground.withValues(alpha: 0.8)
                    : theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
