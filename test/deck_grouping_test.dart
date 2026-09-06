import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/models/deck.dart';

void main() {
  group('Deck Grouping Tests', () {
    test('Hierarchical decks with Parent::Child are grouped by parent', () {
      final decks = [
        const DeckModel(
          id: 'deck-1',
          title: '4000 Essential English Words - Book 1::Unit 01',
          description: 'Desc 1',
          dueCount: 2,
          newCount: 18,
          totalCount: 20,
        ),
        const DeckModel(
          id: 'deck-2',
          title: '4000 Essential English Words - Book 1::Unit 02',
          description: 'Desc 2',
          dueCount: 0,
          newCount: 20,
          totalCount: 20,
        ),
        const DeckModel(
          id: 'deck-standalone',
          title: 'Basic Japanese',
          description: 'Kana and Kanji',
          dueCount: 5,
          newCount: 10,
          totalCount: 50,
        ),
      ];

      final Map<String, List<DeckModel>> groupedMap = {};
      final List<DeckModel> standaloneDecks = [];

      for (final deck in decks) {
        if (deck.title.contains('::')) {
          final parts = deck.title.split('::');
          final parentName = parts.sublist(0, parts.length - 1).join(' › ');
          groupedMap.putIfAbsent(parentName, () => []).add(deck);
        } else {
          standaloneDecks.add(deck);
        }
      }

      for (final parent in groupedMap.keys) {
        standaloneDecks.removeWhere((d) => d.title == parent);
      }

      expect(groupedMap.length, 1);
      expect(groupedMap.containsKey('4000 Essential English Words - Book 1'), isTrue);
      expect(groupedMap['4000 Essential English Words - Book 1']!.length, 2);

      final groupSubdecks = groupedMap['4000 Essential English Words - Book 1']!;
      final totalDue = groupSubdecks.fold<int>(0, (sum, d) => sum + d.dueCount);
      final totalNew = groupSubdecks.fold<int>(0, (sum, d) => sum + d.newCount);
      final totalCards = groupSubdecks.fold<int>(0, (sum, d) => sum + d.totalCount);

      expect(totalDue, 2);
      expect(totalNew, 38);
      expect(totalCards, 40);

      expect(standaloneDecks.length, 1);
      expect(standaloneDecks.first.title, 'Basic Japanese');
    });
  });
}
