import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../config/app_config.dart';
import '../../config/supabase_config.dart';
import '../../models/card.dart';
import '../../models/custom_study_mode.dart';
import '../../models/sync_payloads.dart';
import '../app_database.dart';
import 'database_context.dart';

class CardDao {
  final DatabaseContext _context;

  CardDao(this._context);

  AppDatabase get _db => _context.db;

  List<CardModel> getAllCards() => List.unmodifiable(_context.cachedCards);

  List<CardModel> getCardsForDeck(String deckId) {
    return _context.cachedCards.where((c) => c.deckId == deckId).toList();
  }

  List<CardModel> getStudyQueue(
    String deckId, {
    int? limit,
    int? newLimit,
    int? reviewLimit,
  }) {
    final now = DateTime.now();
    final eligible = _context.cachedCards.where(
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
    return _context.cachedCards
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

    final deckCount = _context.cachedDecks
        .firstWhereOrNull((d) => d.id == deckId)
        ?.totalCount;
    final effectiveLimit =
        parsedLimit ??
        (deckCount != null && deckCount > 0 ? deckCount : null) ??
        limit ??
        AppConfig.defaultCramLimit;

    final available = _context.cachedCards
        .where((c) => !c.isSuspended)
        .toList();

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
    final available = _context.cachedCards.where((c) => !c.isSuspended);
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

  Future<void> saveCard(CardModel card, {bool markOutbox = true}) async {
    final parentDeck = _context.cachedDecks.firstWhereOrNull(
      (d) => d.id == card.deckId,
    );
    final shouldMarkOutbox = markOutbox && (parentDeck?.isSyncEnabled != false);

    // Optimistic cache update
    final idx = _context.cachedCards.indexWhere((c) => c.id == card.id);
    if (idx >= 0) {
      _context.cachedCards[idx] = card;
    } else {
      _context.cachedCards.insert(0, card);
    }

    final hlcStr = shouldMarkOutbox ? _context.advanceHlc().pack() : '';

    await _db.transaction(() async {
      await _db
          .into(_db.cards)
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

      if (shouldMarkOutbox) {
        await _db
            .into(_db.syncOutbox)
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
    await _context.reloadCache();
    if (shouldMarkOutbox) {
      _context.onMutationEnqueued?.call();
    }
  }

  Future<void> saveCards(
    List<CardModel> cards, {
    bool markOutbox = true,
  }) async {
    for (final card in cards) {
      final idx = _context.cachedCards.indexWhere((c) => c.id == card.id);
      if (idx >= 0) {
        _context.cachedCards[idx] = card;
      } else {
        _context.cachedCards.insert(0, card);
      }
    }

    bool anyOutboxEnqueued = false;

    await _db.transaction(() async {
      for (final card in cards) {
        final parentDeck = _context.cachedDecks.firstWhereOrNull(
          (d) => d.id == card.deckId,
        );
        final shouldMarkOutbox =
            markOutbox && (parentDeck?.isSyncEnabled != false);
        final hlcStr = shouldMarkOutbox ? _context.advanceHlc().pack() : '';

        await _db
            .into(_db.cards)
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

        if (shouldMarkOutbox) {
          anyOutboxEnqueued = true;
          await _db
              .into(_db.syncOutbox)
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
    await _context.reloadCache();
    if (anyOutboxEnqueued) {
      _context.onMutationEnqueued?.call();
    }
  }

  /// Merges remote cards into the local collection using smart Last-Write-Wins per card.
  /// Preserves local study progress if local was studied more recently than remote,
  /// and adopts remote study progress if remote was studied more recently.
  Future<void> mergeCards(List<CardModel> remoteCards) async {
    final localCardsMap = {for (final c in _context.cachedCards) c.id: c};
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
    for (final local in _context.cachedCards) {
      if (!remoteIds.contains(local.id)) {
        mergedCards.add(local);
      }
    }

    await saveCards(mergedCards);
  }

  Future<void> deleteCard(String cardId, {bool markOutbox = true}) async {
    final cardToDelete = _context.cachedCards.firstWhereOrNull(
      (c) => c.id == cardId,
    );
    final parentDeck = cardToDelete != null
        ? _context.cachedDecks.firstWhereOrNull(
            (d) => d.id == cardToDelete.deckId,
          )
        : null;
    final shouldMarkOutbox = markOutbox && (parentDeck?.isSyncEnabled != false);

    _context.cachedCards.removeWhere((c) => c.id == cardId);
    final hlcStr = shouldMarkOutbox ? _context.advanceHlc().pack() : '';

    await _db.transaction(() async {
      await (_db.update(
        _db.cards,
      )..where((tbl) => tbl.id.equals(cardId))).write(
        CardsCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      if (shouldMarkOutbox) {
        await _db
            .into(_db.syncOutbox)
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
    await _context.reloadCache();
    if (shouldMarkOutbox) {
      _context.onMutationEnqueued?.call();
    }
  }

  static String cleanMediaPaths(String html) {
    if (!html.contains(AppConfig.appMediaBaseDirectory)) return html;
    return html.replaceAllMapped(
      RegExp(
        r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
    );
  }

  static CardModel mapRowToCard(Card row) {
    final tags = row.tags.isNotEmpty ? row.tags.split(',') : <String>[];
    return CardModel(
      id: row.id,
      deckId: row.deckId,
      front: cleanMediaPaths(row.front),
      back: cleanMediaPaths(row.back),
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
}
