import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/database/app_database.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/features/exam/data/exam_repository.dart';
import 'package:flanki/features/exam/models/exam_models.dart';
import 'package:flanki/features/exam/providers/exam_session_notifier.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

import '../../../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DatabaseService dbService;
  late MockSupabaseCloudHub cloudHub;
  late SupabaseSyncEngine syncEngine;
  late ExamRepository repo;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService.forTest(db);
    dbService.configureNodeId('test_notifier_node');
    await dbService.init();

    cloudHub = MockSupabaseCloudHub();
    syncEngine = SupabaseSyncEngine(rpcClient: cloudHub, dbService: dbService);

    repo = ExamRepository(dbService: dbService, syncEngine: syncEngine);

    // Pre-populate sample catalog
    await repo.getExamCatalog();

    container = ProviderContainer(
      overrides: [examRepositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await dbService.close();
  });

  group('ExamSessionNotifier Unit Tests', () {
    test(
      'initSession loads paper, sections, questions and starts timer',
      () async {
        final notifier = container.read(examSessionProvider.notifier);
        await notifier.initSession('jlpt_n3_mock_01');

        final state = container.read(examSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.paper, isNotNull);
        expect(state.paper!.id, equals('jlpt_n3_mock_01'));
        expect(state.sections.length, equals(2));
        expect(state.questions.length, equals(3));
        expect(state.currentIndex, equals(0));
        expect(state.remainingSeconds, equals(30 * 60));
        expect(state.totalDurationSeconds, equals(30 * 60));
        expect(state.isFinished, isFalse);
      },
    );

    test(
      'selectAnswer, toggleFlag, navigation update state appropriately',
      () async {
        final notifier = container.read(examSessionProvider.notifier);
        await notifier.initSession('jlpt_n3_mock_01');

        // Select answer for question 1
        final q1Id = container.read(examSessionProvider).questions[0].id;
        notifier.selectAnswer(q1Id, 'A');
        expect(
          container.read(examSessionProvider).selectedAnswers[q1Id],
          equals('A'),
        );
        expect(container.read(examSessionProvider).answeredCount, equals(1));

        // Toggle flag
        notifier.toggleFlag(q1Id);
        expect(
          container.read(examSessionProvider).flaggedQuestionIds.contains(q1Id),
          isTrue,
        );
        notifier.toggleFlag(q1Id);
        expect(
          container.read(examSessionProvider).flaggedQuestionIds.contains(q1Id),
          isFalse,
        );

        // Navigation
        notifier.nextQuestion();
        expect(container.read(examSessionProvider).currentIndex, equals(1));
        notifier.prevQuestion();
        expect(container.read(examSessionProvider).currentIndex, equals(0));
        notifier.jumpTo(2);
        expect(container.read(examSessionProvider).currentIndex, equals(2));
      },
    );

    test(
      'submitExam grades accurately and produces wrong questions list',
      () async {
        final notifier = container.read(examSessionProvider.notifier);
        await notifier.initSession('jlpt_n3_mock_01');

        // Answer 1 question correctly, 2 incorrectly
        final questions = container.read(examSessionProvider).questions;
        final q1 = questions[0]; // q1 correct is 'A'
        final q2 = questions[1]; // q2 correct is 'B'
        final q3 = questions[2]; // q3 correct is 'A'

        notifier.selectAnswer(q1.id, 'A'); // Correct (+10)
        notifier.selectAnswer(q2.id, 'A'); // Incorrect (user: A, correct: B)
        notifier.selectAnswer(q3.id, 'C'); // Incorrect (user: C, correct: A)

        await notifier.submitExam();

        final state = container.read(examSessionProvider);
        expect(state.isFinished, isTrue);
        expect(state.isSubmitting, isFalse);
        expect(state.submission, isNotNull);

        final sub = state.submission!;
        expect(sub.totalCorrect, equals(1));
        expect(sub.score, equals(10));
        expect(sub.totalQuestions, equals(3));
        expect(sub.isPassed, isFalse);

        // 2 questions wrong
        expect(state.wrongQuestions.length, equals(2));
        final wrongQ2 = state.wrongQuestions.firstWhere(
          (w) => w.questionId == q2.id,
        );
        expect(wrongQ2.userAnswer, equals('A'));
        expect(wrongQ2.status, equals(WrongQuestionStatus.newQuestion));

        // Check persisted into repository
        final submissions = await repo.getSubmissions('jlpt_n3_mock_01');
        expect(submissions.length, equals(1));
        expect(submissions.first.id, equals(sub.id));

        final wrongInDb = await repo.getWrongQuestions(
          examId: 'jlpt_n3_mock_01',
        );
        expect(wrongInDb.length, equals(2));
      },
    );

    test(
      'initSession with non-existent exam sets structured error code',
      () async {
        final notifier = container.read(examSessionProvider.notifier);
        await notifier.initSession('non_existent_id');

        final state = container.read(examSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.error, equals(ExamSessionNotifier.errExamNotFound));

        final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
        final l10nVi = await AppLocalizations.delegate.load(const Locale('vi'));
        expect(
          state.getLocalizedError(l10nEn),
          'Exam paper not found or deleted.',
        );
        expect(
          state.getLocalizedError(l10nVi),
          'Đề thi không tồn tại hoặc đã bị xóa.',
        );
      },
    );

    test(
      'submitExam with unanswered questions stores empty string in userAnswer',
      () async {
        final notifier = container.read(examSessionProvider.notifier);
        await notifier.initSession('jlpt_n3_mock_01');

        // Leave all unanswered
        await notifier.submitExam();

        final state = container.read(examSessionProvider);
        expect(state.isFinished, isTrue);
        expect(state.wrongQuestions.length, equals(3));
        for (final w in state.wrongQuestions) {
          expect(
            w.userAnswer,
            equals(''),
          ); // Empty string, no hardcoded Vietnamese!
        }
      },
    );
  });
}
