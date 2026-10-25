import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/theme/app_tokens.dart';
import 'package:flanki/app/shell/navigation/widgets/sidebar_brand_header.dart';
import 'package:flanki/app/shell/navigation/widgets/sidebar_nav_item.dart';
import 'package:flanki/app/shell/navigation/widgets/sidebar_sync_status.dart';
import 'package:flanki/features/decks/providers/deck_notifier.dart';
import 'package:flanki/features/sync/providers/auth_notifier.dart';

class DesktopSidebar extends ConsumerWidget {
  final int currentIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelectTab;

  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.l10n,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalDue = ref.watch(totalDueCountProvider);
    final isAuthenticated = ref.watch(
      authNotifierProvider.select((s) => s.isAuthenticated),
    );

    return Container(
      width: AppDimensions.sidebarWidth,
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarBrandHeader(l10n: l10n),
          const Divider(height: AppDimensions.hairline),
          AppGaps.v12,
          _buildNavLinks(context, totalDue, isAuthenticated),
          const Spacer(),
          SidebarSyncStatus(isAuthenticated: isAuthenticated, l10n: l10n),
        ],
      ),
    );
  }

  Widget _buildNavLinks(
    BuildContext context,
    int totalDue,
    bool isAuthenticated,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smPlus),
      child: Column(
        children: [
          SidebarNavItem(
            icon: LucideIcons.layers,
            activeIcon: LucideIcons.layers2,
            label: l10n.navDecks,
            shortcutHint: AppKeyboardShortcuts.navDecks,
            isSelected: currentIndex == AppNavIndex.decks,
            badgeCount: totalDue > 0 ? totalDue : null,
            onTap: () => onSelectTab(AppNavIndex.decks),
          ),
          AppGaps.v4,
          SidebarNavItem(
            icon: LucideIcons.search,
            activeIcon: LucideIcons.fileSearch,
            label: l10n.navBrowser,
            shortcutHint: AppKeyboardShortcuts.navBrowser,
            isSelected: currentIndex == AppNavIndex.browser,
            onTap: () => onSelectTab(AppNavIndex.browser),
          ),
          AppGaps.v4,
          SidebarNavItem(
            icon: LucideIcons.bookOpenText,
            activeIcon: LucideIcons.bookOpen,
            label: l10n.navGrammar,
            shortcutHint: AppKeyboardShortcuts.navGrammar,
            isSelected: currentIndex == AppNavIndex.grammar,
            onTap: () => onSelectTab(AppNavIndex.grammar),
          ),
          AppGaps.v4,
          SidebarNavItem(
            icon: LucideIcons.graduationCap,
            activeIcon: LucideIcons.graduationCap,
            label: l10n.navExams,
            shortcutHint: AppKeyboardShortcuts.navExams,
            isSelected: currentIndex == AppNavIndex.exams,
            onTap: () => onSelectTab(AppNavIndex.exams),
          ),
          AppGaps.v4,
          SidebarNavItem(
            icon: LucideIcons.chartColumn,
            activeIcon: LucideIcons.chartNoAxesCombined,
            label: l10n.navStats,
            shortcutHint: AppKeyboardShortcuts.navStats,
            isSelected: currentIndex == AppNavIndex.stats,
            onTap: () => onSelectTab(AppNavIndex.stats),
          ),
          AppGaps.v4,
          SidebarNavItem(
            icon: LucideIcons.settings,
            activeIcon: LucideIcons.settings2,
            label: l10n.navSettings,
            shortcutHint: AppKeyboardShortcuts.navSettings,
            isSelected: currentIndex == AppNavIndex.settings,
            indicatorColor: isAuthenticated ? context.colors.success : null,
            onTap: () => onSelectTab(AppNavIndex.settings),
          ),
        ],
      ),
    );
  }
}
