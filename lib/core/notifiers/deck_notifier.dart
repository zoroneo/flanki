import 'dart:io' show Platform;
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/deck.dart';
import '../storage/database_service.dart';

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

final deckListProvider = NotifierProvider<DeckNotifier, List<DeckModel>>(
  DeckNotifier.new,
);

class DeckNotifier extends Notifier<List<DeckModel>> {
  @override
  List<DeckModel> build() {
    return DatabaseService.instance.getAllDecks();
  }

  Future<void> refresh() async {
    await DatabaseService.instance.deduplicateDecks();
    state = DatabaseService.instance.getAllDecks();
    await DatabaseService.instance.recalculateAllDeckCounts();
    if (ref.mounted) {
      state = DatabaseService.instance.getAllDecks();
    }
  }

  Future<void> addDecks(List<DeckModel> decks) async {
    await DatabaseService.instance.saveDecks(decks);
    await refresh();
  }

  Future<void> addDeck(DeckModel deck) async {
    await DatabaseService.instance.saveDeck(deck);
    await refresh();
  }

  void createCramDeck({
    required String name,
    required String filterTag,
    int cardLimit = 20,
    String mode = 'byTag',
    String? description,
  }) {
    final encodedTag = Uri.encodeComponent(
      filterTag.isNotEmpty ? filterTag : 'all',
    );
    final actualCount = DatabaseService.instance.countCardsForCustomStudy(
      mode: mode,
      tag: filterTag,
    );
    final count = actualCount > cardLimit ? cardLimit : actualCount;

    final cramDeck = DeckModel(
      id: 'cram_${mode}_${encodedTag}_${cardLimit}_${DateTime.now().millisecondsSinceEpoch}',
      title: '⚡ Cram: $name${filterTag.isNotEmpty ? " (#$filterTag)" : ""}',
      description: description ?? _defaultCramDescription(),
      dueCount: count,
      newCount: 0,
      totalCount: count,
      lastStudied: DateTime.now(),
    );
    DatabaseService.instance.saveDeck(cramDeck);
    refresh();
  }

  static String _defaultCramDescription() {
    try {
      final code = (Platform.localeName.toLowerCase().startsWith('vi'))
          ? 'vi'
          : 'en';
      return lookupAppLocalizations(Locale(code)).cramDeckDefaultDesc;
    } catch (_) {
      return lookupAppLocalizations(const Locale('vi')).cramDeckDefaultDesc;
    }
  }

  void updateDueCount(String deckId, {int? dueCount, int? newCount}) {
    state = state.map((deck) {
      if (deck.id == deckId) {
        final updated = deck.copyWith(
          dueCount: dueCount ?? deck.dueCount,
          newCount: newCount ?? deck.newCount,
          lastStudied: DateTime.now(),
        );
        DatabaseService.instance.saveDeck(updated);
        return updated;
      }
      return deck;
    }).toList();
  }

  void recordStudyProgress(String deckId) {
    state = state.map((deck) {
      if (deck.id == deckId) {
        final remaining = (deck.dueCount > 0) ? deck.dueCount - 1 : 0;
        final updated = deck.copyWith(
          dueCount: remaining,
          lastStudied: DateTime.now(),
        );
        DatabaseService.instance.saveDeck(updated);
        return updated;
      }
      return deck;
    }).toList();
  }

  void deleteDeck(String deckId) {
    DatabaseService.instance.deleteDeck(deckId);
    refresh();
  }
}
