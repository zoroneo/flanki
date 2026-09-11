import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/models/grammar/grammar_models.dart';
import 'package:flanki/core/notifiers/grammar_session_notifier.dart';
import 'package:flanki/core/storage/app_database.dart';
import 'package:flanki/core/storage/grammar_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GrammarAnswerEvaluator Tests', () {
    test('Evaluates Multiple Choice questions accurately', () {
      const ex = GrammarExercise(
        id: 'ex_01',
        type: GrammarExerciseType.choice,
        difficulty: GrammarDifficulty.recognition,
        prompt: 'He _______ to school.',
        options: ['goes', 'go', 'is go', 'going'],
        correctAnswer: 'goes',
        explanation: GrammarExplanation(
          translation: '',
          keySignal: '',
          rule: '',
          whyCorrect: '',
        ),
      );

      expect(GrammarAnswerEvaluator.isCorrect(ex, 'goes'), isTrue);
      expect(GrammarAnswerEvaluator.isCorrect(ex, 'go'), isFalse);
      expect(GrammarAnswerEvaluator.isCorrect(ex, ''), isFalse);
    });

    test('Evaluates Error ID questions (case-insensitive A,B,C,D)', () {
      const ex = GrammarExercise(
        id: 'ex_06',
        type: GrammarExerciseType.errorId,
        difficulty: GrammarDifficulty.analysis,
        prompt: 'The [A] team are [B] working [C] on [D] it.',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'B',
        explanation: GrammarExplanation(
          translation: '',
          keySignal: '',
          rule: '',
          whyCorrect: '',
        ),
      );

      expect(GrammarAnswerEvaluator.isCorrect(ex, 'B'), isTrue);
      expect(GrammarAnswerEvaluator.isCorrect(ex, 'b'), isTrue);
      expect(GrammarAnswerEvaluator.isCorrect(ex, 'A'), isFalse);
    });

    test('Evaluates Cloze with advanced normalization (case, spaces, quotes, punctuation)', () {
      const ex = GrammarExercise(
        id: 'ex_11',
        type: GrammarExerciseType.cloze,
        difficulty: GrammarDifficulty.analysis,
        prompt: 'She hasn\'t ________ (arrive) yet.',
        options: [],
        correctAnswer: "haven't arrived",
        explanation: GrammarExplanation(
          translation: '',
          keySignal: '',
          rule: '',
          whyCorrect: '',
        ),
      );

      // Exact
      expect(GrammarAnswerEvaluator.isCorrect(ex, "haven't arrived"), isTrue);
      // Case insensitive
      expect(GrammarAnswerEvaluator.isCorrect(ex, "Haven't Arrived"), isTrue);
      // Extra spaces & trailing period
      expect(
        GrammarAnswerEvaluator.isCorrect(ex, "  haven't   arrived. "),
        isTrue,
      );
      // Curly quote
      expect(GrammarAnswerEvaluator.isCorrect(ex, "haven’t arrived"), isTrue);
      // Wrong answer
      expect(GrammarAnswerEvaluator.isCorrect(ex, "hasn't arrived"), isFalse);
    });

    test('Evaluates Cloze with alternative answers separated by slash', () {
      const ex = GrammarExercise(
        id: 'ex_12',
        type: GrammarExerciseType.cloze,
        difficulty: GrammarDifficulty.analysis,
        prompt: 'The rules ________ (conform to / with) standards.',
        options: [],
        correctAnswer: 'conform to / conform with',
        explanation: GrammarExplanation(
          translation: '',
          keySignal: '',
          rule: '',
          whyCorrect: '',
        ),
      );

      expect(GrammarAnswerEvaluator.isCorrect(ex, 'conform to'), isTrue);
      expect(GrammarAnswerEvaluator.isCorrect(ex, 'conform with'), isTrue);
      expect(GrammarAnswerEvaluator.isCorrect(ex, 'conform for'), isFalse);
    });
  });

  group('GrammarSessionNotifier & FSRS Scheduling Tests', () {
    late AppDatabase db;
    late GrammarRepository repo;
    late ProviderContainer container;
    late GrammarSessionNotifier notifier;
    late GrammarUnit sampleUnit;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = GrammarRepository(db);
      await repo.init();

      container = ProviderContainer(
        overrides: [grammarRepositoryProvider.overrideWithValue(repo)],
      );
      notifier = container.read(grammarSessionNotifierProvider.notifier);

      sampleUnit = const GrammarUnit(
        unitId: 'unit-test',
        title: 'Test Unit',
        category: GrammarCategory.tenses,
        level: GrammarLevel.foundation,
        coreConcept: 'Test concept',
        formulas: {'f1': 'formula 1'},
        commonTraps: [],
        exercises: [
          GrammarExercise(
            id: 'ex_01',
            type: GrammarExerciseType.choice,
            difficulty: GrammarDifficulty.recognition,
            prompt: 'Q1',
            options: ['A', 'B'],
            correctAnswer: 'A',
            explanation: GrammarExplanation(
              translation: 'T1',
              keySignal: 'K1',
              rule: 'R1',
              whyCorrect: 'W1',
            ),
          ),
          GrammarExercise(
            id: 'ex_02',
            type: GrammarExerciseType.errorId,
            difficulty: GrammarDifficulty.analysis,
            prompt: 'Q2',
            options: ['A', 'B', 'C', 'D'],
            correctAnswer: 'B',
            explanation: GrammarExplanation(
              translation: 'T2',
              keySignal: 'K2',
              rule: 'R2',
              whyCorrect: 'W2',
            ),
          ),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('Initializes session correctly', () {
      notifier.startUnitSession(sampleUnit);

      expect(notifier.state.unit, equals(sampleUnit));
      expect(notifier.state.totalQuestions, equals(2));
      expect(notifier.state.currentIndex, equals(0));
      expect(notifier.state.currentExercise?.id, equals('ex_01'));
      expect(notifier.state.isSubmitted, isFalse);
      expect(notifier.state.progressFraction, equals(0.0));
    });

    test(
      'Submits correct answer, advances FSRS and moves to next question',
      () async {
        notifier.startUnitSession(sampleUnit);

        notifier.selectAnswer('A');
        final isRight = await notifier.submitAnswer();

        expect(isRight, isTrue);
        expect(notifier.state.isSubmitted, isTrue);
        expect(notifier.state.isCurrentCorrect, isTrue);
        expect(notifier.state.ghostChallengeQueue, isEmpty);

        // Check SQLite FSRS record
        final progress = repo.getProgress('unit-test', 'ex_01');
        expect(progress, isNotNull);
        expect(progress!.isCompleted, isTrue);
        expect(progress.isGhost, isFalse);
        expect(progress.stability, greaterThan(0.0));

        // Advance
        notifier.nextQuestion();
        expect(notifier.state.currentIndex, equals(1));
        expect(notifier.state.currentExercise?.id, equals('ex_02'));
        expect(notifier.state.isSubmitted, isFalse);
        expect(notifier.state.selectedAnswer, isNull);
      },
    );

    test(
      'Submits incorrect answer, flags Ghost and activates Ghost Challenge',
      () async {
        notifier.startUnitSession(sampleUnit);

        // Q1: Answer wrongly ('B' instead of 'A')
        notifier.selectAnswer('B');
        final isRight1 = await notifier.submitAnswer();
        expect(isRight1, isFalse);
        expect(notifier.state.isCurrentCorrect, isFalse);
        expect(notifier.state.ghostChallengeQueue.length, equals(1));

        // Check SQLite Ghost flag
        final progress1 = repo.getProgress('unit-test', 'ex_01');
        expect(progress1, isNotNull);
        expect(progress1!.isGhost, isTrue);
        expect(progress1.lapses, equals(1));

        // Next to Q2
        notifier.nextQuestion();
        expect(notifier.state.isLastQuestion, isTrue);

        // Q2: Answer correctly
        notifier.selectAnswer('B');
        await notifier.submitAnswer();

        // Finish session
        notifier.nextQuestion();
        expect(notifier.state.isFinished, isTrue);
        expect(notifier.state.correctCount, equals(1));

        // Trigger Ghost Challenge for the failed question (Q1)
        notifier.startGhostChallenge();
        expect(notifier.state.isGhostChallenge, isTrue);
        expect(notifier.state.exercises.length, equals(1));
        expect(notifier.state.currentExercise?.id, equals('ex_01'));
        expect(notifier.state.currentIndex, equals(0));
      },
    );
  });
}
