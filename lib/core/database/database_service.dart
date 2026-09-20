import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/card.dart';
import '../models/custom_study_mode.dart';
import '../models/deck.dart';
import '../models/review_log.dart';
import '../models/sync_payloads.dart';
import '../sync/hlc.dart';
import '../../features/exam/models/exam_models.dart';
import '../../features/grammar/models/grammar_progress.dart';
import 'app_database.dart';

export '../models/review_log.dart';
export '../models/sync_payloads.dart';

class DatabaseService {
  static DatabaseService? _instance;
  AppDatabase? _db;

  // Hybrid Logical Clock (HLC) & Node Identity
  String _nodeId = IdHelper.generateNodeId();
  Hlc? _lastHlc;

  String get nodeId => _nodeId;
  Hlc get currentHlc => _lastHlc ?? Hlc.now(_nodeId);

  void configureNodeId(String id) {
    _nodeId = id;
  }

  Hlc advanceHlc({int? wallTime}) {
    _lastHlc = Hlc.send(_lastHlc, _nodeId, wallTime: wallTime);
    return _lastHlc!;
  }

  void updateHlcFromRemote(Hlc remoteHlc) {
    _lastHlc = Hlc.recv(_lastHlc, remoteHlc, _nodeId);
  }

  /// Optional listener triggered whenever a local mutation is enqueued into the outbox.
  void Function()? onMutationEnqueued;

  // In-memory cache for synchronous fast UI rendering
  List<DeckModel> _cachedDecks = [];
  List<CardModel> _cachedCards = [];
  List<ReviewLogModel> _cachedReviewLogs = [];

  DatabaseService._();
  DatabaseService.forTest(AppDatabase database) : _db = database;

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
    if (_db == null) {
      if (customPath != null) {
        _db = AppDatabase(NativeDatabase(File(customPath)));
      } else {
        _db = AppDatabase(driftDatabase(name: AppConfig.databaseName));
      }
    }

