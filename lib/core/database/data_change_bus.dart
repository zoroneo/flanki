import 'dart:async';

/// Scope of data that has been mutated in SQLite or via synchronization.
enum DataScope { all, decks, cards, reviews }

/// Lightweight event bus notifying active Riverpod notifiers when data changes,
/// preventing direct cross-feature provider coupling.
class DataChangeBus {
  static final DataChangeBus instance = DataChangeBus._();
  DataChangeBus._();

  final StreamController<DataScope> _controller =
      StreamController<DataScope>.broadcast();

  /// Stream of data mutation events.
  Stream<DataScope> get stream => _controller.stream;

  /// Emits a data change notification for the given [scope].
  void notify(DataScope scope) {
    if (!_controller.isClosed) {
      _controller.add(scope);
    }
  }

  /// Convenience helper to notify card changes.
  void notifyCards() => notify(DataScope.cards);

  /// Convenience helper to notify deck changes.
  void notifyDecks() => notify(DataScope.decks);

  /// Convenience helper to notify review log changes.
  void notifyReviews() => notify(DataScope.reviews);

  /// Convenience helper to notify all data changes.
  void notifyAll() => notify(DataScope.all);
}
