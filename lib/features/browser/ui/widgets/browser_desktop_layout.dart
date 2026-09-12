import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../providers/card_browser_notifier.dart';
import 'card_browser_filter_bar.dart';
import 'card_browser_list_item.dart';
import 'desktop_card_detail_pane.dart';

class BrowserDesktopLayout extends StatelessWidget {
  final ThemeData theme;
  final dynamic l10n;
  final CardFilterType filterType;
  final CardBrowserNotifier browserNotifier;
  final List<dynamic> decks;
  final Map<String, String> deckMap;
  final List<CardModel> filteredCards;
  final ValueNotifier<String?> selectedCardId;
  final TextEditingController searchController;

  const BrowserDesktopLayout({
    super.key,
    required this.theme,
    required this.l10n,
    required this.filterType,
    required this.browserNotifier,
    required this.decks,
    required this.deckMap,
    required this.filteredCards,
    required this.selectedCardId,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final currentSelectedCard = filteredCards.cast<CardModel?>().firstWhere(
      (c) => c?.id == selectedCardId.value,
      orElse: () => filteredCards.isNotEmpty ? filteredCards.first : null,
    );

    return Scaffold(
      child: Row(
        children: [
          // Left Column: Search, Filters & Card Table (Width: 420px)
          SizedBox(
            width: 420,
            child: Column(
              children: [
                _buildSearchBar(context),
                _buildFilterBar(),
                const Divider(height: 1),
                _buildHeaderCount(),
                Expanded(child: _buildCardList()),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right Column: Detail / Preview Pane
          Expanded(
            child: currentSelectedCard != null
                ? DesktopCardDetailPane(
                    key: ValueKey(currentSelectedCard.id),
                    card: currentSelectedCard,
                    deckTitle: deckMap[currentSelectedCard.deckId],
                    browserNotifier: browserNotifier,
                  )
                : _buildEmptyPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            Expanded(
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
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              size: ButtonSize.small,
              leading: const Icon(LucideIcons.plus, size: 14),
              child: Text(l10n.addCard),
              onPressed: () => context.push('/editor'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
              onTap: () =>
                  browserNotifier.setFilterType(CardFilterType.newCard),
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: l10n.filterFlagged,
              isSelected: filterType == CardFilterType.flagged,
              onTap: () =>
                  browserNotifier.setFilterType(CardFilterType.flagged),
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
      ),
    );
  }

  Widget _buildHeaderCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.muted.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text(
            l10n.cardsCount(filteredCards.length),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList() {
    if (filteredCards.isEmpty) {
      return Center(
        child: Text(
          l10n.noCardsFound,
          style: theme.typography.small.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredCards.length,
      itemBuilder: (context, index) {
        final card = filteredCards[index];
        final isSelected = card.id == selectedCardId.value;

        return DesktopCardRowItem(
          key: ValueKey(card.id),
          card: card,
          isSelected: isSelected,
          onTap: () => selectedCardId.value = card.id,
        );
      },
    );
  }

  Widget _buildEmptyPreview() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.fileQuestion,
            size: 48,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noCardSelected,
            style: TextStyle(color: theme.colorScheme.mutedForeground),
          ),
        ],
      ),
    );
  }
}
