import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/data_change_bus.dart';
import '../database/database_service.dart';
import '../models/deck.dart';

/// Shared read-only provider exposing active decks across features
/// without creating tight coupling to features/decks/.
final sharedDeckListProvider = Provider<List<DeckModel>>((ref) {
  final sub = DataChangeBus.instance.stream.listen((scope) {
    if (scope == DataScope.all ||
        scope == DataScope.decks ||
        scope == DataScope.cards) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(sub.cancel);
  return DatabaseService.instance.getAllDecks();
});
