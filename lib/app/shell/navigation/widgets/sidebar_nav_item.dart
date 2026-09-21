import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? shortcutHint;
  final bool isSelected;
  final int? badgeCount;
  final m.Color? indicatorColor;
  final VoidCallback onTap;

  const SidebarNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.shortcutHint,
    required this.isSelected,
    this.badgeCount,
    this.indicatorColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: AppEdgeInsets.h12v8,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : AppColors.transparent,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              _buildIcon(theme),
              AppGaps.h12,
              _buildLabel(context, theme),
              if (badgeCount != null) _buildBadge(context, theme),
              if (shortcutHint != null && isSelected)
                _buildShortcutHint(context, theme),
              if (indicatorColor != null) _buildIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return Icon(
      isSelected ? activeIcon : icon,
      size: AppIconSize.md,
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.mutedForeground,
    );
  }

  Widget _buildLabel(BuildContext context, ThemeData theme) {
    return Expanded(
      child: Text(
        label,
        style: isSelected
            ? context.textStyles.navBold
            : context.textStyles.nav.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: AppEdgeInsets.tag,
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        badgeCount! > AppLimits.badgeMaxCount
            ? AppLimits.badgeOverflowText
            : '$badgeCount',
        style: context.textStyles.captionBold.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _buildShortcutHint(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s6),
      child: Text(shortcutHint!, style: context.textStyles.captionMuted),
    );
  }

  Widget _buildIndicator() {
    return Container(
      width: AppDimensions.indicatorDotSize,
      height: AppDimensions.indicatorDotSize,
      margin: const EdgeInsets.only(left: AppSpacing.s6),
      decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
    );
  }
}
