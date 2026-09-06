import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';

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
          if (card.due == null && card.intervalDays == 0) return false;
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
    // Initial sample collection data matching Anki structure
    final sampleCards = [
      CardModel(
        id: 'c1',
        deckId: 'deck-toeic-600',
        front: 'Abundant (adj)',
        back: 'Dồi dào, phong phú, thừa thãi\n\nVí dụ: Fish are abundant in this lake.',
        hint: 'Nhiều hơn mức bình thường',
        tags: ['vocabulary', 'toeic', 'c1'],
        intervalDays: 1,
        stability: 2.1,
        difficulty: 3.4,
        reps: 2,
        flag: 1, // Red
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CardModel(
        id: 'c2',
        deckId: 'deck-flutter-rust',
        front: 'FSRS (Free Spaced Repetition Scheduler)',
        back: 'Thuật toán lặp lại ngắt quãng thế hệ mới dựa trên mô hình DSR (Difficulty, Stability, Retrievability) tối ưu hơn SM-2.',
        hint: 'Thuật toán học tập lõi của Anki hiện đại',
        tags: ['algorithm', 'anki', 'fsrs'],
        intervalDays: 3,
        stability: 4.8,
        difficulty: 4.1,
        reps: 4,
        flag: 4, // Blue
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CardModel(
        id: 'c3',
        deckId: 'deck-oxford-4000',
        front: 'Pragmatic (adj)',
        back: 'Thực dụng, thực tế, giải quyết vấn đề dựa trên hiệu quả thực tiễn thay vì lý thuyết suông.',
        hint: 'Từ trái nghĩa với idealistic',
        tags: ['philosophy', 'vocabulary'],
        intervalDays: 5,
        stability: 7.2,
        difficulty: 2.9,
        reps: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      CardModel(
        id: 'c4',
        deckId: 'deck-flutter-rust',
        front: 'Zero-cost Abstraction (Rust)',
        back: 'Những gì bạn không dùng thì không phải trả giá; những gì bạn dùng thì bạn không thể tự viết tay tốt hơn compiler tối ưu.',
        hint: 'Nguyên lý cốt lõi của Bjarne Stroustrup & Rust',
        tags: ['rust', 'programming'],
        intervalDays: 7,
        stability: 11.5,
        difficulty: 5.0,
        reps: 8,
        flag: 3, // Green
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      CardModel(
        id: 'c5',
        deckId: 'deck-toeic-600',
        front: '{{c1::Acquire}} (verb)',
        back: 'Đạt được, thu được, học được (kỹ năng/kiến thức)\n\nVí dụ: She acquired a good knowledge of English.',
        noteType: 'cloze',
        tags: ['cloze', 'toeic'],
        intervalDays: 0,
        reps: 0, // New card
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CardModel(
        id: 'c6',
        deckId: 'deck-toeic-600',
        front: 'Obsolete (adj)',
        back: 'Lỗi thời, không còn được sử dụng',
        tags: ['toeic'],
        isSuspended: true, // Suspended card
        intervalDays: 0,
        reps: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    return CardBrowserState(allCards: sampleCards);
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

  void addCards(List<CardModel> cards) {
    state = state.copyWith(allCards: [...cards, ...state.allCards]);
  }

  void addCard(CardModel card) {
    state = state.copyWith(allCards: [card, ...state.allCards]);
  }

  void updateCard(CardModel updatedCard) {
    state = state.copyWith(
      allCards: state.allCards.map((c) {
        return c.id == updatedCard.id ? updatedCard : c;
      }).toList(),
    );
  }

  void toggleCardSuspend(String cardId) {
    state = state.copyWith(
      allCards: state.allCards.map((c) {
        if (c.id == cardId) {
          return c.copyWith(isSuspended: !c.isSuspended);
        }
        return c;
      }).toList(),
    );
  }

  void setCardFlag(String cardId, int flagColor) {
    state = state.copyWith(
      allCards: state.allCards.map((c) {
        if (c.id == cardId) {
          final newFlag = (c.flag == flagColor) ? 0 : flagColor;
          return c.copyWith(flag: newFlag);
        }
        return c;
      }).toList(),
    );
  }

  void deleteCard(String cardId) {
    state = state.copyWith(
      allCards: state.allCards.where((c) => c.id != cardId).toList(),
    );
  }
}
