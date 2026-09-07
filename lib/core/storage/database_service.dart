import 'dart:io';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/card.dart';
import '../models/deck.dart';
import 'app_database.dart';

class ReviewLogModel {
  final int id;
  final String cardId;
  final ReviewRating rating;
  final DateTime reviewTime;
  final int scheduledDays;
  final int elapsedDays;

  const ReviewLogModel({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewTime,
    required this.scheduledDays,
    required this.elapsedDays,
  });
}

class DatabaseService {
  static DatabaseService? _instance;
  AppDatabase? _db;

  // In-memory cache for synchronous fast UI rendering
  List<DeckModel> _cachedDecks = [];
  List<CardModel> _cachedCards = [];
  List<ReviewLogModel> _cachedReviewLogs = [];

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  AppDatabase get db {
    if (_db == null) {
      throw StateError('DatabaseService has not been initialized. Call init() first.');
    }
    return _db!;
  }

  Future<void> init({String? customPath}) async {
    if (_db != null) return;

    if (customPath != null) {
      _db = AppDatabase(NativeDatabase(File(customPath)));
    } else {
      _db = AppDatabase(driftDatabase(name: 'flanki'));
    }

    await deduplicateDecks();
    await _reloadCache();
  }

  Future<void> _reloadCache() async {
    if (_db == null) return;
    final deckRows = await (db.select(db.decks)..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
    _cachedDecks = deckRows.map((r) {
      return DeckModel(
        id: r.id,
        title: r.title,
        description: r.description,
        dueCount: r.dueCount,
        newCount: r.newCount,
        totalCount: r.totalCount,
        lastStudied: r.lastStudied,
      );
    }).toList();

    final cardRows = await (db.select(db.cards)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    _cachedCards = cardRows.map(_mapRowToCard).toList();

    final logRows = await (db.select(db.reviewLogs)..orderBy([(t) => OrderingTerm.desc(t.reviewTime)])).get();
    _cachedReviewLogs = logRows.map((r) {
      return ReviewLogModel(
        id: r.id,
        cardId: r.cardId,
        rating: ReviewRating.fromValue(r.rating),
        reviewTime: r.reviewTime,
        scheduledDays: r.scheduledDays,
        elapsedDays: r.elapsedDays,
      );
    }).toList();
  }

  // --- Synchronous Access for Riverpod state ---

  List<DeckModel> getAllDecks() => List.unmodifiable(_cachedDecks);

  List<CardModel> getAllCards() => List.unmodifiable(_cachedCards);

  List<ReviewLogModel> getAllReviewLogs() => List.unmodifiable(_cachedReviewLogs);

  List<CardModel> getCardsForDeck(String deckId) {
    return _cachedCards.where((c) => c.deckId == deckId).toList();
  }

  List<CardModel> getStudyQueue(
    String deckId, {
    int? limit,
    int? newLimit,
    int? reviewLimit,
  }) {
    final now = DateTime.now();
    final eligible = _cachedCards
        .where((c) => c.deckId == deckId && !c.isSuspended && !c.isBuried);

    if (newLimit != null || reviewLimit != null) {
      final maxNew = newLimit ?? 20;
      final maxReview = reviewLimit ?? 100;

      final dueCards = eligible
          .where((c) => c.reps > 0 && c.due != null && c.due!.isBefore(now))
          .take(maxReview)
          .toList();

      final newCards = eligible
          .where((c) => c.reps == 0)
          .take(maxNew)
          .toList();

      final queue = [...dueCards, ...newCards];
      if (limit != null) {
        return queue.take(limit).toList();
      }
      return queue;
    }

    final effectiveLimit = limit ?? 50;
    return eligible
        .where((c) {
          if (c.reps == 0) return true; // New card
          if (c.due != null && c.due!.isBefore(now)) return true; // Due card
          return false;
        })
        .take(effectiveLimit)
        .toList();
  }

  List<CardModel> getCramQueue({
    required String filterTag,
    int limit = 20,
    bool onlyFlagged = false,
  }) {
    return _cachedCards
        .where((c) => !c.isSuspended)
        .where((c) {
          if (onlyFlagged) return c.hasFlag;
          if (filterTag.isNotEmpty) {
            return c.tags.any((t) => t.toLowerCase() == filterTag.toLowerCase());
          }
          return true;
        })
        .take(limit)
        .toList();
  }

  /// Query cards for ad-hoc Custom Study / Cram session based on deckId parameters.
  List<CardModel> getCustomStudyQueue({
    required String deckId,
    int limit = 50,
  }) {
    // Format: cram_<mode>_<tag>_<limit>_<timestamp>
    final parts = deckId.split('_');
    final mode = parts.length > 1 ? parts[1] : '';
    final rawTag = parts.length > 2 ? parts[2] : '';
    final tag = Uri.decodeComponent(rawTag);

    final available = _cachedCards.where((c) => !c.isSuspended).toList();

    if (mode == 'flagged' || deckId.contains('flagged')) {
      return available.where((c) => c.hasFlag).take(limit).toList();
    } else if (mode == 'ahead' || mode == 'reviewAhead' || deckId.contains('ahead')) {
      // Review ahead: prioritize cards with earliest due dates
      final list = List<CardModel>.from(available)
        ..sort((a, b) {
          if (a.due == null) return 1;
          if (b.due == null) return -1;
          return a.due!.compareTo(b.due!);
        });
      return list.take(limit).toList();
    } else if (tag.isNotEmpty && tag != 'all') {
      return available
          .where((c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
          .take(limit)
          .toList();
    }

    return available.take(limit).toList();
  }

  /// Counts the total matching cards for a custom study filter.
  int countCardsForCustomStudy({
    required String mode,
    required String tag,
  }) {
    final available = _cachedCards.where((c) => !c.isSuspended);
    if (mode == 'flagged') {
      return available.where((c) => c.hasFlag).length;
    } else if (mode == 'ahead' || mode == 'reviewAhead') {
      return available.length;
    } else if (tag.isNotEmpty && tag != 'all') {
      return available
          .where((c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
          .length;
    }
    return available.length;
  }

  // --- Asynchronous Persistent Writes ---

  Future<void> saveDeck(DeckModel deck) async {
    final duplicate = _cachedDecks.firstWhereOrNull(
      (d) =>
          d.title.trim().toLowerCase() == deck.title.trim().toLowerCase() &&
          d.id != deck.id,
    );

    if (duplicate != null) {
      // Re-assign all cards from duplicate deck to this deck
      await (db.update(db.cards)..where((tbl) => tbl.deckId.equals(duplicate.id))).write(
        CardsCompanion(deckId: Value(deck.id)),
      );
      await (db.delete(db.decks)..where((tbl) => tbl.id.equals(duplicate.id))).go();
      _cachedDecks.removeWhere((d) => d.id == duplicate.id);
    }

    final idx = _cachedDecks.indexWhere((d) => d.id == deck.id);
    if (idx >= 0) {
      _cachedDecks[idx] = deck;
    } else {
      _cachedDecks.add(deck);
    }

    await db.into(db.decks).insertOnConflictUpdate(
      DecksCompanion.insert(
        id: deck.id,
        title: deck.title,
        description: deck.description,
        dueCount: Value(deck.dueCount),
        newCount: Value(deck.newCount),
        totalCount: Value(deck.totalCount),
        lastStudied: Value(deck.lastStudied),
      ),
    );
    await _reloadCache();
  }

  Future<void> saveDecks(List<DeckModel> decks) async {
    for (final incomingDeck in decks) {
      final duplicate = _cachedDecks.firstWhereOrNull(
        (d) =>
            d.title.trim().toLowerCase() == incomingDeck.title.trim().toLowerCase() &&
            d.id != incomingDeck.id,
      );

      if (duplicate != null) {
        await (db.update(db.cards)..where((tbl) => tbl.deckId.equals(duplicate.id))).write(
          CardsCompanion(deckId: Value(incomingDeck.id)),
        );
        await (db.delete(db.decks)..where((tbl) => tbl.id.equals(duplicate.id))).go();
        _cachedDecks.removeWhere((d) => d.id == duplicate.id);
      }

      final idx = _cachedDecks.indexWhere((d) => d.id == incomingDeck.id);
      if (idx >= 0) {
        _cachedDecks[idx] = incomingDeck;
      } else {
        _cachedDecks.add(incomingDeck);
      }
    }

    await db.batch((batch) {
      for (final deck in decks) {
        batch.insert(
          db.decks,
          DecksCompanion.insert(
            id: deck.id,
            title: deck.title,
            description: deck.description,
            dueCount: Value(deck.dueCount),
            newCount: Value(deck.newCount),
            totalCount: Value(deck.totalCount),
            lastStudied: Value(deck.lastStudied),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    await _reloadCache();
  }

  /// Removes duplicate decks with the same title, merging cards into the canonical deck.
  Future<void> deduplicateDecks() async {
    if (_db == null) return;
    final allDecks = await db.select(db.decks).get();
    final groupedByTitle = <String, List<Deck>>{};
    for (final d in allDecks) {
      final key = d.title.trim().toLowerCase();
      groupedByTitle.putIfAbsent(key, () => []).add(d);
    }

    bool hasDuplicates = false;
    for (final entry in groupedByTitle.entries) {
      final duplicateList = entry.value;
      if (duplicateList.length > 1) {
        hasDuplicates = true;
        // Determine canonical deck: the one that has the most cards
        Deck canonical = duplicateList.first;
        int maxCards = -1;
        for (final d in duplicateList) {
          final count = (await (db.select(db.cards)..where((tbl) => tbl.deckId.equals(d.id))).get()).length;
          if (count > maxCards) {
            maxCards = count;
            canonical = d;
          }
        }

        // Migrate cards from other duplicate decks to canonical deck and delete the duplicates
        for (final d in duplicateList) {
          if (d.id != canonical.id) {
            await (db.update(db.cards)..where((tbl) => tbl.deckId.equals(d.id))).write(
              CardsCompanion(deckId: Value(canonical.id)),
            );
            await (db.delete(db.decks)..where((tbl) => tbl.id.equals(d.id))).go();
          }
        }
      }
    }

    if (hasDuplicates) {
      await _reloadCache();
      await recalculateAllDeckCounts();
    }
  }

  Future<void> deleteDeck(String deckId) async {
    _cachedDecks.removeWhere((d) => d.id == deckId);
    _cachedCards.removeWhere((c) => c.deckId == deckId);

    await (db.delete(db.cards)..where((tbl) => tbl.deckId.equals(deckId))).go();
    await (db.delete(db.decks)..where((tbl) => tbl.id.equals(deckId))).go();
    await _reloadCache();
  }

  Future<void> recalculateAllDeckCounts() async {
    final now = DateTime.now();

    // Optimistic cache calculation
    final updatedList = <DeckModel>[];
    for (final d in _cachedDecks) {
      final deckCards = _cachedCards.where((c) => c.deckId == d.id).toList();
      int total = deckCards.length;
      int newC = 0;
      int dueC = 0;

      for (final c in deckCards) {
        if (c.isSuspended || c.isBuried) continue;
        if (c.reps == 0) {
          newC++;
        } else if (c.due != null && c.due!.isBefore(now)) {
          dueC++;
        }
      }

      updatedList.add(d.copyWith(
        totalCount: total,
        newCount: newC,
        dueCount: dueC,
      ));
    }
    _cachedDecks = updatedList;

    if (_db == null) return;
    final allDecks = await db.select(db.decks).get();
    for (final d in allDecks) {
      if (_db == null) return;
      final deckCards = await (db.select(db.cards)..where((tbl) => tbl.deckId.equals(d.id))).get();

      int total = deckCards.length;
      int newC = 0;
      int dueC = 0;

      for (final c in deckCards) {
        if (c.isSuspended || c.isBuried) continue;

        if (c.reps == 0) {
          newC++;
        } else if (c.due != null && c.due!.isBefore(now)) {
          dueC++;
        }
      }

      if (_db == null) return;
      await (db.update(db.decks)..where((tbl) => tbl.id.equals(d.id))).write(
        DecksCompanion(
          totalCount: Value(total),
          newCount: Value(newC),
          dueCount: Value(dueC),
        ),
      );
    }
    await _reloadCache();
  }

  Future<void> saveCard(CardModel card) async {
    // Optimistic cache update
    final idx = _cachedCards.indexWhere((c) => c.id == card.id);
    if (idx >= 0) {
      _cachedCards[idx] = card;
    } else {
      _cachedCards.insert(0, card);
    }

    await db.into(db.cards).insertOnConflictUpdate(
      CardsCompanion.insert(
        id: card.id,
        deckId: card.deckId,
        front: card.front,
        back: card.back,
        hint: Value(card.hint),
        noteType: Value(card.noteType.value),
        flag: Value(card.flag.value),
        isSuspended: Value(card.isSuspended),
        isBuried: Value(card.isBuried),
        tags: Value(card.tags.join(',')),
        intervalDays: Value(card.intervalDays),
        stability: Value(card.stability),
        difficulty: Value(card.difficulty),
        reps: Value(card.reps),
        lapses: Value(card.lapses),
        due: Value(card.due),
        lastStudied: Value(card.lastStudied),
        createdAt: Value(card.createdAt ?? DateTime.now()),
      ),
    );
    await _reloadCache();
  }

  Future<void> saveCards(List<CardModel> cards) async {
    for (final card in cards) {
      final idx = _cachedCards.indexWhere((c) => c.id == card.id);
      if (idx >= 0) {
        _cachedCards[idx] = card;
      } else {
        _cachedCards.insert(0, card);
      }
    }

    await db.batch((batch) {
      for (final card in cards) {
        batch.insert(
          db.cards,
          CardsCompanion.insert(
            id: card.id,
            deckId: card.deckId,
            front: card.front,
            back: card.back,
            hint: Value(card.hint),
            noteType: Value(card.noteType.value),
            flag: Value(card.flag.value),
            isSuspended: Value(card.isSuspended),
            isBuried: Value(card.isBuried),
            tags: Value(card.tags.join(',')),
            intervalDays: Value(card.intervalDays),
            stability: Value(card.stability),
            difficulty: Value(card.difficulty),
            reps: Value(card.reps),
            lapses: Value(card.lapses),
            due: Value(card.due),
            lastStudied: Value(card.lastStudied),
            createdAt: Value(card.createdAt ?? DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    await _reloadCache();
  }

  Future<void> deleteCard(String cardId) async {
    _cachedCards.removeWhere((c) => c.id == cardId);
    await (db.delete(db.cards)..where((tbl) => tbl.id.equals(cardId))).go();
    await _reloadCache();
  }

  Future<void> insertReviewLog({
    required String cardId,
    required ReviewRating rating,
    required DateTime reviewTime,
    required int scheduledDays,
    required int elapsedDays,
  }) async {
    final log = ReviewLogModel(
      id: DateTime.now().microsecondsSinceEpoch,
      cardId: cardId,
      rating: rating,
      reviewTime: reviewTime,
      scheduledDays: scheduledDays,
      elapsedDays: elapsedDays,
    );
    _cachedReviewLogs.insert(0, log);

    await db.into(db.reviewLogs).insert(
      ReviewLogsCompanion.insert(
        cardId: cardId,
        rating: rating.value,
        reviewTime: reviewTime,
        scheduledDays: Value(scheduledDays),
        elapsedDays: Value(elapsedDays),
      ),
    );
    await _reloadCache();
  }

  static String _cleanMediaPaths(String html) {
    if (!html.contains('flanki_media')) return html;
    return html.replaceAllMapped(
      RegExp(r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''', caseSensitive: false),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
    );
  }

  CardModel _mapRowToCard(Card row) {
    final tags = row.tags.isNotEmpty ? row.tags.split(',') : <String>[];
    return CardModel(
      id: row.id,
      deckId: row.deckId,
      front: _cleanMediaPaths(row.front),
      back: _cleanMediaPaths(row.back),
      hint: row.hint,
      noteType: NoteType.fromString(row.noteType),
      flag: CardFlag.fromValue(row.flag),
      isSuspended: row.isSuspended,
      isBuried: row.isBuried,
      tags: tags,
      intervalDays: row.intervalDays,
      stability: row.stability,
      difficulty: row.difficulty,
      reps: row.reps,
      lapses: row.lapses,
      due: row.due,
      lastStudied: row.lastStudied,
      createdAt: row.createdAt,
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _cachedDecks = [];
    _cachedCards = [];
    _cachedReviewLogs = [];
  }
}
