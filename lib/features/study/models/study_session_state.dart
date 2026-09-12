import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/card.dart';
import '../../settings/models/settings_state.dart';
import '../../../core/storage/database_service.dart';

part 'study_session_state.freezed.dart';

@freezed
abstract class StudySessionSnapshot with _$StudySessionSnapshot {
  const factory StudySessionSnapshot({
    required List<CardModel> queue,
    required CardModel? currentCard,
    required bool isFlipped,
    required int completedCount,
    required bool isFinished,
  }) = _StudySessionSnapshot;
}

@freezed
abstract class StudySessionState with _$StudySessionState {
  const StudySessionState._();

  const factory StudySessionState({
    required String deckId,
    required List<CardModel> queue,
    CardModel? currentCard,
    @Default(false) bool isFlipped,
    @Default(0) int completedCount,
    @Default(0) int initialCount,
    @Default(false) bool isFinished,
    @Default([]) List<StudySessionSnapshot> history,
    DateTime? cardPresentedAt,
  }) = _StudySessionState;

  bool get canUndo => history.isNotEmpty;

  factory StudySessionState.initial(String deckId, {StudySettings? settings}) {
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
      // Custom Study / Cram Deck: query matching cards with resilient fallback
      final fallbackLimit =
          settings?.maxReviewsPerDay ?? AppConfig.defaultCramLimit;
      cards = DatabaseService.instance.getCustomStudyQueue(
        deckId: deckId,
        limit: fallbackLimit,
      );
    } else {
      final newLimit =
          settings?.newCardsPerDay ?? AppConfig.defaultNewCardsPerDay;
      final reviewLimit =
          settings?.maxReviewsPerDay ?? AppConfig.defaultReviewsPerDay;
      cards = DatabaseService.instance.getStudyQueue(
        deckId,
        newLimit: newLimit,
        reviewLimit: reviewLimit,
      );
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
      cardPresentedAt: cards.isNotEmpty ? DateTime.now() : null,
    );
  }

  double get progress =>
      initialCount == 0 ? 1.0 : completedCount / initialCount;
}
