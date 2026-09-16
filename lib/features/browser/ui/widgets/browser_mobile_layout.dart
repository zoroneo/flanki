import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../providers/card_browser_notifier.dart';
import 'card_browser_filter_bar.dart';
import 'card_browser_list_item.dart';

class BrowserMobileLayout extends StatelessWidget {
  final ThemeData theme;
  final dynamic l10n;
  final CardFilterType filterType;
  final CardBrowserNotifier browserNotifier;
  final List<dynamic> decks;
  final Map<String, String> deckMap;
  final List<CardModel> filteredCards;
  final TextEditingController searchController;
  final double topPadding;
  final int visibleCount;
  final bool hasMore;
  final ValueNotifier<int> displayedCount;
  final void Function(CardModel) openCardDetail;

  const BrowserMobileLayout({
    super.key,
    required this.theme,
    required this.l10n,
    required this.filterType,
    required this.browserNotifier,
    required this.decks,
    required this.deckMap,
    required this.filteredCards,
    required this.searchController,
    required this.topPadding,
    required this.visibleCount,
    required this.hasMore,
    required this.displayedCount,
    required this.openCardDetail,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardBottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: SearchHeaderDelegate(
                  topPadding: topPadding,
                  theme: theme,
                  titleRow: _buildTitleRow(),
                  searchBox: _buildSearchBox(),
                  filterRow: _buildFilterRow(),
                ),
              ),
              _buildCardListSliver(),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100 + keyboardBottom,
                ), // allow-magic-dimension
              ),
            ],
          ),
          if (!isKeyboardOpen)
            Positioned(
              bottom: AppSpacing.xl,
              right: AppSpacing.lg,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(AppRoutes.editor);
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.plus,
                      color: theme.colorScheme.primaryForeground,
                      size: AppIconSize.lg,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            l10n.navBrowser,
            style: theme.typography.large.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGaps.h8,
          Text(
            '(${filteredCards.length})',
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: TextField(
        controller: searchController,
        features: [
          InputFeature.leading(
            Icon(
              LucideIcons.search,
              size: AppIconSize.sm,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
        placeholder: Text(l10n.searchCardsPlaceholder),
        onChanged: browserNotifier.setSearchQuery,
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          FilterChip(
            label: l10n.filterAll,
            isSelected: filterType == CardFilterType.all,
            onTap: () => browserNotifier.setFilterType(CardFilterType.all),
          ),
          AppGaps.h8,
          FilterChip(
            label: l10n.filterDue,
            isSelected: filterType == CardFilterType.due,
            onTap: () => browserNotifier.setFilterType(CardFilterType.due),
          ),
          AppGaps.h8,
          FilterChip(
            label: l10n.filterNew,
            isSelected: filterType == CardFilterType.newCard,
            onTap: () => browserNotifier.setFilterType(CardFilterType.newCard),
          ),
          AppGaps.h8,
          FilterChip(
            label: l10n.filterFlagged,
            isSelected: filterType == CardFilterType.flagged,
            onTap: () => browserNotifier.setFilterType(CardFilterType.flagged),
          ),
          AppGaps.h8,
          FilterChip(
            label: l10n.filterSuspended,
            isSelected: filterType == CardFilterType.suspended,
            onTap: () =>
                browserNotifier.setFilterType(CardFilterType.suspended),
          ),
        ],
      ),
    );
  }

  Widget _buildCardListSliver() {
    if (filteredCards.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.searchX,
                size: AppSpacing.xxxl,
                color: theme.colorScheme.mutedForeground,
              ),
              AppGaps.v12,
              Text(
                l10n.noCardsFound,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: AppEdgeInsets.all16,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == visibleCount) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: OutlineButton(
                  child: Text(l10n.loadMoreCards),
                  onPressed: () => displayedCount.value += 30,
                ),
              ),
            );
          }

          final card = filteredCards[index];
          return MobileCardRowItem(
            key: ValueKey('card_${card.id}'),
            card: card,
            deckTitle: deckMap[card.deckId],
            onTap: () => openCardDetail(card),
          );
        }, childCount: visibleCount + (hasMore ? 1 : 0)),
      ),
    );
  }
}
