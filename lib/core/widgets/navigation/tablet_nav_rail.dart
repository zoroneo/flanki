import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TabletNavRail extends StatelessWidget {
  final int currentIndex;
  final int totalDue;
  final bool isAuthenticated;
  final dynamic l10n;
  final ValueChanged<int> onSelectTab;

  const TabletNavRail({
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
      width: 72,
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Column(
        children: [
          _buildBrandIcon(theme),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildNavItems(theme),
          const Spacer(),
          _buildSyncIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Tooltip(
        tooltip: (context) => const TooltipContainer(child: Text('Flanki')),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              LucideIcons.zap,
              color: theme.colorScheme.primaryForeground,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItems(ThemeData theme) {
    return Column(
      children: [
        NavRailItem(
          icon: LucideIcons.layers,
          activeIcon: LucideIcons.layers2,
          label: l10n.navDecks,
          shortcutHint: 'Ctrl+1',
          isSelected: currentIndex == 0,
          badgeCount: totalDue > 0 ? totalDue : null,
          onTap: () => onSelectTab(0),
        ),
        const SizedBox(height: 8),
        NavRailItem(
          icon: LucideIcons.search,
          activeIcon: LucideIcons.fileSearch,
          label: l10n.navBrowser,
          shortcutHint: 'Ctrl+2',
          isSelected: currentIndex == 1,
          onTap: () => onSelectTab(1),
        ),
        const SizedBox(height: 8),
        NavRailItem(
          icon: LucideIcons.bookOpenText,
          activeIcon: LucideIcons.bookOpen,
          label: l10n.navGrammar,
          shortcutHint: 'Ctrl+3',
          isSelected: currentIndex == 2,
          onTap: () => onSelectTab(2),
        ),
        const SizedBox(height: 8),
        NavRailItem(
          icon: LucideIcons.chartColumn,
          activeIcon: LucideIcons.chartNoAxesCombined,
          label: l10n.navStats,
          shortcutHint: 'Ctrl+4',
          isSelected: currentIndex == 3,
          onTap: () => onSelectTab(3),
        ),
        const SizedBox(height: 8),
        NavRailItem(
          icon: LucideIcons.settings,
          activeIcon: LucideIcons.settings2,
          label: l10n.navSettings,
          shortcutHint: 'Ctrl+5',
          isSelected: currentIndex == 4,
          indicatorColor: isAuthenticated ? m.Colors.green : null,
          onTap: () => onSelectTab(4),
        ),
      ],
    );
  }

  Widget _buildSyncIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Tooltip(
        tooltip: (context) => TooltipContainer(
          child: Text(
            '${l10n.syncAnkiWeb}: ${isAuthenticated ? l10n.connected : l10n.offlineMode}',
          ),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.6),
            ),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isAuthenticated
                    ? m.Colors.green
                    : theme.colorScheme.mutedForeground,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NavRailItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? shortcutHint;
  final bool isSelected;
  final int? badgeCount;
  final m.Color? indicatorColor;
  final VoidCallback onTap;

  const NavRailItem({
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
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    final tooltipContent = shortcutHint != null
        ? '$label ($shortcutHint)'
        : label;

    return Tooltip(
      tooltip: (context) => TooltipContainer(child: Text(tooltipContent)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : m.Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(isSelected ? activeIcon : icon, size: 22, color: color),
                if (badgeCount != null)
                  Positioned(top: 4, right: 4, child: _buildBadge(theme)),
                if (indicatorColor != null)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _buildIndicator(theme),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        badgeCount! > 99 ? '99+' : '$badgeCount',
        style: const TextStyle(
          color: m.Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.background, width: 1.5),
      ),
    );
  }
}
