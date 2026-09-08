import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flanki/core/storage/database_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_test_db_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => tempDir.path,
        );
    dbPath = '${tempDir.path}/test_flanki.db';
    await DatabaseService.instance.init(customPath: dbPath);
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('DatabaseService starts clean and empty', () {
    final decks = DatabaseService.instance.getAllDecks();
    expect(decks.isEmpty, isTrue);

    final cards = DatabaseService.instance.getAllCards();
    expect(cards.isEmpty, isTrue);
  });

  test('DatabaseService saves and retrieves decks', () async {
    const deck = DeckModel(
      id: 'deck_test_1',
      title: 'Vocabulary',
      description: 'Test deck',
      dueCount: 0,
      newCount: 0,
      totalCount: 0,
    );

    await DatabaseService.instance.saveDeck(deck);
    final decks = DatabaseService.instance.getAllDecks();
    expect(decks.length, equals(1));
    expect(decks.first.title, equals('Vocabulary'));
  });

  test('DatabaseService saves and retrieves cards', () async {
    final newCard = CardModel(
      id: 'test_card_1',
      deckId: 'deck-toeic-600',
      front: 'Ephemeral',
      back: 'Phù du, chóng tàn',
      tags: ['vocab'],
    );

    await DatabaseService.instance.saveCard(newCard);
    final allCards = DatabaseService.instance.getAllCards();
    final retrieved = allCards.firstWhere((c) => c.id == 'test_card_1');

    expect(retrieved.front, equals('Ephemeral'));
    expect(retrieved.back, equals('Phù du, chóng tàn'));
  });

  test('DatabaseService inserts and reads review logs', () async {
    await DatabaseService.instance.insertReviewLog(
      cardId: 'c1',
      rating: ReviewRating.good,
      reviewTime: DateTime.now(),
      scheduledDays: 4,
      elapsedDays: 1,
    );

    final logs = DatabaseService.instance.getAllReviewLogs();
    expect(logs.isNotEmpty, isTrue);
    expect(logs.first.rating, equals(ReviewRating.good));
  });

  test('DatabaseService queries custom study queue by tag and flag', () async {
    final c1 = CardModel(
      id: 'c1',
      deckId: 'd1',
      front: 'Flagged card',
      back: 'Back 1',
      flag: CardFlag.red,
      tags: ['ielts'],
    );
    final c2 = CardModel(
      id: 'c2',
      deckId: 'd1',
      front: 'Tag card',
      back: 'Back 2',
      tags: ['toeic'],
    );
    final c3 = CardModel(
      id: 'c3',
      deckId: 'd1',
      front: 'Suspended card',
      back: 'Back 3',
      isSuspended: true,
      tags: ['ielts'],
    );

    await DatabaseService.instance.saveCards([c1, c2, c3]);

    final flaggedQueue = DatabaseService.instance.getCustomStudyQueue(
      deckId: 'cram_flagged_all_20_123',
    );
    expect(flaggedQueue.length, equals(1));
    expect(flaggedQueue.first.id, equals('c1'));

    final tagQueue = DatabaseService.instance.getCustomStudyQueue(
      deckId: 'cram_byTag_ielts_20_123',
    );
    expect(tagQueue.length, equals(1));
    expect(tagQueue.first.id, equals('c1'));

    final count = DatabaseService.instance.countCardsForCustomStudy(
      mode: 'byTag',
      tag: 'toeic',
    );
    expect(count, equals(1));
  });

  test('DatabaseService getCustomStudyQueue falls back to registered deck totalCount when parsedLimit is absent', () async {
    const legacyCramDeck = DeckModel(
      id: 'cram_flagged_all',
      title: 'Legacy Cram',
      description: '',
      dueCount: 75,
      newCount: 0,
      totalCount: 75,
    );
    await DatabaseService.instance.saveDeck(legacyCramDeck);

    final cards = List.generate(
      75,
      (i) => CardModel(
        id: 'flagged_$i',
        deckId: 'legacy_src',
        front: 'Front $i',
        back: 'Back $i',
        flag: CardFlag.red,
      ),
    );
    await DatabaseService.instance.saveCards(cards);

    final queue = DatabaseService.instance.getCustomStudyQueue(
      deckId: 'cram_flagged_all',
    );
    // It should yield all 75 cards from totalCount instead of being capped at default 50
    expect(queue.length, equals(75));
  });

  test('DatabaseService recalculateAllDeckCounts updates counts excluding suspended/buried cards', () async {
    const deck = DeckModel(
      id: 'd_recalc',
      title: 'Math',
      description: '',
      dueCount: 0,
      newCount: 0,
      totalCount: 0,
    );
    await DatabaseService.instance.saveDeck(deck);

    final now = DateTime.now();
    final newCard = CardModel(
      id: 'mc1',
      deckId: 'd_recalc',
      front: '1+1',
      back: '2',
      reps: 0,
    );
    final dueCard = CardModel(
      id: 'mc2',
      deckId: 'd_recalc',
      front: '2+2',
      back: '4',
      reps: 1,
      due: now.subtract(const Duration(days: 1)),
    );
    final suspendedCard = CardModel(
      id: 'mc3',
      deckId: 'd_recalc',
      front: '3+3',
      back: '6',
      reps: 0,
      isSuspended: true,
    );

    await DatabaseService.instance.saveCards([newCard, dueCard, suspendedCard]);
    await DatabaseService.instance.recalculateAllDeckCounts();

    final decks = DatabaseService.instance.getAllDecks();
    final mathDeck = decks.firstWhere((d) => d.id == 'd_recalc');
    expect(mathDeck.totalCount, equals(3));
    expect(mathDeck.newCount, equals(1)); // mc1 (mc3 is suspended)
    expect(mathDeck.dueCount, equals(1)); // mc2
  });

  test('DatabaseService exportToAnkiDatabase correctly parses both native Flanki card IDs and Anki c_ IDs into revlog', () async {
    const deck = DeckModel(
      id: 'd_export_test',
      title: 'Export Test',
      description: '',
      dueCount: 0,
      newCount: 0,
      totalCount: 0,
    );
    await DatabaseService.instance.saveDeck(deck);

    // Native Flanki card id and Anki imported card id
    final nativeCard = CardModel(
      id: 'card-1709812345678',
      deckId: 'd_export_test',
      front: 'Front 1',
      back: 'Back 1',
    );
    final ankiCard = CardModel(
      id: 'c_998877',
      deckId: 'd_export_test',
      front: 'Front 2',
      back: 'Back 2',
    );
    await DatabaseService.instance.saveCards([nativeCard, ankiCard]);

    await DatabaseService.instance.insertReviewLog(
      cardId: 'card-1709812345678',
      rating: ReviewRating.good,
      reviewTime: DateTime.now().subtract(const Duration(hours: 1)),
      scheduledDays: 1,
      elapsedDays: 0,
    );
    await DatabaseService.instance.insertReviewLog(
      cardId: 'c_998877',
      rating: ReviewRating.easy,
      reviewTime: DateTime.now(),
      scheduledDays: 4,
      elapsedDays: 1,
    );

    final bytes = await DatabaseService.instance.exportToAnki2Db();
    expect(bytes.isNotEmpty, isTrue);

    final exportedDbFile = File('${tempDir.path}/exported_anki.db');
    exportedDbFile.writeAsBytesSync(bytes);

    final exportedDb = sqlite3.open(exportedDbFile.path);
    try {
      final rows = exportedDb.select('SELECT cid FROM revlog ORDER BY cid ASC');
      final cids = rows.map((r) => r['cid'] as int).toList();

      expect(cids.contains(998877), isTrue);
      expect(cids.contains(1709812345678), isTrue);
    } finally {
      exportedDb.close();
    }
  });
}
