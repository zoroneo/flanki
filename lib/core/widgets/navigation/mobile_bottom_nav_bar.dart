import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavItem(
                icon: LucideIcons.layers,
                activeIcon: LucideIcons.layers2,
                label: l10n.navDecks,
                isSelected: currentIndex == 0,
                badgeCount: totalDue > 0 ? totalDue : null,
                onTap: () => onTap(0),
              ),
              BottomNavItem(
                icon: LucideIcons.search,
                activeIcon: LucideIcons.fileSearch,
                label: l10n.navBrowser,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              BottomNavItem(
                icon: LucideIcons.bookOpenText,
                activeIcon: LucideIcons.bookOpen,
                label: l10n.navGrammar,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              BottomNavItem(
                icon: LucideIcons.chartColumn,
                activeIcon: LucideIcons.chartNoAxesCombined,
                label: l10n.navStats,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              BottomNavItem(
                icon: LucideIcons.settings,
                activeIcon: LucideIcons.settings2,
                label: l10n.navSettings,
                isSelected: currentIndex == 4,
                indicatorColor: isAuthenticated ? m.Colors.green : null,
                onTap: () => onTap(4),
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
        constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconStack(theme, color),
            const SizedBox(height: 3),
            _buildLabel(color),
          ],
        ),
      ),
    );
  }

  Widget _buildIconStack(ThemeData theme, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : m.Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(isSelected ? activeIcon : icon, size: 22, color: color),
        ),
        if (badgeCount != null)
          Positioned(top: -2, right: 2, child: _buildBadge(theme)),
        if (indicatorColor != null)
          Positioned(bottom: 2, right: 6, child: _buildIndicator(theme)),
      ],
    );
  }

  Widget _buildBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.background, width: 1.5),
      ),
      child: Text(
        badgeCount! > 99 ? '99+' : '$badgeCount',
        style: const TextStyle(
          color: m.Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.background, width: 1.5),
      ),
    );
  }

  Widget _buildLabel(Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: color,
      ),
    );
  }
}
