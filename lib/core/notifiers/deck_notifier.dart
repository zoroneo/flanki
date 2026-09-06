import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deck.dart';

class DeckTreeNode {
  final DeckModel deck;
  final String shortName;
  final int level;
  final List<DeckTreeNode> children;
  bool isExpanded;

  DeckTreeNode({
    required this.deck,
    required this.shortName,
    required this.level,
    this.children = const [],
    this.isExpanded = true,
  });
}

final deckListProvider =
    NotifierProvider<DeckNotifier, List<DeckModel>>(DeckNotifier.new);

class DeckNotifier extends Notifier<List<DeckModel>> {
  @override
  List<DeckModel> build() {
    return [
      DeckModel(
        id: 'deck-toeic-600',
        title: 'TOEIC::600 Essential Vocabulary',
        description: '600 từ vựng cốt lõi thường xuất hiện trong đề thi TOEIC format mới.',
        dueCount: 24,
        newCount: 10,
        totalCount: 600,
        lastStudied: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      DeckModel(
        id: 'deck-toeic-grammar',
        title: 'TOEIC::Grammar Tactics',
        description: 'Ngữ pháp Part 5 & 6 bẫy thì và mệnh đề quan hệ.',
        dueCount: 8,
        newCount: 4,
        totalCount: 150,
        lastStudied: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DeckModel(
        id: 'deck-oxford-4000',
        title: 'Languages::English::4000 Essential Words',
        description: 'Bộ từ vựng giao tiếp và học thuật chuẩn Paul Nation (kèm giải nghĩa Tiếng Việt).',
        dueCount: 18,
        newCount: 5,
        totalCount: 600,
        lastStudied: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DeckModel(
        id: 'deck-flutter-rust',
        title: 'Engineering::Flutter & Rust Architecture',
        description: 'Kiến trúc C ABI, memory safety, Dart FFI và FSRS Spaced Repetition.',
        dueCount: 7,
        newCount: 3,
        totalCount: 120,
        lastStudied: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  void addDecks(List<DeckModel> decks) {
    // Avoid duplicate deck ids
    final existingIds = state.map((d) => d.id).toSet();
    final newDecks = decks.where((d) => !existingIds.contains(d.id)).toList();
    state = [...newDecks, ...state];
  }

  void addDeck(DeckModel deck) {
    state = [...state, deck];
  }

  void createCramDeck({
    required String name,
    required String filterTag,
    int cardLimit = 20,
  }) {
    final cramDeck = DeckModel(
      id: 'cram-${DateTime.now().millisecondsSinceEpoch}',
      title: '⚡ Cram: $name (#$filterTag)',
      description: 'Bộ thẻ ôn tập đột xuất (Custom Study) không ảnh hưởng lịch FSRS chính.',
      dueCount: cardLimit,
      newCount: 0,
      totalCount: cardLimit,
      lastStudied: DateTime.now(),
    );
    state = [cramDeck, ...state];
  }

  void updateDueCount(String deckId, {int? dueCount, int? newCount}) {
    state = state.map((deck) {
      if (deck.id == deckId) {
        return deck.copyWith(
          dueCount: dueCount ?? deck.dueCount,
          newCount: newCount ?? deck.newCount,
          lastStudied: DateTime.now(),
        );
      }
      return deck;
    }).toList();
  }

  void recordStudyProgress(String deckId) {
    state = state.map((deck) {
      if (deck.id == deckId) {
        final remaining = (deck.dueCount > 0) ? deck.dueCount - 1 : 0;
        return deck.copyWith(
          dueCount: remaining,
          lastStudied: DateTime.now(),
        );
      }
      return deck;
    }).toList();
  }

  void deleteDeck(String deckId) {
    state = state.where((d) => d.id != deckId).toList();
  }
}
