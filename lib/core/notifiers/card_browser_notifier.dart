import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../storage/database_service.dart';
import 'deck_notifier.dart';

enum CardFilterType {
  all,
  due,
  newCard,
  flagged,
  suspended,
}

class CardBrowserState {
  final List<CardModel> allCards;
  final String searchQuery;
  final CardFilterType filterType;
  final String? selectedDeckId;

  const CardBrowserState({
    required this.allCards,
    this.searchQuery = '',
    this.filterType = CardFilterType.all,
    this.selectedDeckId,
  });

  List<CardModel> get filteredCards {
    final now = DateTime.now();
    return allCards.where((card) {
      // Deck filter
      if (selectedDeckId != null && card.deckId != selectedDeckId) {
        return false;
      }

      // Filter type
      switch (filterType) {
        case CardFilterType.all:
          break;
        case CardFilterType.due:
          if (card.due == null) return false;
          if (card.due!.isAfter(now)) return false;
          break;
        case CardFilterType.newCard:
          if (card.reps > 0) return false;
          break;
        case CardFilterType.flagged:
          if (!card.hasFlag) return false;
          break;
        case CardFilterType.suspended:
          if (!card.isSuspended) return false;
          break;
      }

      // Query filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchFront = card.front.toLowerCase().contains(q);
        final matchBack = card.back.toLowerCase().contains(q);
        final matchTags = card.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchFront && !matchBack && !matchTags) return false;
      }

      return true;
    }).toList();
  }

  CardBrowserState copyWith({
    List<CardModel>? allCards,
    String? searchQuery,
    CardFilterType? filterType,
    String? selectedDeckId,
  }) {
    return CardBrowserState(
      allCards: allCards ?? this.allCards,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      selectedDeckId: selectedDeckId ?? this.selectedDeckId,
    );
  }
}

final cardBrowserProvider =
    NotifierProvider<CardBrowserNotifier, CardBrowserState>(
  CardBrowserNotifier.new,
);

class CardBrowserNotifier extends Notifier<CardBrowserState> {
  @override
  CardBrowserState build() {
    final cards = DatabaseService.instance.getAllCards();
    return CardBrowserState(allCards: cards);
  }

  void refresh() {
    final cards = DatabaseService.instance.getAllCards();
    state = state.copyWith(allCards: cards);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterType(CardFilterType filter) {
    state = state.copyWith(filterType: filter);
  }

  void setSelectedDeck(String? deckId) {
    state = state.copyWith(selectedDeckId: deckId);
  }

  Future<void> addCards(List<CardModel> cards) async {
    await DatabaseService.instance.saveCards(cards);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> addCard(CardModel card) async {
    await DatabaseService.instance.saveCard(card);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> updateCard(CardModel updatedCard) async {
    await DatabaseService.instance.saveCard(updatedCard);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> toggleCardSuspend(String cardId) async {
    final card = state.allCards.firstWhere((c) => c.id == cardId);
    final updated = card.copyWith(isSuspended: !card.isSuspended);
    await DatabaseService.instance.saveCard(updated);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> toggleCardBury(String cardId) async {
    final card = state.allCards.firstWhere((c) => c.id == cardId);
    final updated = card.copyWith(isBuried: !card.isBuried);
    await DatabaseService.instance.saveCard(updated);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> setCardFlag(String cardId, CardFlag flagColor) async {
    final card = state.allCards.firstWhere((c) => c.id == cardId);
    final newFlag = (card.flag == flagColor) ? CardFlag.none : flagColor;
    final updated = card.copyWith(flag: newFlag);
    await DatabaseService.instance.saveCard(updated);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }

  Future<void> deleteCard(String cardId) async {
    await DatabaseService.instance.deleteCard(cardId);
    refresh();
    await ref.read(deckListProvider.notifier).refresh();
  }
}
