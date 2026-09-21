import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class MobileBottomNavBar extends StatelessWidget {
  final ThemeData theme;
  final int currentIndex;
  final int totalDue;
  final bool isAuthenticated;
  final dynamic l10n;
  final ValueChanged<int> onTap;

  const MobileBottomNavBar({
    super.key,
    required this.theme,
    required this.currentIndex,
    required this.totalDue,
    required this.isAuthenticated,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: BottomNavItem(
                  icon: LucideIcons.layers,
                  activeIcon: LucideIcons.layers2,
                  label: l10n.navDecks,
                  isSelected: currentIndex == AppNavIndex.decks,
                  badgeCount: totalDue > 0 ? totalDue : null,
                  onTap: () => onTap(AppNavIndex.decks),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: LucideIcons.bookOpenText,
                  activeIcon: LucideIcons.bookOpen,
                  label: l10n.navGrammar,
                  isSelected: currentIndex == AppNavIndex.grammar,
                  onTap: () => onTap(AppNavIndex.grammar),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: LucideIcons.graduationCap,
                  activeIcon: LucideIcons.graduationCap,
                  label: l10n.navExams,
                  isSelected: currentIndex == AppNavIndex.exams,
                  onTap: () => onTap(AppNavIndex.exams),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: LucideIcons.settings,
                  activeIcon: LucideIcons.settings2,
                  label: l10n.navSettings,
                  isSelected: currentIndex == AppNavIndex.settings,
                  indicatorColor: isAuthenticated
                      ? context.colors.success
                      : null,
                  onTap: () => onTap(AppNavIndex.settings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final m.Color? indicatorColor;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    this.indicatorColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppDimensions.mobileNavItemMinWidth,
          minHeight: AppDimensions.mobileNavItemMinHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxs,
          vertical: AppSpacing.xxs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconStack(context, theme, color),
            AppGaps.v4,
            _buildLabel(context, color),
          ],
        ),
      ),
    );
  }

  Widget _buildIconStack(BuildContext context, ThemeData theme, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: AppDurations.normal,
          width: AppDimensions.navIndicatorPillWidth,
          height: AppDimensions.navIndicatorPillHeight,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.14)
                : AppColors.transparent,
            borderRadius: AppRadius.borderFull,
          ),
          child: Center(
            child: Icon(
              isSelected ? activeIcon : icon,
              size: AppIconSize.lg,
              color: color,
            ),
          ),
        ),
        if (badgeCount != null)
          Positioned(top: -3, right: 8, child: _buildBadge(context, theme)),
        if (indicatorColor != null)
          Positioned(bottom: 2, right: 12, child: _buildIndicator(theme)),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: AppEdgeInsets.badge,
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: AppRadius.borderFull,
        border: Border.all(color: theme.colorScheme.background, width: 1.5),
      ),
      child: Text(
        badgeCount! > AppLimits.badgeMaxCount
            ? AppLimits.badgeOverflowText
            : '$badgeCount',
        style: context.textStyles.captionBold.copyWith(
          color: AppColors.white,
          height: AppTypography.lineHeightBadge,
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return Container(
      width: AppDimensions.statusDotSize,
      height: AppDimensions.statusDotSize,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.background, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, Color color) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style:
          (isSelected ? context.textStyles.subSemiBold : context.textStyles.sub)
              .copyWith(color: color),
    );
  }
}
