import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../core/localization/locale_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
import '../../core/notifiers/card_browser_notifier.dart';
import '../../core/notifiers/stats_notifier.dart';
import '../../core/auth/auth_notifier.dart';
import 'navigation/desktop_sidebar.dart';
import 'navigation/mobile_bottom_nav_bar.dart';
import 'navigation/tablet_nav_rail.dart';

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
    final totalDue = ref.watch(
      deckListProvider.select(
        (decks) => decks.fold<int>(0, (sum, d) => sum + d.dueCount),
      ),
    );
    final isAuthenticated = ref.watch(
      authNotifierProvider.select((s) => s.isAuthenticated),
    );
    final l10n = context.l10n;

    final currentIndex = navigationShell.currentIndex;

    return CallbackShortcuts(
      bindings: _buildKeyboardShortcuts(ref),
      child: Focus(
        autofocus: true,
        child: ScreenTypeLayout.builder(
          mobile: (context) => _buildMobileLayout(
            theme: theme,
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            ref: ref,
          ),
          tablet: (context) => _buildTabletLayout(
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            ref: ref,
          ),
          desktop: (context) => _buildDesktopLayout(
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            ref: ref,
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildKeyboardShortcuts(WidgetRef ref) {
    return <ShortcutActivator, VoidCallback>{
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
    };
  }

  Widget _buildMobileLayout({
    required ThemeData theme,
    required int currentIndex,
    required int totalDue,
    required bool isAuthenticated,
    required dynamic l10n,
    required WidgetRef ref,
  }) {
    return Scaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          MobileBottomNavBar(
            theme: theme,
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            onTap: (index) => _onTap(index, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout({
    required int currentIndex,
    required int totalDue,
    required bool isAuthenticated,
    required dynamic l10n,
    required WidgetRef ref,
  }) {
    return Scaffold(
      child: Row(
        children: [
          TabletNavRail(
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            onSelectTab: (index) => _onTap(index, ref),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout({
    required int currentIndex,
    required int totalDue,
    required bool isAuthenticated,
    required dynamic l10n,
    required WidgetRef ref,
  }) {
    return Scaffold(
      child: Row(
        children: [
          DesktopSidebar(
            currentIndex: currentIndex,
            totalDue: totalDue,
            isAuthenticated: isAuthenticated,
            l10n: l10n,
            onSelectTab: (index) => _onTap(index, ref),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
