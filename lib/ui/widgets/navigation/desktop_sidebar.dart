import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final int totalDue;
  final bool isAuthenticated;
  final dynamic l10n;
  final ValueChanged<int> onSelectTab;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.totalDue,
    required this.isAuthenticated,
    required this.l10n,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrandHeader(theme),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildNavLinks(theme),
          const Spacer(),
          _buildSyncStatus(theme),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                LucideIcons.zap,
                color: theme.colorScheme.primaryForeground,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildNavLinks(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          SidebarNavItem(
            icon: LucideIcons.layers,
            activeIcon: LucideIcons.layers2,
            label: l10n.navDecks,
            shortcutHint: 'Ctrl+1',
            isSelected: currentIndex == 0,
            badgeCount: totalDue > 0 ? totalDue : null,
            onTap: () => onSelectTab(0),
          ),
          const SizedBox(height: 4),
          SidebarNavItem(
            icon: LucideIcons.search,
            activeIcon: LucideIcons.fileSearch,
            label: l10n.navBrowser,
            shortcutHint: 'Ctrl+2',
            isSelected: currentIndex == 1,
            onTap: () => onSelectTab(1),
          ),
          const SizedBox(height: 4),
          SidebarNavItem(
            icon: LucideIcons.bookOpenText,
            activeIcon: LucideIcons.bookOpen,
            label: l10n.navGrammar,
            shortcutHint: 'Ctrl+3',
            isSelected: currentIndex == 2,
            onTap: () => onSelectTab(2),
          ),
          const SizedBox(height: 4),
          SidebarNavItem(
            icon: LucideIcons.chartColumn,
            activeIcon: LucideIcons.chartNoAxesCombined,
            label: l10n.navStats,
            shortcutHint: 'Ctrl+4',
            isSelected: currentIndex == 3,
            onTap: () => onSelectTab(3),
          ),
          const SizedBox(height: 4),
          SidebarNavItem(
            icon: LucideIcons.settings,
            activeIcon: LucideIcons.settings2,
            label: l10n.navSettings,
            shortcutHint: 'Ctrl+5',
            isSelected: currentIndex == 4,
            indicatorColor: isAuthenticated ? m.Colors.green : null,
            onTap: () => onSelectTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.border.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isAuthenticated
                    ? m.Colors.green
                    : theme.colorScheme.mutedForeground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
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
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.mutedForeground,
                    ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : m.Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildIcon(theme),
              const SizedBox(width: 12),
              _buildLabel(theme),
              if (badgeCount != null) _buildBadge(theme),
              if (shortcutHint != null && isSelected) _buildShortcutHint(theme),
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
      size: 18,
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.mutedForeground,
    );
  }

  Widget _buildLabel(ThemeData theme) {
    return Expanded(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected
              ? theme.colorScheme.foreground
              : theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        badgeCount! > 99 ? '99+' : '$badgeCount',
        style: const TextStyle(
          color: m.Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildShortcutHint(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        shortcutHint!,
        style: TextStyle(
          fontSize: 10,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
    );
  }
}
