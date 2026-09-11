import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../config/app_config.dart';
import '../models/card.dart';
import '../models/custom_study_mode.dart';
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
      throw StateError(
        'DatabaseService has not been initialized. Call init() first.',
      );
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
    final deckRows = await (db.select(
      db.decks,
    )..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
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

    final cardRows = await (db.select(
      db.cards,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    _cachedCards = cardRows.map(_mapRowToCard).toList();

    final logRows = await (db.select(
      db.reviewLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.reviewTime)])).get();
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

  List<ReviewLogModel> getAllReviewLogs() =>
      List.unmodifiable(_cachedReviewLogs);

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
    final eligible = _cachedCards.where(
      (c) => c.deckId == deckId && !c.isSuspended && !c.isBuried,
    );

    if (newLimit != null || reviewLimit != null) {
      final maxNew = newLimit ?? AppConfig.defaultNewCardsPerDay;
      final maxReview = reviewLimit ?? AppConfig.defaultReviewsPerDay;

      final dueCards = eligible
          .where((c) => c.reps > 0 && c.due != null && c.due!.isBefore(now))
          .take(maxReview)
          .toList();

      final newCards = eligible.where((c) => c.reps == 0).take(maxNew).toList();

      final queue = [...dueCards, ...newCards];
      if (limit != null) {
        return queue.take(limit).toList();
      }
      return queue;
    }

    final effectiveLimit = limit ?? AppConfig.defaultCramLimit;
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
            return c.tags.any(
              (t) => t.toLowerCase() == filterTag.toLowerCase(),
            );
          }
          return true;
        })
        .take(limit)
        .toList();
  }

  /// Query cards for ad-hoc Custom Study / Cram session based on deckId parameters.
  List<CardModel> getCustomStudyQueue({required String deckId, int? limit}) {
    // Format: cram_<mode>_<tag>_<limit>_<timestamp>
    final parts = deckId.split('_');
    final rawMode = parts.length > 1 ? parts[1] : '';
    final customMode = CustomStudyMode.fromString(rawMode);

    final String rawTag;
    final int? parsedLimit;
    if (parts.length >= 5) {
      parsedLimit = int.tryParse(parts[parts.length - 2]);
      rawTag = parts.sublist(2, parts.length - 2).join('_');
    } else {
      rawTag = parts.length > 2 ? parts[2] : '';
      parsedLimit = parts.length > 3 ? int.tryParse(parts[3]) : null;
    }
    final tag = Uri.decodeComponent(rawTag);

    final deckCount = _cachedDecks
        .firstWhereOrNull((d) => d.id == deckId)
        ?.totalCount;
    final effectiveLimit =
        parsedLimit ??
        (deckCount != null && deckCount > 0 ? deckCount : null) ??
        limit ??
        AppConfig.defaultCramLimit;

    final available = _cachedCards.where((c) => !c.isSuspended).toList();

    switch (customMode) {
      case CustomStudyMode.flagged:
        return available.where((c) => c.hasFlag).take(effectiveLimit).toList();
      case CustomStudyMode.reviewAhead:
        final list = List<CardModel>.from(available)
          ..sort((a, b) {
            if (a.due == null) return 1;
            if (b.due == null) return -1;
            return a.due!.compareTo(b.due!);
          });
        return list.take(effectiveLimit).toList();
      case CustomStudyMode.byTag:
        if (tag.isNotEmpty && tag != 'all') {
          return available
              .where((c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
              .take(effectiveLimit)
              .toList();
        }
        return available.take(effectiveLimit).toList();
    }
  }

  /// Counts the total matching cards for a custom study filter.
  int countCardsForCustomStudy({
    required CustomStudyMode mode,
    required String tag,
  }) {
    final available = _cachedCards.where((c) => !c.isSuspended);
    switch (mode) {
      case CustomStudyMode.flagged:
        return available.where((c) => c.hasFlag).length;
      case CustomStudyMode.reviewAhead:
        return available.length;
      case CustomStudyMode.byTag:
        if (tag.isNotEmpty && tag != 'all') {
          return available
              .where((c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
              .length;
        }
        return available.length;
    }
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
      await (db.update(db.cards)
            ..where((tbl) => tbl.deckId.equals(duplicate.id)))
          .write(CardsCompanion(deckId: Value(deck.id)));
      await (db.delete(
        db.decks,
      )..where((tbl) => tbl.id.equals(duplicate.id))).go();
      _cachedDecks.removeWhere((d) => d.id == duplicate.id);
    }

    final idx = _cachedDecks.indexWhere((d) => d.id == deck.id);
    if (idx >= 0) {
      _cachedDecks[idx] = deck;
    } else {
      _cachedDecks.add(deck);
    }

    await db
        .into(db.decks)
        .insertOnConflictUpdate(
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
            d.title.trim().toLowerCase() ==
                incomingDeck.title.trim().toLowerCase() &&
            d.id != incomingDeck.id,
      );

      if (duplicate != null) {
        await (db.update(db.cards)
              ..where((tbl) => tbl.deckId.equals(duplicate.id)))
            .write(CardsCompanion(deckId: Value(incomingDeck.id)));
        await (db.delete(
          db.decks,
        )..where((tbl) => tbl.id.equals(duplicate.id))).go();
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
          final count = (await (db.select(
            db.cards,
          )..where((tbl) => tbl.deckId.equals(d.id))).get()).length;
          if (count > maxCards) {
            maxCards = count;
            canonical = d;
          }
        }

        // Migrate cards from other duplicate decks to canonical deck and delete the duplicates
        for (final d in duplicateList) {
          if (d.id != canonical.id) {
            await (db.update(db.cards)..where((tbl) => tbl.deckId.equals(d.id)))
                .write(CardsCompanion(deckId: Value(canonical.id)));
            await (db.delete(
              db.decks,
            )..where((tbl) => tbl.id.equals(d.id))).go();
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

      updatedList.add(
        d.copyWith(totalCount: total, newCount: newC, dueCount: dueC),
      );
    }
    _cachedDecks = updatedList;

    if (_db == null) return;
    final allDecks = await db.select(db.decks).get();
    for (final d in allDecks) {
      if (_db == null) return;
      final deckCards = await (db.select(
        db.cards,
      )..where((tbl) => tbl.deckId.equals(d.id))).get();

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

    await db
        .into(db.cards)
        .insertOnConflictUpdate(
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

  /// Merges remote cards into the local collection using smart Last-Write-Wins per card.
  /// Preserves local study progress if local was studied more recently than remote,
  /// and adopts remote study progress if remote was studied more recently.
  Future<void> mergeCards(List<CardModel> remoteCards) async {
    final localCardsMap = {for (final c in _cachedCards) c.id: c};
    final mergedCards = <CardModel>[];

    for (final remote in remoteCards) {
      final local = localCardsMap[remote.id];
      if (local == null) {
        mergedCards.add(remote);
      } else {
        final localStudied = local.lastStudied;
        final remoteStudied = remote.lastStudied;

        if (remoteStudied != null && localStudied != null) {
          if (remoteStudied.isAfter(localStudied)) {
            mergedCards.add(remote);
          } else if (localStudied.isAfter(remoteStudied)) {
            mergedCards.add(local);
          } else {
            mergedCards.add(remote.reps >= local.reps ? remote : local);
          }
        } else if (remoteStudied != null && localStudied == null) {
          mergedCards.add(remote);
        } else if (localStudied != null && remoteStudied == null) {
          mergedCards.add(local);
        } else {
          mergedCards.add(remote);
        }
      }
    }

    final remoteIds = remoteCards.map((c) => c.id).toSet();
    for (final local in _cachedCards) {
      if (!remoteIds.contains(local.id)) {
        mergedCards.add(local);
      }
    }

    await saveCards(mergedCards);
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

    await db
        .into(db.reviewLogs)
        .insert(
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

  Future<void> saveReviewLogs(List<ReviewLogModel> logs) async {
    if (logs.isEmpty) return;

    final existingSet = _cachedReviewLogs
        .map((l) => '${l.cardId}_${l.reviewTime.millisecondsSinceEpoch}')
        .toSet();

    final cardIdSet = _cachedCards.map((c) => c.id).toSet();

    final newLogs = logs.where((l) {
      final key = '${l.cardId}_${l.reviewTime.millisecondsSinceEpoch}';
      return !existingSet.contains(key) && cardIdSet.contains(l.cardId);
    }).toList();

    if (newLogs.isEmpty) return;

    await db.batch((batch) {
      for (final log in newLogs) {
        batch.insert(
          db.reviewLogs,
          ReviewLogsCompanion.insert(
            cardId: log.cardId,
            rating: log.rating.value,
            reviewTime: log.reviewTime,
            scheduledDays: Value(log.scheduledDays),
            elapsedDays: Value(log.elapsedDays),
          ),
        );
      }
    });

    await _reloadCache();
  }

  static String _cleanMediaPaths(String html) {
    if (!html.contains('flanki_media')) return html;
    return html.replaceAllMapped(
      RegExp(
        r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
        caseSensitive: false,
      ),
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

  /// Checks if any cards or review logs have been added or updated after [lastSyncTime].
  bool hasLocalChangesSince(DateTime? lastSyncTime) {
    if (lastSyncTime == null) {
      return _cachedCards.isNotEmpty || _cachedReviewLogs.isNotEmpty;
    }
    final hasReviewedCard = _cachedCards.any(
      (c) =>
          (c.lastStudied != null && c.lastStudied!.isAfter(lastSyncTime)) ||
          (c.createdAt != null && c.createdAt!.isAfter(lastSyncTime)),
    );
    if (hasReviewedCard) return true;

    return _cachedReviewLogs.any((l) => l.reviewTime.isAfter(lastSyncTime));
  }

  /// Persists downloaded SQLite bytes from AnkiWeb as the sync template.
  Future<void> saveSyncTemplateBytes(Uint8List bytes) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final file = File('${supportDir.path}/sync_template.anki2');
      await file.writeAsBytes(bytes, flush: true);
    } catch (_) {}
  }

  /// Persists sync template from an existing file using OS-level copy.
  Future<void> saveSyncTemplateFile(File sourceFile) async {
    try {
      final supportDir = await getApplicationSupportDirectory();
      final file = File('${supportDir.path}/sync_template.anki2');
      if (file.existsSync()) {
        file.deleteSync();
      }
      await sourceFile.copy(file.path);
    } catch (_) {}
  }

  /// Exports local collection and review logs to a valid SQLite collection.anki2 binary.
  Future<Uint8List> exportToAnki2Db() async {
    final supportDir = await getApplicationSupportDirectory();
    final templateFile = File('${supportDir.path}/sync_template.anki2');
    final tempDir = Directory.systemTemp.createTempSync('flanki_export_');
    final targetDbFile = File('${tempDir.path}/collection.anki2');

    try {
      if (templateFile.existsSync()) {
        templateFile.copySync(targetDbFile.path);
      }

      final db = sqlite3.open(targetDbFile.path);
      try {
        db.execute('''
          CREATE TABLE IF NOT EXISTS col (
            id integer primary key,
            crt integer,
            mod integer,
            scm integer,
            ver integer,
            dty integer,
            usn integer,
            ls integer,
            conf text,
            models text,
            decks text,
            dconf text,
            tags text
          );
          CREATE TABLE IF NOT EXISTS notes (
            id integer primary key,
            guid text,
            mid integer,
            mod integer,
            usn integer,
            tags text,
            flds text,
            sfld integer,
            csum integer,
            flags integer,
            data text
          );
          CREATE TABLE IF NOT EXISTS cards (
            id integer primary key,
            nid integer,
            did integer,
            ord integer,
            mod integer,
            usn integer,
            type integer,
            queue integer,
            due integer,
            ivl integer,
            factor integer,
            reps integer,
            lapses integer,
            left integer,
            odue integer,
            odid integer,
            flags integer,
            data text
          );
          CREATE TABLE IF NOT EXISTS revlog (
            id integer primary key,
            cid integer,
            usn integer,
            ease integer,
            ivl integer,
            lastIvl integer,
            factor integer,
            time integer,
            type integer
          );
          CREATE TABLE IF NOT EXISTS graves (
            usn integer not null,
            oid integer not null,
            type integer not null
          );
        ''');

        final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // Update or insert col row
        final colCount =
            db.select('SELECT count(*) as cnt FROM col').first['cnt'] as int;
        if (colCount == 0) {
          db.execute(
            '''
            INSERT INTO col (id, crt, mod, scm, ver, dty, usn, ls, conf, models, decks, dconf, tags)
            VALUES (1, ?, ?, ?, ${AppConfig.ankiColSchemaVersion}, 0, 0, 0, '{}', '{}', '{}', '{}', '{}')
          ''',
            [nowSec, nowSec, nowSec],
          );
        } else {
          db.execute('UPDATE col SET mod = ?, usn = usn + 1', [nowSec]);
        }

        final colRow = db.select('SELECT crt FROM col LIMIT 1');
        final colCrtSec = colRow.isNotEmpty
            ? (colRow.first['crt'] as int? ?? nowSec)
            : nowSec;
        final colCrtDate = DateTime.fromMillisecondsSinceEpoch(
          colCrtSec * 1000,
        );

        // Update cards scheduling state
        for (final card in _cachedCards) {
          final cid =
              int.tryParse(card.id.replaceAll(RegExp(r'\D'), '')) ??
              card.id.hashCode.abs();
          if (cid == 0) continue;

          final factor = (card.difficulty > 0)
              ? ((3.0 - (card.difficulty - 1.0) / 9.0 * 1.7) * 1000)
                    .toInt()
                    .clamp(AppConfig.minAnkiFactor, AppConfig.maxAnkiFactor)
              : AppConfig.defaultAnkiFactor;

          final cardModSec =
              (card.lastStudied ?? card.createdAt ?? DateTime.now())
                  .millisecondsSinceEpoch ~/
              1000;
          final dueDays = card.due != null
              ? (card.reps > 0 ? card.due!.difference(colCrtDate).inDays : 0)
              : card.intervalDays;

          db.execute(
            '''
            UPDATE cards SET
              ivl = ?,
              factor = ?,
              reps = ?,
              lapses = ?,
              due = ?,
              mod = ?,
              usn = ?
            WHERE id = ?
          ''',
            [
              card.intervalDays,
              factor,
              card.reps,
              card.lapses,
              dueDays,
              cardModSec,
              AppConfig.ankiSyncUsnModified,
              cid,
            ],
          );
        }

        // Insert review logs
        for (final log in _cachedReviewLogs) {
          final cid =
              int.tryParse(log.cardId.replaceAll(RegExp(r'\D'), '')) ??
              log.cardId.hashCode.abs();
          if (cid == 0) continue;

          final logId = log.reviewTime.millisecondsSinceEpoch;
          final ease = log.rating.value;
          final ivl = log.scheduledDays;
          final lastIvl = log.elapsedDays;

          db.execute(
            '''
            INSERT OR IGNORE INTO revlog (id, cid, usn, ease, ivl, lastIvl, factor, time, type)
            VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?)
          ''',
            [
              logId,
              cid,
              AppConfig.ankiSyncUsnModified,
              ease,
              ivl,
              lastIvl,
              AppConfig.defaultAnkiFactor,
              AppConfig.ankiRevlogTypeReview,
            ],
          );
        }

        db.execute('PRAGMA integrity_check;');
      } finally {
        db.close();
      }

      return targetDbFile.readAsBytesSync();
    } finally {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _cachedDecks = [];
    _cachedCards = [];
    _cachedReviewLogs = [];
  }
}
