import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/card.dart';

part 'card_browser_state.freezed.dart';

enum CardFilterType { all, due, newCard, flagged, suspended }

@freezed
abstract class CardBrowserState with _$CardBrowserState {
  const CardBrowserState._();

  const factory CardBrowserState({
    @Default([]) List<CardModel> allCards,
    @Default('') String searchQuery,
    @Default(CardFilterType.all) CardFilterType filterType,
    String? selectedDeckId,
  }) = _CardBrowserState;

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
}
