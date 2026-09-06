import '../fsrs/fsrs_engine_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card.dart';

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
    final cards = _getCardsForDeck(deckId);
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

  static List<CardModel> _getCardsForDeck(String deckId) {
    return [
      CardModel(
        id: 'c1',
        deckId: deckId,
        front: 'Abundant (adj)',
        back: 'Dồi dào, phong phú, thừa thãi\n\nVí dụ: Fish are abundant in this lake.',
        hint: 'Nhiều hơn mức bình thường',
        tags: ['vocabulary', 'toeic', 'c1'],
        intervalDays: 1,
        stability: 2.1,
        difficulty: 3.4,
        reps: 2,
      ),
      CardModel(
        id: 'c2',
        deckId: deckId,
        front: 'FSRS (Free Spaced Repetition Scheduler)',
        back: 'Thuật toán lặp lại ngắt quãng thế hệ mới dựa trên mô hình DSR (Difficulty, Stability, Retrievability) tối ưu hơn SM-2.',
        hint: 'Thuật toán học tập lõi của Anki hiện đại',
        tags: ['algorithm', 'anki', 'fsrs'],
        intervalDays: 3,
        stability: 4.8,
        difficulty: 4.1,
        reps: 4,
      ),
      CardModel(
        id: 'c3',
        deckId: deckId,
        front: 'Pragmatic (adj)',
        back: 'Thực dụng, thực tế, giải quyết vấn đề dựa trên hiệu quả thực tiễn thay vì lý thuyết suông.',
        hint: 'Từ trái nghĩa với idealistic',
        tags: ['philosophy', 'vocabulary'],
        intervalDays: 5,
        stability: 7.2,
        difficulty: 2.9,
        reps: 5,
      ),
      CardModel(
        id: 'c4',
        deckId: deckId,
        front: 'Zero-cost Abstraction (Rust)',
        back: 'Những gì bạn không dùng thì không phải trả giá; những gì bạn dùng thì bạn không thể tự viết tay tốt hơn compiler tối ưu.',
        hint: 'Nguyên lý cốt lõi của Bjarne Stroustrup & Rust',
        tags: ['rust', 'programming'],
        intervalDays: 7,
        stability: 11.5,
        difficulty: 5.0,
        reps: 8,
      ),
    ];
  }
}

final studySessionProvider =
    NotifierProvider<StudySessionNotifier, StudySessionState>(
  StudySessionNotifier.new,
);

class StudySessionNotifier extends Notifier<StudySessionState> {
  @override
  StudySessionState build() {
    return StudySessionState.initial('default');
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

  void rateCard(int rating) {
    if (state.currentCard == null) return;

    // Push current snapshot to history stack for Undo
    final snapshot = StudySessionSnapshot(
      queue: List<CardModel>.from(state.queue),
      currentCard: state.currentCard,
      isFlipped: state.isFlipped,
      completedCount: state.completedCount,
      isFinished: state.isFinished,
    );
    final updatedHistory = [...state.history, snapshot];

    // Compute updated card with FSRS scheduling
    final fsrsService = FsrsEngineService();
    final scheduledCard = fsrsService.scheduleReview(state.currentCard!, rating);

    final remainingQueue = List<CardModel>.from(state.queue);
    final finishedCount = state.completedCount + 1;

    if (rating == 1) {
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

  /// Undo the last rating and restore previous card state
  bool undo() {
    if (!state.canUndo) return false;

    final historyList = List<StudySessionSnapshot>.from(state.history);
    final lastSnapshot = historyList.removeLast();

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

  /// Toggle flag (0: None, 1..7: Anki 7 colors)
  void toggleFlag(int flagColor) {
    if (state.currentCard == null) return;
    final currentFlag = state.currentCard!.flag;
    final newFlag = (currentFlag == flagColor) ? 0 : flagColor;

    final updatedCard = state.currentCard!.copyWith(flag: newFlag);
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

  /// Bury current card (postpone until tomorrow)
  void buryCurrentCard() {
    if (state.currentCard == null) return;
    _skipCurrentCard();
  }

  /// Suspend current card (disable until un-suspended)
  void suspendCurrentCard() {
    if (state.currentCard == null) return;
    _skipCurrentCard();
  }

  /// Edit card front and back directly in session
  void editCurrentCard(String front, String back) {
    if (state.currentCard == null) return;
    final updatedCard = state.currentCard!.copyWith(
      front: front,
      back: back,
    );
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
