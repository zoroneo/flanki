import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/locale_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
import '../../core/notifiers/card_browser_notifier.dart';
import '../../core/notifiers/stats_notifier.dart';
import '../../core/auth/auth_notifier.dart';

const double kDesktopBreakpoint = 768.0;

class AdaptiveScaffold extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  void _onTap(int index, WidgetRef ref) {
    HapticFeedback.selectionClick();
    if (index == 0) {
      ref.read(deckListProvider.notifier).refresh();
    } else if (index == 1) {
      ref.read(cardBrowserProvider.notifier).refresh();
    } else if (index == 3) {
      ref.read(statsNotifierProvider.notifier).refresh();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final authState = ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    final totalDue = decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);
    final currentIndex = navigationShell.currentIndex;

    // Desktop keyboard shortcuts: Ctrl+1..5
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () =>
            _onTap(0, ref),
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () =>
            _onTap(1, ref),
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () =>
            _onTap(2, ref),
        const SingleActivator(LogicalKeyboardKey.digit4, control: true): () =>
            _onTap(3, ref),
        const SingleActivator(LogicalKeyboardKey.digit5, control: true): () =>
            _onTap(4, ref),
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;

            if (isDesktop) {
              return Scaffold(
                child: Row(
                  children: [
                    // Desktop Left Navigation Sidebar (240px)
                    _DesktopSidebar(
                      currentIndex: currentIndex,
                      totalDue: totalDue,
                      isAuthenticated: authState.isAuthenticated,
                      l10n: l10n,
                      onSelectTab: (index) => _onTap(index, ref),
                    ),
                    const VerticalDivider(width: 1),
                    // Main Screen Area
                    Expanded(child: navigationShell),
                  ],
                ),
              );
            }

            // Mobile Layout (< 768px): Screen on top, Bottom Navigation Bar below
            return Scaffold(
              child: Column(
                children: [
                  Expanded(child: navigationShell),
                  _MobileBottomNavBar(
                    theme: theme,
                    currentIndex: currentIndex,
                    totalDue: totalDue,
                    isAuthenticated: authState.isAuthenticated,
                    l10n: l10n,
                    onTap: (index) => _onTap(index, ref),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop Sidebar
// ---------------------------------------------------------------------------

class _DesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final int totalDue;
  final bool isAuthenticated;
  final dynamic l10n;
  final ValueChanged<int> onSelectTab;

  const _DesktopSidebar({
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
          // App Brand Header
          Padding(
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
                      'Desktop • Zinc',
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Navigation Links
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _SidebarNavItem(
                  icon: LucideIcons.layers,
                  activeIcon: LucideIcons.layers2,
                  label: l10n.navDecks,
                  shortcutHint: 'Ctrl+1',
                  isSelected: currentIndex == 0,
                  badgeCount: totalDue > 0 ? totalDue : null,
                  onTap: () => onSelectTab(0),
                ),
                const SizedBox(height: 4),
                _SidebarNavItem(
                  icon: LucideIcons.search,
                  activeIcon: LucideIcons.fileSearch,
                  label: l10n.navBrowser,
                  shortcutHint: 'Ctrl+2',
                  isSelected: currentIndex == 1,
                  onTap: () => onSelectTab(1),
                ),
                const SizedBox(height: 4),
                _SidebarNavItem(
                  icon: LucideIcons.bookOpenText,
                  activeIcon: LucideIcons.bookOpen,
                  label: l10n.navGrammar,
                  shortcutHint: 'Ctrl+3',
                  isSelected: currentIndex == 2,
                  onTap: () => onSelectTab(2),
                ),
                const SizedBox(height: 4),
                _SidebarNavItem(
                  icon: LucideIcons.chartColumn,
                  activeIcon: LucideIcons.chartNoAxesCombined,
                  label: l10n.navStats,
                  shortcutHint: 'Ctrl+4',
                  isSelected: currentIndex == 3,
                  onTap: () => onSelectTab(3),
                ),
                const SizedBox(height: 4),
                _SidebarNavItem(
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
          ),

          const Spacer(),

          // Desktop Footer: Sync Status
          Padding(
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
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? shortcutHint;
  final bool isSelected;
  final int? badgeCount;
  final m.Color? indicatorColor;
  final VoidCallback onTap;

  const _SidebarNavItem({
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
              Icon(
                isSelected ? activeIcon : icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 12),
              Expanded(
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
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
                ),
              if (shortcutHint != null && isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    shortcutHint!,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              if (indicatorColor != null)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile Bottom Bar
// ---------------------------------------------------------------------------

class _MobileBottomNavBar extends StatelessWidget {
  final ThemeData theme;
  final int currentIndex;
  final int totalDue;
  final bool isAuthenticated;
  final dynamic l10n;
  final ValueChanged<int> onTap;

  const _MobileBottomNavBar({
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
              _BottomNavItem(
                icon: LucideIcons.layers,
                activeIcon: LucideIcons.layers2,
                label: l10n.navDecks,
                isSelected: currentIndex == 0,
                badgeCount: totalDue > 0 ? totalDue : null,
                onTap: () => onTap(0),
              ),
              _BottomNavItem(
                icon: LucideIcons.search,
                activeIcon: LucideIcons.fileSearch,
                label: l10n.navBrowser,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _BottomNavItem(
                icon: LucideIcons.bookOpenText,
                activeIcon: LucideIcons.bookOpen,
                label: l10n.navGrammar,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _BottomNavItem(
                icon: LucideIcons.chartColumn,
                activeIcon: LucideIcons.chartNoAxesCombined,
                label: l10n.navStats,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _BottomNavItem(
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final int? badgeCount;
  final m.Color? indicatorColor;
  final VoidCallback onTap;

  const _BottomNavItem({
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : m.Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: color,
                  ),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.destructive,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.colorScheme.background,
                          width: 1.5,
                        ),
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
                    ),
                  ),
                if (indicatorColor != null)
                  Positioned(
                    bottom: 2,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
