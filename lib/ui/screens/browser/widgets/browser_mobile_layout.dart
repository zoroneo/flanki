import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/notifiers/card_browser_notifier.dart';
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
    return Scaffold(
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: PrimaryButton(
              size: ButtonSize.large,
              leading: const Icon(LucideIcons.plus, size: 20),
              child: Text(l10n.addCard),
              onPressed: () => context.push('/editor'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            l10n.navBrowser,
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(
            '(${filteredCards.length})',
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: searchController,
        features: [
          InputFeature.leading(
            Icon(
              LucideIcons.search,
              size: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: l10n.filterAll,
            isSelected: filterType == CardFilterType.all,
            onTap: () => browserNotifier.setFilterType(CardFilterType.all),
          ),
          const SizedBox(width: 6),
          FilterChip(
            label: l10n.filterDue,
            isSelected: filterType == CardFilterType.due,
            onTap: () => browserNotifier.setFilterType(CardFilterType.due),
          ),
          const SizedBox(width: 6),
          FilterChip(
            label: l10n.filterNew,
            isSelected: filterType == CardFilterType.newCard,
            onTap: () => browserNotifier.setFilterType(CardFilterType.newCard),
          ),
          const SizedBox(width: 6),
          FilterChip(
            label: l10n.filterFlagged,
            isSelected: filterType == CardFilterType.flagged,
            onTap: () => browserNotifier.setFilterType(CardFilterType.flagged),
          ),
          const SizedBox(width: 6),
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
                size: 48,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == visibleCount) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