    await _reloadCache();
    unawaited(deduplicateDecks());
  }

  Future<void> _reloadCache() async {
    if (_db == null) return;
    final deckRows =
        await (db.select(db.decks)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.title)]))
            .get();
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

    final cardRows =
        await (db.select(db.cards)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
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
              .where(
                (c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()),
              )
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
              .where(
                (c) => c.tags.any((t) => t.toLowerCase() == tag.toLowerCase()),
              )
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

    final hlcStr = advanceHlc().pack();

    await db.transaction(() async {
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
              updatedAtHlc: Value(hlcStr),
              isDeleted: const Value(false),
            ),
          );

      await db
          .into(db.syncOutbox)
          .insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              id: IdHelper.outboxId(
                prefix: 'deck',
                entityId: deck.id,
                hlc: hlcStr,
              ),
              entityType: SupabaseConfig.entityDeck,
              entityId: deck.id,
              operation: SupabaseConfig.opUpsert,
              payloadJson: jsonEncode(deck.toJson()),
              hlc: hlcStr,
            ),
          );
    });
    await _reloadCache();
    onMutationEnqueued?.call();
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

    final hlcStr = advanceHlc().pack();

    await db.transaction(() async {
      for (final deck in decks) {
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
                updatedAtHlc: Value(hlcStr),
                isDeleted: const Value(false),
              ),
            );

        await db
            .into(db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'deck',
                  entityId: deck.id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityDeck,
                entityId: deck.id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(deck.toJson()),
                hlc: hlcStr,
              ),
            );
      }
    });
    await _reloadCache();
    onMutationEnqueued?.call();
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
    final hlcStr = advanceHlc().pack();

    await db.transaction(() async {
      await (db.update(
        db.cards,
      )..where((tbl) => tbl.deckId.equals(deckId))).write(
        CardsCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );
      await (db.update(db.decks)..where((tbl) => tbl.id.equals(deckId))).write(
        DecksCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      await db
          .into(db.syncOutbox)
          .insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              id: IdHelper.outboxId(
                prefix: 'deck_del',
                entityId: deckId,
                hlc: hlcStr,
              ),
              entityType: SupabaseConfig.entityDeck,
              entityId: deckId,
              operation: SupabaseConfig.opDelete,
              payloadJson: jsonEncode(SyncIdPayload(id: deckId).toJson()),
              hlc: hlcStr,
            ),
          );
    });
    await _reloadCache();
    onMutationEnqueued?.call();
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

  Future<void> saveCard(CardModel card, {bool markOutbox = true}) async {
    // Optimistic cache update
    final idx = _cachedCards.indexWhere((c) => c.id == card.id);
    if (idx >= 0) {
      _cachedCards[idx] = card;
    } else {
      _cachedCards.insert(0, card);
    }

    final hlcStr = markOutbox ? advanceHlc().pack() : '';

    await db.transaction(() async {
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
              updatedAtHlc: Value(hlcStr),
              isDeleted: const Value(false),
            ),
          );

      if (markOutbox) {
        await db
            .into(db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'card',
                  entityId: card.id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityCard,
                entityId: card.id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(card.toJson()),
                hlc: hlcStr,
              ),
            );
      }
    });
    await _reloadCache();
    if (markOutbox) {
      onMutationEnqueued?.call();
    }
  }

  Future<void> saveCards(
    List<CardModel> cards, {
    bool markOutbox = true,
  }) async {
    for (final card in cards) {
      final idx = _cachedCards.indexWhere((c) => c.id == card.id);
      if (idx >= 0) {
        _cachedCards[idx] = card;
      } else {
        _cachedCards.insert(0, card);
      }
    }

    final hlcStr = markOutbox ? advanceHlc().pack() : '';

    await db.transaction(() async {
      for (final card in cards) {
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
                updatedAtHlc: Value(hlcStr),
                isDeleted: const Value(false),
              ),
            );

        if (markOutbox) {
          await db
              .into(db.syncOutbox)
              .insertOnConflictUpdate(
                SyncOutboxCompanion.insert(
                  id: IdHelper.outboxId(
                    prefix: 'card',
                    entityId: card.id,
                    hlc: hlcStr,
                  ),
                  entityType: SupabaseConfig.entityCard,
                  entityId: card.id,
                  operation: SupabaseConfig.opUpsert,
                  payloadJson: jsonEncode(card.toJson()),
                  hlc: hlcStr,
                ),
              );
        }
      }
    });
    await _reloadCache();
    if (markOutbox) {
      onMutationEnqueued?.call();
    }
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

  Future<void> deleteCard(String cardId, {bool markOutbox = true}) async {
    _cachedCards.removeWhere((c) => c.id == cardId);
    final hlcStr = markOutbox ? advanceHlc().pack() : '';

    await db.transaction(() async {
      await (db.update(db.cards)..where((tbl) => tbl.id.equals(cardId))).write(
        CardsCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      if (markOutbox) {
        await db
            .into(db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'card_del',
                  entityId: cardId,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityCard,
                entityId: cardId,
                operation: SupabaseConfig.opDelete,
                payloadJson: jsonEncode(SyncIdPayload(id: cardId).toJson()),
                hlc: hlcStr,
              ),
            );
      }
    });
    await _reloadCache();
    if (markOutbox) {
      onMutationEnqueued?.call();
    }
  }

  Future<void> insertReviewLog({
    required String cardId,
    required ReviewRating rating,
    required DateTime reviewTime,
    required int scheduledDays,
    required int elapsedDays,
  }) async {
    final clientLogId = 'log_${cardId}_${reviewTime.millisecondsSinceEpoch}';
    final log = ReviewLogModel(
      id: DateTime.now().microsecondsSinceEpoch,
      cardId: cardId,
      rating: rating,
      reviewTime: reviewTime,
      scheduledDays: scheduledDays,
      elapsedDays: elapsedDays,
      clientLogId: clientLogId,
    );
    _cachedReviewLogs.insert(0, log);

    final hlcStr = advanceHlc().pack();

    await db.transaction(() async {
      await db
          .into(db.reviewLogs)
          .insert(
            ReviewLogsCompanion.insert(
              cardId: cardId,
              rating: rating.value,
              reviewTime: reviewTime,
              scheduledDays: Value(scheduledDays),
              elapsedDays: Value(elapsedDays),
              clientLogId: Value(clientLogId),
            ),
          );

      await db
          .into(db.syncOutbox)
          .insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              id: IdHelper.outboxId(
                prefix: 'revlog',
                entityId: clientLogId,
                hlc: hlcStr,
              ),
              entityType: SupabaseConfig.entityReviewLog,
              entityId: clientLogId,
              operation: SupabaseConfig.opInsert,
              payloadJson: jsonEncode(log.toJson()),
              hlc: hlcStr,
            ),
          );
    });
    await _reloadCache();
    onMutationEnqueued?.call();
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
    if (!html.contains(AppConfig.appMediaBaseDirectory)) return html;
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
    final templateFile = File(
      '${supportDir.path}/${AppConfig.ankiSyncTemplateFileName}',
    );
    final tempDir = Directory.systemTemp.createTempSync(
      AppConfig.tempExportPrefix,
    );
    final targetDbFile = File('${tempDir.path}/${AppConfig.anki2DbFileName}');

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

  // --- Sync Replicator Helpers ---

  Future<List<SyncOutboxData>> getPendingOutboxBatch({int limit = 100}) async {
    return (db.select(db.syncOutbox)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> acknowledgeOutboxBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    await (db.delete(db.syncOutbox)..where((tbl) => tbl.id.isIn(ids))).go();
  }

  Future<int> getPendingOutboxCount() async {
    final countExpr = db.syncOutbox.id.count();
    final query = db.selectOnly(db.syncOutbox)..addColumns([countExpr]);
    final result = await query.map((row) => row.read(countExpr)).getSingle();
    return result ?? 0;
  }

  Future<String?> getSyncCursor(String entityType) async {
    final row = await (db.select(
      db.syncCursors,
    )..where((t) => t.entityType.equals(entityType))).getSingleOrNull();
    return row?.lastServerHlc;
  }

  Future<void> setSyncCursor(String entityType, String lastServerHlc) async {
    await db
        .into(db.syncCursors)
        .insertOnConflictUpdate(
          SyncCursorsCompanion.insert(
            entityType: entityType,
            lastServerHlc: Value(lastServerHlc),
            lastSyncedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    String? hlc,
  }) async {
    final hlcStr = hlc ?? advanceHlc().pack();
    final outboxId = 'outbox_${entityType}_${entityId}_$hlcStr';
    await db
        .into(db.syncOutbox)
        .insertOnConflictUpdate(
          SyncOutboxCompanion.insert(
            id: outboxId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payloadJson: jsonEncode(payload),
            hlc: hlcStr,
          ),
        );
    onMutationEnqueued?.call();
  }

  /// Applies a batch of remote deltas pulled from the cloud directly into SQLite
  /// and updates in-memory caches WITHOUT enqueuing mutations into [syncOutbox].
  Future<void> applyRemoteDeltasBatch({
    List<Map<String, dynamic>> decks = const [],
    List<Map<String, dynamic>> cards = const [],
    List<Map<String, dynamic>> reviewLogs = const [],
    List<Map<String, dynamic>> grammarProgress = const [],
    List<Map<String, dynamic>> examSubmissions = const [],
    List<Map<String, dynamic>> wrongQuestions = const [],
  }) async {
    if (decks.isEmpty &&
        cards.isEmpty &&
        reviewLogs.isEmpty &&
        grammarProgress.isEmpty &&
        examSubmissions.isEmpty &&
        wrongQuestions.isEmpty) {
      return;
    }

    await db.transaction(() async {
      // 1. Apply Decks
      for (final raw in decks) {
        final deck = DeckModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

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
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 2. Apply Cards
      for (final raw in cards) {
        final card = CardModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

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
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 3. Apply Review Logs
      for (final raw in reviewLogs) {
        final log = ReviewLogModel.fromJson(raw);
        final clientLogId = log.clientLogId.isNotEmpty
            ? log.clientLogId
            : (raw['client_log_id'] as String? ??
                  'log_${log.cardId}_${log.reviewTime.millisecondsSinceEpoch}');

        final existing =
            await (db.select(db.reviewLogs)
                  ..where((tbl) => tbl.clientLogId.equals(clientLogId)))
                .getSingleOrNull();

        if (existing == null) {
          await db
              .into(db.reviewLogs)
              .insert(
                ReviewLogsCompanion.insert(
                  cardId: log.cardId,
                  rating: log.rating.value,
                  reviewTime: log.reviewTime,
                  scheduledDays: Value(log.scheduledDays),
                  elapsedDays: Value(log.elapsedDays),
                  clientLogId: Value(clientLogId),
                ),
              );
        }
      }

      // 4. Apply Grammar Progress
      for (final raw in grammarProgress) {
        final model = GrammarProgressModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await db
            .into(db.grammarProgressEntries)
            .insertOnConflictUpdate(
              GrammarProgressEntriesCompanion.insert(
                unitId: model.unitId,
                exerciseId: model.exerciseId,
                stability: Value(model.stability),
                difficulty: Value(model.difficulty),
                due: Value(model.due),
                lastStudied: Value(model.lastStudied),
                reps: Value(model.reps),
                lapses: Value(model.lapses),
                state: Value(model.state),
                isGhost: Value(model.isGhost),
                isCompleted: Value(model.isCompleted),
                lastUserAnswer: Value(model.lastUserAnswer),
                updatedAt: Value(model.updatedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 5. Apply Exam Submissions
      for (final raw in examSubmissions) {
        final submission = ExamSubmissionModel.fromJson(raw);
        final answersJson = raw['answers_json'] is String
            ? raw['answers_json'] as String
            : jsonEncode(submission.answers);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await db
            .into(db.examSubmissions)
            .insertOnConflictUpdate(
              ExamSubmissionsCompanion.insert(
                id: submission.id,
                examId: submission.examId,
                score: Value(submission.score),
                totalCorrect: Value(submission.totalCorrect),
                totalQuestions: Value(submission.totalQuestions),
                durationSeconds: Value(submission.durationSeconds),
                answersJson: Value(answersJson),
                submittedAt: Value(submission.submittedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }

      // 6. Apply Wrong Questions Notebook
      for (final raw in wrongQuestions) {
        final w = WrongQuestionModel.fromJson(raw);
        final hlc = raw['updated_at_hlc'] as String? ?? '';
        final isDeleted = raw['is_deleted'] as bool? ?? false;

        await db
            .into(db.wrongQuestionNotebook)
            .insertOnConflictUpdate(
              WrongQuestionNotebookCompanion.insert(
                id: w.id,
                examId: w.examId,
                questionId: w.questionId,
                userAnswer: w.userAnswer,
                explanation: Value(w.explanation),
                notes: Value(w.notes),
                status: Value(w.status.code),
                createdAt: Value(w.createdAt),
                updatedAt: Value(w.updatedAt),
                updatedAtHlc: Value(hlc),
                isDeleted: Value(isDeleted),
              ),
            );
      }
    });

    // Reload cache to reflect remote changes immediately
    await _reloadCache();
  }

  // --- Exam Bank Queries & Operations ---

  Future<void> saveExamCatalog(List<ExamPaperModel> exams) async {
    await db.transaction(() async {
      for (final exam in exams) {
        await db
            .into(db.examPapers)
            .insertOnConflictUpdate(
              ExamPapersCompanion.insert(
                id: exam.id,
                title: exam.title,
                description: Value(exam.description),
                category: Value(exam.category.code),
                level: Value(exam.level),
                durationMinutes: Value(exam.durationMinutes),
                totalQuestions: Value(exam.totalQuestions),
                passingScore: Value(exam.passingScore),
                iconName: Value(exam.iconName),
                version: Value(exam.version),
                isPublished: Value(exam.isPublished),
                isDownloaded: Value(exam.isDownloaded),
                createdAt: Value(exam.createdAt),
                updatedAt: Value(exam.updatedAt),
              ),
            );
      }
    });
  }

  Future<List<ExamPaperModel>> getExamCatalog({
    ExamCategory? category,
    String? level,
  }) async {
    final query = db.select(db.examPapers)
      ..where((tbl) => tbl.isPublished.equals(true));
    if (category != null) {
      query.where((tbl) => tbl.category.equals(category.code));
    }
    if (level != null && level.isNotEmpty) {
      query.where((tbl) => tbl.level.equals(level));
    }
    query.orderBy([
      (tbl) => OrderingTerm.asc(tbl.category),
      (tbl) => OrderingTerm.asc(tbl.level),
    ]);
    final rows = await query.get();
    return rows
        .map(
          (r) => ExamPaperModel(
            id: r.id,
            title: r.title,
            description: r.description,
            category: ExamCategory.fromString(r.category),
            level: r.level,
            durationMinutes: r.durationMinutes,
            totalQuestions: r.totalQuestions,
            passingScore: r.passingScore,
            iconName: r.iconName,
            version: r.version,
            isPublished: r.isPublished,
            isDownloaded: r.isDownloaded,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<ExamPaperModel?> getExamPaperById(String examId) async {
    final row = await (db.select(
      db.examPapers,
    )..where((tbl) => tbl.id.equals(examId))).getSingleOrNull();
    if (row == null) return null;
    return ExamPaperModel(
      id: row.id,
      title: row.title,
      description: row.description,
      category: ExamCategory.fromString(row.category),
      level: row.level,
      durationMinutes: row.durationMinutes,
      totalQuestions: row.totalQuestions,
      passingScore: row.passingScore,
      iconName: row.iconName,
      version: row.version,
      isPublished: row.isPublished,
      isDownloaded: row.isDownloaded,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<void> saveExamPaperWithQuestions(
    ExamPaperModel paper,
    List<ExamSectionModel> sections,
    List<ExamQuestionModel> questions,
  ) async {
    await db.transaction(() async {
      await db
          .into(db.examPapers)
          .insertOnConflictUpdate(
            ExamPapersCompanion.insert(
              id: paper.id,
              title: paper.title,
              description: Value(paper.description),
              category: Value(paper.category.code),
              level: Value(paper.level),
              durationMinutes: Value(paper.durationMinutes),
              totalQuestions: Value(paper.totalQuestions),
              passingScore: Value(paper.passingScore),
              iconName: Value(paper.iconName),
              version: Value(paper.version),
              isPublished: Value(paper.isPublished),
              isDownloaded: const Value(true),
              createdAt: Value(paper.createdAt),
              updatedAt: Value(paper.updatedAt),
            ),
          );

      for (final sec in sections) {
        await db
            .into(db.examSections)
            .insertOnConflictUpdate(
              ExamSectionsCompanion.insert(
                id: sec.id,
                examId: sec.examId,
                title: sec.title,
                sectionType: Value(sec.sectionType),
                orderIndex: Value(sec.orderIndex),
                instruction: Value(sec.instruction),
              ),
            );
      }

      for (final q in questions) {
        await db
            .into(db.examQuestions)
            .insertOnConflictUpdate(
              ExamQuestionsCompanion.insert(
                id: q.id,
                examId: q.examId,
                sectionId: q.sectionId,
                questionNumber: Value(q.questionNumber),
                questionText: q.questionText,
                contextPassage: Value(q.contextPassage),
                audioUrl: Value(q.audioUrl),
                optionsJson: Value(
                  jsonEncode(q.options.map((o) => o.toJson()).toList()),
                ),
                correctAnswer: q.correctAnswer,
                explanation: Value(q.explanation),
                points: Value(q.points),
              ),
            );
      }
    });
  }

  Future<List<ExamSectionModel>> getExamSections(String examId) async {
    final rows =
        await (db.select(db.examSections)
              ..where((tbl) => tbl.examId.equals(examId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
            .get();
    return rows
        .map(
          (r) => ExamSectionModel(
            id: r.id,
            examId: r.examId,
            title: r.title,
            sectionType: r.sectionType,
            orderIndex: r.orderIndex,
            instruction: r.instruction,
          ),
        )
        .toList();
  }

  Future<List<ExamQuestionModel>> getExamQuestions(String examId) async {
    final rows =
        await (db.select(db.examQuestions)
              ..where((tbl) => tbl.examId.equals(examId))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.questionNumber)]))
            .get();
    return rows
        .map(
          (r) => ExamQuestionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'section_id': r.sectionId,
            'question_number': r.questionNumber,
            'question_text': r.questionText,
            'context_passage': r.contextPassage,
            'audio_url': r.audioUrl,
            'options_json': r.optionsJson,
            'correct_answer': r.correctAnswer,
            'explanation': r.explanation,
            'points': r.points,
          }),
        )
        .toList();
  }

  Future<void> submitExamResult(
    ExamSubmissionModel submission,
    List<WrongQuestionModel> wrongQuestions, {
    bool markOutbox = true,
  }) async {
    final hlcStr = markOutbox ? advanceHlc().pack() : '';

    await db.transaction(() async {
      await db
          .into(db.examSubmissions)
          .insertOnConflictUpdate(
            ExamSubmissionsCompanion.insert(
              id: submission.id,
              examId: submission.examId,
              score: Value(submission.score),
              totalCorrect: Value(submission.totalCorrect),
              totalQuestions: Value(submission.totalQuestions),
              durationSeconds: Value(submission.durationSeconds),
              answersJson: Value(jsonEncode(submission.answers)),
              submittedAt: Value(submission.submittedAt),
              updatedAtHlc: Value(hlcStr),
              isDeleted: const Value(false),
            ),
          );

      if (markOutbox) {
        await db
            .into(db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'exam_sub',
                  entityId: submission.id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityExamSubmission,
                entityId: submission.id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(submission.toJson()),
                hlc: hlcStr,
              ),
            );
      }

      for (final w in wrongQuestions) {
        final wHlcStr = markOutbox ? advanceHlc().pack() : '';
        await db
            .into(db.wrongQuestionNotebook)
            .insertOnConflictUpdate(
              WrongQuestionNotebookCompanion.insert(
                id: w.id,
                examId: w.examId,
                questionId: w.questionId,
                userAnswer: w.userAnswer,
                explanation: Value(w.explanation),
                notes: Value(w.notes),
                status: Value(w.status.code),
                createdAt: Value(w.createdAt),
                updatedAt: Value(DateTime.now().toUtc()),
                updatedAtHlc: Value(wHlcStr),
                isDeleted: const Value(false),
              ),
            );

        if (markOutbox) {
          await db
              .into(db.syncOutbox)
              .insertOnConflictUpdate(
                SyncOutboxCompanion.insert(
                  id: IdHelper.outboxId(
                    prefix: 'wrong_q',
                    entityId: w.id,
                    hlc: wHlcStr,
                  ),
                  entityType: SupabaseConfig.entityWrongQuestion,
                  entityId: w.id,
                  operation: SupabaseConfig.opUpsert,
                  payloadJson: jsonEncode(w.toJson()),
                  hlc: wHlcStr,
                ),
              );
        }
      }
    });

    if (markOutbox) {
      onMutationEnqueued?.call();
    }
  }

  Future<List<ExamSubmissionModel>> getExamSubmissions(String examId) async {
    final rows =
        await (db.select(db.examSubmissions)
              ..where(
                (tbl) =>
                    tbl.examId.equals(examId) & tbl.isDeleted.equals(false),
              )
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.submittedAt)]))
            .get();
    return rows
        .map(
          (r) => ExamSubmissionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'score': r.score,
            'total_correct': r.totalCorrect,
            'total_questions': r.totalQuestions,
            'duration_seconds': r.durationSeconds,
            'answers_json': r.answersJson,
            'submitted_at': r.submittedAt.toIso8601String(),
            'updated_at_hlc': r.updatedAtHlc,
          }),
        )
        .toList();
  }

  Future<List<WrongQuestionModel>> getWrongQuestions({
    String? examId,
    WrongQuestionStatus? status,
  }) async {
    final query = db.select(db.wrongQuestionNotebook)
      ..where((tbl) => tbl.isDeleted.equals(false));
    if (examId != null) {
      query.where((tbl) => tbl.examId.equals(examId));
    }
    if (status != null) {
      query.where((tbl) => tbl.status.equals(status.code));
    }
    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    final rows = await query.get();
    return rows
        .map(
          (r) => WrongQuestionModel.fromJson({
            'id': r.id,
            'exam_id': r.examId,
            'question_id': r.questionId,
            'user_answer': r.userAnswer,
            'explanation': r.explanation,
            'notes': r.notes,
            'status': r.status,
            'created_at': r.createdAt.toIso8601String(),
            'updated_at': r.updatedAt.toIso8601String(),
            'updated_at_hlc': r.updatedAtHlc,
          }),
        )
        .toList();
  }

  Future<void> updateWrongQuestionStatus(
    String id,
    WrongQuestionStatus status, {
    bool markOutbox = true,
  }) async {
    final hlcStr = markOutbox ? advanceHlc().pack() : '';
    await db.transaction(() async {
      final existing = await (db.select(
        db.wrongQuestionNotebook,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      await (db.update(
        db.wrongQuestionNotebook,
      )..where((tbl) => tbl.id.equals(id))).write(
        WrongQuestionNotebookCompanion(
          status: Value(status.code),
          updatedAt: Value(DateTime.now().toUtc()),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      if (markOutbox) {
        final payload = existing != null
            ? WrongQuestionModel(
                id: id,
                examId: existing.examId,
                questionId: existing.questionId,
                userAnswer: existing.userAnswer,
                explanation: existing.explanation,
                notes: existing.notes,
                status: status,
                createdAt: existing.createdAt,
                updatedAt: DateTime.now().toUtc(),
              ).toJson()
            : WrongQuestionStatusPayload(
                id: id,
                status: status.code,
                updatedAt: DateTime.now().toUtc().toIso8601String(),
              ).toJson();

        await db
            .into(db.syncOutbox)
            .insertOnConflictUpdate(
              SyncOutboxCompanion.insert(
                id: IdHelper.outboxId(
                  prefix: 'wrong_status',
                  entityId: id,
                  hlc: hlcStr,
                ),
                entityType: SupabaseConfig.entityWrongQuestion,
                entityId: id,
                operation: SupabaseConfig.opUpsert,
                payloadJson: jsonEncode(payload),
                hlc: hlcStr,
              ),
            );
      }
    });

    if (markOutbox) {
      onMutationEnqueued?.call();
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
