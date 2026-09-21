import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../config/app_config.dart';
import '../../config/supabase_config.dart';
import '../../models/deck.dart';
import '../../models/sync_payloads.dart';
import '../app_database.dart';
import 'database_context.dart';

class DeckDao {
  final DatabaseContext _context;

  DeckDao(this._context);

  AppDatabase get _db => _context.db;

  List<DeckModel> getAllDecks() => List.unmodifiable(_context.cachedDecks);

  Future<void> saveDeck(DeckModel deck) async {
    final duplicate = _context.cachedDecks.firstWhereOrNull(
      (d) =>
          d.title.trim().toLowerCase() == deck.title.trim().toLowerCase() &&
          d.id != deck.id,
    );

    if (duplicate != null) {
      // Re-assign all cards from duplicate deck to this deck
      await (_db.update(_db.cards)
            ..where((tbl) => tbl.deckId.equals(duplicate.id)))
          .write(CardsCompanion(deckId: Value(deck.id)));
      await (_db.delete(
        _db.decks,
      )..where((tbl) => tbl.id.equals(duplicate.id))).go();
      _context.cachedDecks.removeWhere((d) => d.id == duplicate.id);
    }

    final idx = _context.cachedDecks.indexWhere((d) => d.id == deck.id);
    if (idx >= 0) {
      _context.cachedDecks[idx] = deck;
    } else {
      _context.cachedDecks.add(deck);
    }

    final hlcStr = _context.advanceHlc().pack();

    await _db.transaction(() async {
      await _db
          .into(_db.decks)
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
              isSyncEnabled: Value(deck.isSyncEnabled),
            ),
          );

      await _db
          .into(_db.syncOutbox)
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
    await _context.reloadCache();
    _context.onMutationEnqueued?.call();
  }

  Future<void> recordDeckStudyProgress(String deckId) async {
    final deck = _context.cachedDecks.firstWhereOrNull((d) => d.id == deckId);
    if (deck != null) {
      final remaining = (deck.dueCount > 0) ? deck.dueCount - 1 : 0;
      final updated = deck.copyWith(
        dueCount: remaining,
        lastStudied: DateTime.now(),
      );
      await saveDeck(updated);
    }
  }

