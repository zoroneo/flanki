import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../fsrs/fsrs_engine_service.dart';
import '../fsrs/sm2_engine_service.dart';
import '../models/card.dart';
import '../services/notification_service.dart';
import '../states/study_session_state.dart';
import '../storage/database_service.dart';
import 'card_browser_notifier.dart';
import 'deck_notifier.dart';
import 'settings_notifier.dart';
import '../../features/stats/providers/stats_notifier.dart';

export '../states/study_session_state.dart';

part 'study_session_notifier.g.dart';

@Riverpod(keepAlive: true, name: 'studySessionProvider')
class StudySessionNotifier extends _$StudySessionNotifier {
  @override
  StudySessionState build() {
    final settings = ref.watch(studySettingsProvider);
    return StudySessionState.initial('', settings: settings);
  }

  void init(String deckId) {
    final settings = ref.read(studySettingsProvider);
    if (state.deckId != deckId || state.isFinished) {
      state = StudySessionState.initial(deckId, settings: settings);
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

    // 2. Dynamic Spaced Repetition calculation (FSRS vs SM-2 based on user settings)
    final settings = ref.read(studySettingsProvider);
    final CardModel scheduledCard;
    if (settings.fsrsEnabled) {
      final fsrsService = FsrsEngineService(
        desiredRetention: settings.desiredRetention,
      );
      scheduledCard = fsrsService.scheduleReview(current, rating);
    } else {
      const sm2Service = Sm2EngineService();
      scheduledCard = sm2Service.scheduleReview(current, rating);
    }

    // 3. Track real elapsed study time
    final now = DateTime.now();
    final elapsedSeconds = state.cardPresentedAt != null
        ? now.difference(state.cardPresentedAt!).inSeconds.clamp(1, 120)
        : 15;
    ref
        .read(statsNotifierProvider.notifier)
        .recordStudyDuration(elapsedSeconds);

    // 4. Persist card updates and record Review Log into SQLite
    DatabaseService.instance.saveCard(scheduledCard);
    DatabaseService.instance.insertReviewLog(
      cardId: scheduledCard.id,
      rating: rating,
      reviewTime: now,
      scheduledDays: scheduledCard.intervalDays,
      elapsedDays: current.lastStudied != null
          ? now.difference(current.lastStudied!).inDays
          : 0,
    );

    ref.read(statsNotifierProvider.notifier).refresh();
    ref.read(deckListProvider.notifier).refresh();
    ref.read(cardBrowserProvider.notifier).refresh();
    NotificationService.instance.onStudyCompletedToday();

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
        cardPresentedAt: DateTime.now(),
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
    final updatedCard = state.currentCard!.copyWith(front: front, back: back);
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
        cardPresentedAt: DateTime.now(),
      );
    }
  }

  void restart() {
    final settings = ref.read(studySettingsProvider);
    state = StudySessionState.initial(state.deckId, settings: settings);
  }
}
