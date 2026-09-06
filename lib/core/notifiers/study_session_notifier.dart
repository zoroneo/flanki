import '../fsrs/fsrs_engine_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';
import '../storage/database_service.dart';
import 'card_browser_notifier.dart';
import 'deck_notifier.dart';
import 'stats_notifier.dart';

class StudySessionSnapshot {
  final List<CardModel> queue;
  final CardModel? currentCard;
  final bool isFlipped;
  final int completedCount;
  final bool isFinished;

  const StudySessionSnapshot({
    required this.queue,
    required this.currentCard,
    required this.isFlipped,
    required this.completedCount,
    required this.isFinished,
  });
}

class StudySessionState {
  final String deckId;
  final List<CardModel> queue;
  final CardModel? currentCard;
  final bool isFlipped;
  final int completedCount;
  final int initialCount;
  final bool isFinished;
  final List<StudySessionSnapshot> history;

  const StudySessionState({
    required this.deckId,
    required this.queue,
    this.currentCard,
    this.isFlipped = false,
    this.completedCount = 0,
    this.initialCount = 0,
    this.isFinished = false,
    this.history = const [],
  });

  bool get canUndo => history.isNotEmpty;

  factory StudySessionState.initial(String deckId) {
    if (deckId.isEmpty) {
      return const StudySessionState(
        deckId: '',
        queue: [],
        currentCard: null,
        isFlipped: false,
        completedCount: 0,
        initialCount: 0,
        isFinished: true,
        history: [],
      );
    }

    final List<CardModel> cards;
    if (deckId.startsWith('cram')) {
      // Custom Study / Cram Deck: query matching cards
      cards = DatabaseService.instance.getCustomStudyQueue(deckId: deckId, limit: 50);
    } else {
      cards = DatabaseService.instance.getStudyQueue(deckId, limit: 50);
    }

    return StudySessionState(
      deckId: deckId,
      queue: cards.skip(1).toList(),
      currentCard: cards.isNotEmpty ? cards.first : null,
      isFlipped: false,
      completedCount: 0,
      initialCount: cards.length,
      isFinished: cards.isEmpty,
      history: const [],
    );
  }

  double get progress =>
      initialCount == 0 ? 1.0 : completedCount / initialCount;
}

final studySessionProvider =
    NotifierProvider<StudySessionNotifier, StudySessionState>(
  StudySessionNotifier.new,
);

class StudySessionNotifier extends Notifier<StudySessionState> {
  @override
  StudySessionState build() {
    return StudySessionState.initial('');
  }

  void init(String deckId) {
    if (state.deckId != deckId || state.isFinished) {
      state = StudySessionState.initial(deckId);
    }
  }

  void flip() {
    if (!state.isFlipped && state.currentCard != null) {
      state = StudySessionState(
        deckId: state.deckId,
        queue: state.queue,
        currentCard: state.currentCard,
        isFlipped: true,
        completedCount: state.completedCount,
        initialCount: state.initialCount,
        isFinished: state.isFinished,
        history: state.history,
      );
    }
  }

  void rateCard(ReviewRating rating) {
    final current = state.currentCard;
    if (current == null) return;

    // 1. Push snapshot to history for Undo
    final snapshot = StudySessionSnapshot(
      queue: List<CardModel>.from(state.queue),
      currentCard: current,
      isFlipped: state.isFlipped,
      completedCount: state.completedCount,
      isFinished: state.isFinished,
    );
    final updatedHistory = [...state.history, snapshot];

    // 2. FSRS Spaced Repetition calculation
    final fsrsService = FsrsEngineService();
    final scheduledCard = fsrsService.scheduleReview(current, rating);

    // 3. Persist card updates and record Review Log into SQLite
    DatabaseService.instance.saveCard(scheduledCard);
    DatabaseService.instance.insertReviewLog(
      cardId: scheduledCard.id,
      rating: rating,
      reviewTime: DateTime.now(),
      scheduledDays: scheduledCard.intervalDays,
      elapsedDays: current.lastStudied != null
          ? DateTime.now().difference(current.lastStudied!).inDays
          : 0,
    );

    ref.read(statsNotifierProvider.notifier).refresh();
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();

    final remainingQueue = List<CardModel>.from(state.queue);
    final finishedCount = state.completedCount + 1;

    if (rating == ReviewRating.again) {
      // Re-queue card to end of queue for relearning
      remainingQueue.add(scheduledCard);
    }

    if (remainingQueue.isEmpty) {
      state = StudySessionState(
        deckId: state.deckId,
        queue: const [],
        currentCard: null,
        isFlipped: false,
        completedCount: finishedCount,
        initialCount: state.initialCount,
        isFinished: true,
        history: updatedHistory,
      );
    } else {
      final nextCard = remainingQueue.removeAt(0);
      state = StudySessionState(
        deckId: state.deckId,
        queue: remainingQueue,
        currentCard: nextCard,
        isFlipped: false,
        completedCount: finishedCount,
        initialCount: state.initialCount,
        isFinished: false,
        history: updatedHistory,
      );
    }
  }

