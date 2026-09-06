import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../core/localization/locale_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
import '../../core/auth/auth_notifier.dart';

class MobileScaffold extends HookConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MobileScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    HapticFeedback.selectionClick();
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
                top: BorderSide(
                  color: theme.colorScheme.border,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: m.Icons.style_outlined,
                      activeIcon: m.Icons.style_rounded,
                      label: l10n.navDecks,
                      isSelected: currentIndex == 0,
                      badgeCount: totalDue > 0 ? totalDue : null,
                      onTap: () => _onTap(0),
                    ),
                    _BottomNavItem(
                      icon: m.Icons.search_rounded,
                      activeIcon: m.Icons.manage_search_rounded,
                      label: l10n.navBrowser,
                      isSelected: currentIndex == 1,
                      onTap: () => _onTap(1),
                    ),
                    _BottomNavItem(
                      icon: m.Icons.analytics_outlined,
                      activeIcon: m.Icons.analytics_rounded,
                      label: l10n.navStats,
                      isSelected: currentIndex == 2,
                      onTap: () => _onTap(2),
                    ),
                    _BottomNavItem(
                      icon: m.Icons.tune_outlined,
                      activeIcon: m.Icons.tune_rounded,
                      label: l10n.navSettings,
                      isSelected: currentIndex == 3,
                      indicatorColor: authState.isAuthenticated
                          ? m.Colors.green
                          : null,
                      onTap: () => _onTap(3),
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
  final m.IconData icon;
  final m.IconData activeIcon;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: color,
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.destructive,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: m.Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (indicatorColor != null)
                  Positioned(
                    bottom: 0,
                    right: -2,
                    child: Container(
                      width: 7,
                      height: 7,
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
            const SizedBox(height: 4),
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
