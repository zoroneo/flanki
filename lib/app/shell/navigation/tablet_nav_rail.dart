import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/core/theme/app_tokens.dart';
import 'package:flanki/features/decks/providers/deck_notifier.dart';
import 'package:flanki/features/sync/providers/auth_notifier.dart';

class TabletNavRail extends ConsumerWidget {
  final int currentIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelectTab;

  const TabletNavRail({
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
      width: AppDimensions.navRailWidth,
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Column(
        children: [
          _buildBrandIcon(theme),
          const Divider(height: AppDimensions.hairline),
          AppGaps.v12,
          _buildNavItems(context, theme, totalDue, isAuthenticated),
          const Spacer(),
          _buildSyncIndicator(context, theme, isAuthenticated),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Tooltip(
        tooltip: (context) =>
            const TooltipContainer(child: Text(AppConfig.appName)),
        child: Container(
          width: AppDimensions.brandIconTablet,
          height: AppDimensions.brandIconTablet,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: AppRadius.borderMd,
          ),
          child: Center(
            child: Icon(
              LucideIcons.zap,
              color: theme.colorScheme.primaryForeground,
              size: AppIconSize.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItems(
    BuildContext context,
    ThemeData theme,
    int totalDue,
    bool isAuthenticated,
  ) {
    return Column(
      children: [
        NavRailItem(
          icon: LucideIcons.layers,
          activeIcon: LucideIcons.layers2,
          label: l10n.navDecks,
          shortcutHint: AppKeyboardShortcuts.navDecks,
          isSelected: currentIndex == AppNavIndex.decks,
          badgeCount: totalDue > 0 ? totalDue : null,
          onTap: () => onSelectTab(AppNavIndex.decks),
        ),
        AppGaps.v8,
        NavRailItem(
          icon: LucideIcons.search,
          activeIcon: LucideIcons.fileSearch,
          label: l10n.navBrowser,
          shortcutHint: AppKeyboardShortcuts.navBrowser,
          isSelected: currentIndex == AppNavIndex.browser,
          onTap: () => onSelectTab(AppNavIndex.browser),
        ),
        AppGaps.v8,
        NavRailItem(
          icon: LucideIcons.bookOpenText,
          activeIcon: LucideIcons.bookOpen,
          label: l10n.navGrammar,
          shortcutHint: AppKeyboardShortcuts.navGrammar,
          isSelected: currentIndex == AppNavIndex.grammar,
          onTap: () => onSelectTab(AppNavIndex.grammar),
        ),
        AppGaps.v8,
        NavRailItem(
          icon: LucideIcons.graduationCap,
          activeIcon: LucideIcons.graduationCap,
          label: l10n.navExams,
          shortcutHint: AppKeyboardShortcuts.navExams,
          isSelected: currentIndex == AppNavIndex.exams,
          onTap: () => onSelectTab(AppNavIndex.exams),
        ),
        AppGaps.v8,
        NavRailItem(
          icon: LucideIcons.chartColumn,
          activeIcon: LucideIcons.chartNoAxesCombined,
          label: l10n.navStats,
          shortcutHint: AppKeyboardShortcuts.navStats,
          isSelected: currentIndex == AppNavIndex.stats,
          onTap: () => onSelectTab(AppNavIndex.stats),
        ),
        AppGaps.v8,
        NavRailItem(
          icon: LucideIcons.settings,
          activeIcon: LucideIcons.settings2,
          label: l10n.navSettings,
          shortcutHint: AppKeyboardShortcuts.navSettings,
          isSelected: currentIndex == AppNavIndex.settings,
          indicatorColor: isAuthenticated ? context.colors.success : null,
          onTap: () => onSelectTab(AppNavIndex.settings),
        ),
      ],
    );
  }

  Widget _buildSyncIndicator(
    BuildContext context,
    ThemeData theme,
    bool isAuthenticated,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Tooltip(
        tooltip: (context) => TooltipContainer(
          child: Text(
            '${l10n.syncAnkiWeb}: ${isAuthenticated ? l10n.connected : l10n.offlineMode}',
          ),
        ),
        child: Container(
          width: AppDimensions.brandIconDesktop,
          height: AppDimensions.brandIconDesktop,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.6),
            ),
          ),
          child: Center(
            child: Container(
              width: AppDimensions.statusDotSize,
              height: AppDimensions.statusDotSize,
              decoration: BoxDecoration(
                color: isAuthenticated
                    ? context.colors.success
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
            width: AppDimensions.navRailItemSize,
            height: AppDimensions.navRailItemSize,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : AppColors.transparent,
              borderRadius: AppRadius.borderMd,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: AppIconSize.lg,
                  color: color,
                ),
                if (badgeCount != null)
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: _buildBadge(context, theme),
                  ),
                if (indicatorColor != null)
                  Positioned(
                    bottom: AppSpacing.s6,
                    right: AppSpacing.s6,
                    child: _buildIndicator(theme),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, ThemeData theme) {
    return Container(
      padding: AppEdgeInsets.badge,
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        badgeCount! > AppLimits.badgeMaxCount
            ? AppLimits.badgeOverflowText
            : '$badgeCount',
        style: context.textStyles.badge.copyWith(color: AppColors.white),
      ),
    );
  }

  Widget _buildIndicator(ThemeData theme) {
    return Container(
      width: AppDimensions.indicatorDotSize,
      height: AppDimensions.indicatorDotSize,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.background,
          width: AppDimensions.borderFocus,
        ),
      ),
    );
  }
}
