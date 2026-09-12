import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/notifiers/locale_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
import '../../core/notifiers/card_browser_notifier.dart';
import '../../features/stats/providers/stats_notifier.dart';
import '../../core/notifiers/auth_notifier.dart';

class MobileScaffold extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MobileScaffold({super.key, required this.navigationShell});

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
    final l10n = context.l10n;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      child: Column(
        children: [
          // Screen content from shell branch
          Expanded(child: navigationShell),

          // Modern Zinc Mobile Bottom Navigation Bar
          Container(
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
                    Consumer(
                      builder: (context, ref, _) {
                        final totalDue = ref.watch(
                          deckListProvider.select(
                            (decks) => decks.fold<int>(
                              0,
                              (sum, d) => sum + d.dueCount,
                            ),
                          ),
                        );
                        return _BottomNavItem(
                          icon: LucideIcons.layers,
                          activeIcon: LucideIcons.layers2,
                          label: l10n.navDecks,
                          isSelected: currentIndex == 0,
                          badgeCount: totalDue > 0 ? totalDue : null,
                          onTap: () => _onTap(0, ref),
                        );
                      },
                    ),
                    _BottomNavItem(
                      icon: LucideIcons.search,
                      activeIcon: LucideIcons.fileSearch,
                      label: l10n.navBrowser,
                      isSelected: currentIndex == 1,
                      onTap: () => _onTap(1, ref),
                    ),
                    _BottomNavItem(
                      icon: LucideIcons.bookOpenText,
                      activeIcon: LucideIcons.bookOpen,
                      label: l10n.navGrammar,
                      isSelected: currentIndex == 2,
                      onTap: () => _onTap(2, ref),
                    ),
                    _BottomNavItem(
                      icon: LucideIcons.chartColumn,
                      activeIcon: LucideIcons.chartNoAxesCombined,
                      label: l10n.navStats,
                      isSelected: currentIndex == 3,
                      onTap: () => _onTap(3, ref),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final isAuthenticated = ref.watch(
                          authNotifierProvider.select((s) => s.isAuthenticated),
                        );
                        return _BottomNavItem(
                          icon: LucideIcons.settings,
                          activeIcon: LucideIcons.settings2,
                          label: l10n.navSettings,
                          isSelected: currentIndex == 4,
                          indicatorColor: isAuthenticated
                              ? m.Colors.green
                              : null,
                          onTap: () => _onTap(4, ref),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
