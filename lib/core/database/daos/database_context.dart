import 'dart:async';

import '../app_database.dart';
import '../../models/card.dart';
import '../../models/deck.dart';
import '../../models/review_log.dart';
import '../../sync/hlc.dart';

/// Context interface provided by [DatabaseService] to its constituent DAOs.
abstract class DatabaseContext {
  AppDatabase get db;
  String get nodeId;
  Hlc advanceHlc({int? wallTime});
  void Function()? get onMutationEnqueued;
  Future<void> reloadCache();

  List<DeckModel> get cachedDecks;
  set cachedDecks(List<DeckModel> decks);

  List<CardModel> get cachedCards;
  set cachedCards(List<CardModel> cards);

  List<ReviewLogModel> get cachedReviewLogs;
  set cachedReviewLogs(List<ReviewLogModel> logs);

  Future<void> enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    String? hlc,
  });
}