  bool undo() {
    if (!state.canUndo) return false;

    final historyList = List<StudySessionSnapshot>.from(state.history);
    final lastSnapshot = historyList.removeLast();

    // Revert card state in DB if needed
    if (lastSnapshot.currentCard != null) {
      DatabaseService.instance.saveCard(lastSnapshot.currentCard!);
    }

    ref.read(statsNotifierProvider.notifier).refresh();
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();

    state = StudySessionState(
      deckId: state.deckId,
      queue: lastSnapshot.queue,
      currentCard: lastSnapshot.currentCard,
      isFlipped: lastSnapshot.isFlipped,
      completedCount: lastSnapshot.completedCount,
      initialCount: state.initialCount,
      isFinished: lastSnapshot.isFinished,
      history: historyList,
    );
    return true;
  }

  void toggleFlag(CardFlag flagColor) {
    if (state.currentCard == null) return;
    final currentFlag = state.currentCard!.flag;
    final newFlag = (currentFlag == flagColor) ? CardFlag.none : flagColor;

    final updatedCard = state.currentCard!.copyWith(flag: newFlag);
    DatabaseService.instance.saveCard(updatedCard);
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();

    state = StudySessionState(
      deckId: state.deckId,
      queue: state.queue,
      currentCard: updatedCard,
      isFlipped: state.isFlipped,
      completedCount: state.completedCount,
      initialCount: state.initialCount,
      isFinished: state.isFinished,
      history: state.history,
    );
  }

  void buryCurrentCard() {
    if (state.currentCard == null) return;
    final buriedCard = state.currentCard!.copyWith(isBuried: true);
    DatabaseService.instance.saveCard(buriedCard);
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();
    _skipCurrentCard();
  }

  void suspendCurrentCard() {
    if (state.currentCard == null) return;
    final suspendedCard = state.currentCard!.copyWith(isSuspended: true);
    DatabaseService.instance.saveCard(suspendedCard);
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();
    _skipCurrentCard();
  }

  void deleteCurrentCard() {
    if (state.currentCard == null) return;
    final cardId = state.currentCard!.id;
    DatabaseService.instance.deleteCard(cardId);
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();
    ref.read(statsNotifierProvider.notifier).refresh();
    _skipCurrentCard();
  }

  void editCurrentCard(String front, String back) {
    if (state.currentCard == null) return;
    final updatedCard = state.currentCard!.copyWith(
      front: front,
      back: back,
    );
    DatabaseService.instance.saveCard(updatedCard);
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();

    state = StudySessionState(
      deckId: state.deckId,
      queue: state.queue,
      currentCard: updatedCard,
      isFlipped: state.isFlipped,
      completedCount: state.completedCount,
      initialCount: state.initialCount,
      isFinished: state.isFinished,
      history: state.history,
    );
  }

  void _skipCurrentCard() {
    final remainingQueue = List<CardModel>.from(state.queue);
    if (remainingQueue.isEmpty) {
      state = StudySessionState(
        deckId: state.deckId,
        queue: const [],
        currentCard: null,
        isFlipped: false,
        completedCount: state.completedCount,
        initialCount: state.initialCount,
        isFinished: true,
        history: state.history,
      );
    } else {
      final nextCard = remainingQueue.removeAt(0);
      state = StudySessionState(
        deckId: state.deckId,
        queue: remainingQueue,
        currentCard: nextCard,
        isFlipped: false,
        completedCount: state.completedCount,
        initialCount: state.initialCount,
        isFinished: false,
        history: state.history,
      );
    }
  }

  void restart() {
    state = StudySessionState.initial(state.deckId);
  }
}
