import 'dart:math' as math;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../study/widgets/card_action_sheet.dart';
import 'widgets/card_browser_filter_bar.dart';
import 'widgets/card_browser_list_item.dart';
import 'widgets/desktop_card_detail_pane.dart';

class CardBrowserScreen extends HookConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final filteredCards = ref.watch(
      cardBrowserProvider.select((s) => s.filteredCards),
    );
    final filterType = ref.watch(
      cardBrowserProvider.select((s) => s.filterType),
    );
    final searchQuery = ref.watch(
      cardBrowserProvider.select((s) => s.searchQuery),
    );
    final selectedDeckId = ref.watch(
      cardBrowserProvider.select((s) => s.selectedDeckId),
    );
    final browserNotifier = ref.read(cardBrowserProvider.notifier);
    final decks = ref.watch(deckListProvider);
    final deckMap = {for (final d in decks) d.id: d.title};

    final searchController = useTextEditingController(text: searchQuery);

    // Desktop selected card ID state
    final selectedCardId = useState<String?>(null);

    // Auto-select first card if selection is invalid or null on desktop
    if (filteredCards.isNotEmpty &&
        (selectedCardId.value == null ||
            !filteredCards.any((c) => c.id == selectedCardId.value))) {
      selectedCardId.value = filteredCards.first.id;
    } else if (filteredCards.isEmpty) {
      selectedCardId.value = null;
    }

    const pageSize = 30;
    final displayedCount = useState(pageSize);

    useEffect(() {
      displayedCount.value = pageSize;
      return null;
    }, [searchQuery, filterType, selectedDeckId]);

    final visibleCount = math.min(displayedCount.value, filteredCards.length);
    final hasMore = visibleCount < filteredCards.length;

    void openCardDetail(CardModel card) {
      CardActionSheet.show(
        context,
        card: card,
        onSetFlag: (flag) => browserNotifier.setCardFlag(card.id, flag),
        onBury: () => browserNotifier.toggleCardBury(card.id),
        onSuspend: () => browserNotifier.toggleCardSuspend(card.id),
        onDelete: () => browserNotifier.deleteCard(card.id),
        onEdit: (f, b) {
          browserNotifier.updateCard(card.copyWith(front: f, back: b));
        },
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return ScreenTypeLayout.builder(
      desktop: (context) => _buildDesktopLayout(
        context: context,
        theme: theme,
        l10n: l10n,
        filterType: filterType,
        browserNotifier: browserNotifier,
        decks: decks,
        deckMap: deckMap,
        filteredCards: filteredCards,
        selectedCardId: selectedCardId,
        searchController: searchController,
      ),
      mobile: (context) => _buildMobileLayout(
        context: context,
        theme: theme,
        l10n: l10n,
        filterType: filterType,
        browserNotifier: browserNotifier,
        decks: decks,
        deckMap: deckMap,
        filteredCards: filteredCards,
        searchController: searchController,
        topPadding: topPadding,
        visibleCount: visibleCount,
        hasMore: hasMore,
        displayedCount: displayedCount,
        openCardDetail: openCardDetail,
      ),
    );
  }

  Widget _buildDesktopLayout({
    required BuildContext context,
    required ThemeData theme,
    required dynamic l10n,
    required CardFilterType filterType,
    required CardBrowserNotifier browserNotifier,
    required List<dynamic> decks,
    required Map<String, String> deckMap,
    required List<CardModel> filteredCards,
    required ValueNotifier<String?> selectedCardId,
    required TextEditingController searchController,
  }) {
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
                _buildDesktopSearchBar(
                  context,
                  theme,
                  l10n,
                  searchController,
                  browserNotifier,
                ),
                _buildDesktopFilterBar(
                  context,
                  theme,
                  l10n,
                  filterType,
                  browserNotifier,
                  decks,
                ),
                const Divider(height: 1),
                _buildDesktopHeaderCount(theme, l10n, filteredCards.length),
                Expanded(
                  child: _buildDesktopCardList(
                    filteredCards: filteredCards,
                    selectedCardId: selectedCardId,
                    theme: theme,
                    l10n: l10n,
                  ),
                ),
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
                : _buildDesktopEmptyPreview(theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSearchBar(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    TextEditingController searchController,
    CardBrowserNotifier browserNotifier,
  ) {
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
              onPressed: () => context.push('/cards/new'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopFilterBar(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    CardFilterType filterType,
    CardBrowserNotifier browserNotifier,
    List<dynamic> decks,
  ) {
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

  Widget _buildDesktopHeaderCount(ThemeData theme, dynamic l10n, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.muted.withValues(alpha: 0.3),
      child: Row(
        children: [
          Text(
            l10n.cardsCount(count),
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

  Widget _buildDesktopCardList({
    required List<CardModel> filteredCards,
    required ValueNotifier<String?> selectedCardId,
    required ThemeData theme,
    required dynamic l10n,
  }) {
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

  Widget _buildDesktopEmptyPreview(ThemeData theme, dynamic l10n) {
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

  Widget _buildMobileLayout({
    required BuildContext context,
    required ThemeData theme,
    required dynamic l10n,
    required CardFilterType filterType,
    required CardBrowserNotifier browserNotifier,
    required List<dynamic> decks,
    required Map<String, String> deckMap,
    required List<CardModel> filteredCards,
    required TextEditingController searchController,
    required double topPadding,
    required int visibleCount,
    required bool hasMore,
    required ValueNotifier<int> displayedCount,
    required void Function(CardModel) openCardDetail,
  }) {
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
                  titleRow: _buildMobileTitleRow(
                    theme,
                    l10n,
                    filteredCards.length,
                  ),
                  searchBox: _buildMobileSearchBox(
                    theme,
                    l10n,
                    searchController,
                    browserNotifier,
                  ),
                  filterRow: _buildMobileFilterRow(
                    l10n,
                    filterType,
                    browserNotifier,
                  ),
                ),
              ),
              _buildMobileCardListSliver(
                filteredCards: filteredCards,
                deckMap: deckMap,
                visibleCount: visibleCount,
                hasMore: hasMore,
                displayedCount: displayedCount,
                openCardDetail: openCardDetail,
                theme: theme,
                l10n: l10n,
              ),
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
              onPressed: () => context.push('/cards/new'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTitleRow(ThemeData theme, dynamic l10n, int count) {
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
            '($count)',
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBox(
    ThemeData theme,
    dynamic l10n,
    TextEditingController searchController,
    CardBrowserNotifier browserNotifier,
  ) {
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

  Widget _buildMobileFilterRow(
    dynamic l10n,
    CardFilterType filterType,
    CardBrowserNotifier browserNotifier,
  ) {
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

  Widget _buildMobileCardListSliver({
    required List<CardModel> filteredCards,
    required Map<String, String> deckMap,
    required int visibleCount,
    required bool hasMore,
    required ValueNotifier<int> displayedCount,
    required void Function(CardModel) openCardDetail,
    required ThemeData theme,
    required dynamic l10n,
  }) {
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
