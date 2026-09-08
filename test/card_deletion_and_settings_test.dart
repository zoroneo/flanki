import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/notifiers/card_browser_notifier.dart';
import 'package:flanki/core/notifiers/settings_notifier.dart';
import 'package:flanki/core/storage/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('card_test_');
    dbPath = '${tempDir.path}/test_db.sqlite';
    await DatabaseService.instance.init(customPath: dbPath);

    await DatabaseService.instance.saveDeck(
      const DeckModel(
        id: 'deck_1',
        title: 'Deck 1',
        description: 'Deck description',
        dueCount: 0,
        newCount: 0,
        totalCount: 0,
      ),
    );
  });

  tearDown(() async {
    try {
      await DatabaseService.instance.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('Card Deletion and Undo Tests', () {
    test(
      'Browser notifier deleteCard removes card and addCard restores it',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final card = CardModel(
          id: 'card_to_delete',
          deckId: 'deck_1',
          front: 'Delete Front',
          back: 'Delete Back',
          createdAt: DateTime.now(),
        );

        // Add card initially
        await container.read(cardBrowserProvider.notifier).addCard(card);
        expect(
          container
              .read(cardBrowserProvider)
              .allCards
              .any((c) => c.id == 'card_to_delete'),
          isTrue,
        );

        // Delete card
        await container
            .read(cardBrowserProvider.notifier)
            .deleteCard('card_to_delete');
        expect(
          container
              .read(cardBrowserProvider)
              .allCards
              .any((c) => c.id == 'card_to_delete'),
          isFalse,
        );

        // Undo deletion via addCard
        await container.read(cardBrowserProvider.notifier).addCard(card);
        expect(
          container
              .read(cardBrowserProvider)
              .allCards
              .any((c) => c.id == 'card_to_delete'),
          isTrue,
        );
      },
    );
  });

  group('Settings Notifier Tests', () {
    test('fsrsEnabledProvider toggles value correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(fsrsEnabledProvider.notifier);
      expect(container.read(fsrsEnabledProvider), isTrue);

      await notifier.toggle(false);
      expect(container.read(fsrsEnabledProvider), isFalse);

      await notifier.toggle(true);
      expect(container.read(fsrsEnabledProvider), isTrue);
    });
  });
}
