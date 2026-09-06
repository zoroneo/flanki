import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/storage/database_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';

void main() {
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_test_db_');
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
}