  Future<void> saveDecks(List<DeckModel> decks) async {
    for (final incomingDeck in decks) {
      final duplicate = _context.cachedDecks.firstWhereOrNull(
        (d) =>
            d.title.trim().toLowerCase() ==
                incomingDeck.title.trim().toLowerCase() &&
            d.id != incomingDeck.id,
      );

      if (duplicate != null) {
        await (_db.update(_db.cards)
              ..where((tbl) => tbl.deckId.equals(duplicate.id)))
            .write(CardsCompanion(deckId: Value(incomingDeck.id)));
        await (_db.delete(
          _db.decks,
        )..where((tbl) => tbl.id.equals(duplicate.id))).go();
        _context.cachedDecks.removeWhere((d) => d.id == duplicate.id);
      }

      final idx = _context.cachedDecks.indexWhere(
        (d) => d.id == incomingDeck.id,
      );
      if (idx >= 0) {
        _context.cachedDecks[idx] = incomingDeck;
      } else {
        _context.cachedDecks.add(incomingDeck);
      }
    }

    final hlcStr = _context.advanceHlc().pack();

    await _db.transaction(() async {
      for (final deck in decks) {
        await _db
            .into(_db.decks)
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
                isSyncEnabled: Value(deck.isSyncEnabled),
              ),
            );

        await _db
            .into(_db.syncOutbox)
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
    await _context.reloadCache();
    _context.onMutationEnqueued?.call();
  }

  /// Removes duplicate decks with the same title, merging cards into the canonical deck.
  Future<void> deduplicateDecks() async {
    final allDecks = await _db.select(_db.decks).get();
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
          final count = (await (_db.select(
            _db.cards,
          )..where((tbl) => tbl.deckId.equals(d.id))).get()).length;
          if (count > maxCards) {
            maxCards = count;
            canonical = d;
          }
        }

        // Migrate cards from other duplicate decks to canonical deck and delete the duplicates
        for (final d in duplicateList) {
          if (d.id != canonical.id) {
            await (_db.update(_db.cards)
                  ..where((tbl) => tbl.deckId.equals(d.id)))
                .write(CardsCompanion(deckId: Value(canonical.id)));
            await (_db.delete(
              _db.decks,
            )..where((tbl) => tbl.id.equals(d.id))).go();
          }
        }
      }
    }

    if (hasDuplicates) {
      await _context.reloadCache();
      await recalculateAllDeckCounts();
    }
  }

  Future<void> deleteDeck(String deckId) async {
    _context.cachedDecks.removeWhere((d) => d.id == deckId);
    _context.cachedCards.removeWhere((c) => c.deckId == deckId);
    final hlcStr = _context.advanceHlc().pack();

    await _db.transaction(() async {
      await (_db.update(
        _db.cards,
      )..where((tbl) => tbl.deckId.equals(deckId))).write(
        CardsCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );
      await (_db.update(
        _db.decks,
      )..where((tbl) => tbl.id.equals(deckId))).write(
        DecksCompanion(
          isDeleted: const Value(true),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      await _db
          .into(_db.syncOutbox)
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
    await _context.reloadCache();
    _context.onMutationEnqueued?.call();
  }

  /// Toggles sync status for a specific deck and handles card outbox synchronization.
  Future<void> toggleDeckSync(String deckId, bool enabled) async {
    final deckIdx = _context.cachedDecks.indexWhere((d) => d.id == deckId);
    if (deckIdx < 0) return;

    final oldDeck = _context.cachedDecks[deckIdx];
    final updatedDeck = oldDeck.copyWith(isSyncEnabled: enabled);
    _context.cachedDecks[deckIdx] = updatedDeck;

    final hlcStr = _context.advanceHlc().pack();

    await _db.transaction(() async {
      await (_db.update(
        _db.decks,
      )..where((tbl) => tbl.id.equals(deckId))).write(
        DecksCompanion(
          isSyncEnabled: Value(enabled),
          updatedAtHlc: Value(hlcStr),
        ),
      );

      // Always enqueue deck update so remote knows sync state
      await _db
          .into(_db.syncOutbox)
          .insertOnConflictUpdate(
            SyncOutboxCompanion.insert(
              id: IdHelper.outboxId(
                prefix: 'deck',
                entityId: deckId,
                hlc: hlcStr,
              ),
              entityType: SupabaseConfig.entityDeck,
              entityId: deckId,
              operation: SupabaseConfig.opUpsert,
              payloadJson: jsonEncode(updatedDeck.toJson()),
              hlc: hlcStr,
            ),
          );

      // If re-enabling sync: enqueue all non-deleted cards of this deck into syncOutbox
      if (enabled) {
        final cards = _context.cachedCards
            .where((c) => c.deckId == deckId)
            .toList();
        for (final card in cards) {
          final cardHlc = _context.advanceHlc().pack();
          await _db
              .into(_db.syncOutbox)
              .insertOnConflictUpdate(
                SyncOutboxCompanion.insert(
                  id: IdHelper.outboxId(
                    prefix: 'card',
                    entityId: card.id,
                    hlc: cardHlc,
                  ),
                  entityType: SupabaseConfig.entityCard,
                  entityId: card.id,
                  operation: SupabaseConfig.opUpsert,
                  payloadJson: jsonEncode(card.toJson()),
                  hlc: cardHlc,
                ),
              );
        }
      }
    });

    await _context.reloadCache();
    _context.onMutationEnqueued?.call();
  }

  Future<void> recalculateAllDeckCounts() async {
    final now = DateTime.now();

    // Optimistic cache calculation
    final updatedList = <DeckModel>[];
    for (final d in _context.cachedDecks) {
      final deckCards = _context.cachedCards
          .where((c) => c.deckId == d.id)
          .toList();
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
    _context.cachedDecks = updatedList;

    final allDecks = await _db.select(_db.decks).get();
    for (final d in allDecks) {
      final deckCards = await (_db.select(
        _db.cards,
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

      await (_db.update(_db.decks)..where((tbl) => tbl.id.equals(d.id))).write(
        DecksCompanion(
          totalCount: Value(total),
          newCount: Value(newC),
          dueCount: Value(dueC),
        ),
      );
    }
    await _context.reloadCache();
  }
}
