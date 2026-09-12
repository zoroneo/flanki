import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/card.dart';
import '../../../core/storage/database_service.dart';
import '../../decks/providers/deck_notifier.dart';
import '../models/card_browser_state.dart';

export '../models/card_browser_state.dart';

part 'card_browser_notifier.g.dart';

@Riverpod(keepAlive: true, name: 'cardBrowserProvider')
class CardBrowserNotifier extends _$CardBrowserNotifier {
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
