import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/notifiers/deck_notifier.dart';
import 'package:flanki/core/storage/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_test_deck_');
    dbPath = '${tempDir.path}/test_flanki.db';
    await DatabaseService.instance.init(customPath: dbPath);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Deck Creation Tests', () {
    test(
      'addDeck adds new deck and reflects in deckListProvider state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final initialDecks = container.read(deckListProvider);
        expect(initialDecks, isEmpty);

        const newDeck = DeckModel(
          id: 'deck_test_1',
          title: 'Tiếng Anh Giao Tiếp',
          description: 'Bộ từ vựng giao tiếp hàng ngày',
          dueCount: 0,
          newCount: 0,
          totalCount: 0,
        );

        await container.read(deckListProvider.notifier).addDeck(newDeck);

        final updatedDecks = container.read(deckListProvider);
        expect(updatedDecks.length, 1);
        expect(updatedDecks.first.id, 'deck_test_1');
        expect(updatedDecks.first.title, 'Tiếng Anh Giao Tiếp');
        expect(
          updatedDecks.first.description,
          'Bộ từ vựng giao tiếp hàng ngày',
        );

        // Verify persisted in database
        final dbDecks = DatabaseService.instance.getAllDecks();
        expect(dbDecks.length, 1);
        expect(dbDecks.first.title, 'Tiếng Anh Giao Tiếp');
      },
    );

    test('addMultipleDecks and recalculation maintains consistency', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(deckListProvider.notifier);

      await notifier.addDeck(
        const DeckModel(
          id: 'deck_a',
          title: 'Deck A',
          description: 'First',
          dueCount: 0,
          newCount: 0,
          totalCount: 0,
        ),
      );

      await notifier.addDeck(
        const DeckModel(
          id: 'deck_b',
          title: 'Deck B',
          description: 'Second',
          dueCount: 0,
          newCount: 0,
          totalCount: 0,
        ),
      );

      final state = container.read(deckListProvider);
      expect(state.length, 2);
      expect(state.map((d) => d.title), containsAll(['Deck A', 'Deck B']));
    });
  });
}
