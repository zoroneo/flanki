import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/database/app_database.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/features/exam/data/exam_repository.dart';
import 'package:flanki/features/exam/models/exam_models.dart';

import '../../../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late DatabaseService dbService;
  late MockSupabaseCloudHub cloudHub;
  late SupabaseSyncEngine syncEngine;
  late ExamRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService.forTest(db);
    dbService.configureNodeId('test_node_01');
    await dbService.init();

    cloudHub = MockSupabaseCloudHub();
    syncEngine = SupabaseSyncEngine(rpcClient: cloudHub, dbService: dbService);

    repo = ExamRepository(dbService: dbService, syncEngine: syncEngine);
  });

  tearDown(() async {
    await dbService.close();
  });

  group('ExamRepository Unit Tests', () {
    test(
      'getExamCatalog auto-seeds sample exams when database is empty',
      () async {
        final catalog = await repo.getExamCatalog();
        expect(catalog, isNotEmpty);
        expect(catalog.first.id, equals('jlpt_n3_mock_01'));
        expect(catalog.first.category, equals(ExamCategory.jlpt));
        expect(catalog.first.level, equals('N3'));
        expect(catalog.first.totalQuestions, equals(3));
      },
    );

    test(
      'getExamPaper, sections and questions return valid exam structure',
      () async {
        // Seed via catalog call
        await repo.getExamCatalog();

        final paper = await repo.getExamPaper('jlpt_n3_mock_01');
        expect(paper, isNotNull);
        expect(paper!.title, equals('JLPT N3 Mock Exam 01'));

        final sections = await repo.getExamSections('jlpt_n3_mock_01');
        expect(sections.length, equals(2));

        final questions = await repo.getExamQuestions('jlpt_n3_mock_01');
        expect(questions.length, equals(3));
        expect(questions.first.questionText, contains('重要'));
      },
    );

    test('submitExam persists submission, saves wrong questions, and enqueues outbox mutations', () async {
      await repo.getExamCatalog();
      final now = DateTime.now().toUtc();

      final submission = ExamSubmissionModel(
        id: 'sub_001',
        examId: 'jlpt_n3_mock_01',
        score: 80,
        totalCorrect: 8,
        totalQuestions: 10,
        durationSeconds: 900,
        answers: {'q1': 'A', 'q2': 'B'},
        submittedAt: now,
      );

      final wrongQuestions = [
        WrongQuestionModel(
          id: 'wq_001',
          examId: 'jlpt_n3_mock_01',
          questionId: 'q2',
          userAnswer: 'B',
          explanation: '親切 (しんせつ) nghĩa là tốt bụng.',
          status: WrongQuestionStatus.newQuestion,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await repo.submitExam(
        submission: submission,
        wrongQuestions: wrongQuestions,
      );

      // Check submission persisted
      final submissions = await repo.getSubmissions('jlpt_n3_mock_01');
      expect(submissions.length, equals(1));
      expect(submissions.first.id, equals('sub_001'));
      expect(submissions.first.score, equals(80));
      expect(submissions.first.isPassed, isTrue);

      // Check wrong question saved
      final savedWrongs = await repo.getWrongQuestions(
        examId: 'jlpt_n3_mock_01',
      );
      expect(savedWrongs.length, equals(1));
      expect(savedWrongs.first.id, equals('wq_001'));
      expect(savedWrongs.first.status, equals(WrongQuestionStatus.newQuestion));

      // Verify outbox has mutations for both submission and wrong question
      final pendingMutations = await dbService.getPendingOutboxBatch();
      expect(pendingMutations.length, equals(2));
      final entityTypes = pendingMutations.map((m) => m.entityType).toSet();
      expect(entityTypes, containsAll(['exam_submission', 'wrong_question']));
    });

    test('updateWrongQuestionStatus transitions status correctly', () async {
      await repo.getExamCatalog();
      final now = DateTime.now().toUtc();

      final wrongQuestion = WrongQuestionModel(
        id: 'wq_002',
        examId: 'jlpt_n3_mock_01',
        questionId: 'q3',
        userAnswer: 'A',
        explanation: 'Sample explanation',
        status: WrongQuestionStatus.newQuestion,
        createdAt: now,
        updatedAt: now,
      );

      await repo.submitExam(
        submission: ExamSubmissionModel(
          id: 'sub_002',
          examId: 'jlpt_n3_mock_01',
          score: 90,
          totalCorrect: 9,
          totalQuestions: 10,
          durationSeconds: 500,
          answers: {},
          submittedAt: now,
        ),
        wrongQuestions: [wrongQuestion],
      );

      // Update to reviewing
      await repo.updateWrongQuestionStatus(
        'wq_002',
        WrongQuestionStatus.reviewing,
      );
      var wrongs = await repo.getWrongQuestions(
        status: WrongQuestionStatus.reviewing,
      );
      expect(wrongs.length, equals(1));
      expect(wrongs.first.id, equals('wq_002'));

      // Update to mastered
      await repo.updateWrongQuestionStatus(
        'wq_002',
        WrongQuestionStatus.mastered,
      );
      wrongs = await repo.getWrongQuestions(
        status: WrongQuestionStatus.mastered,
      );
      expect(wrongs.length, equals(1));
      expect(wrongs.first.id, equals('wq_002'));

      // Filter by newQuestion should now be empty
      final newWrongs = await repo.getWrongQuestions(
        status: WrongQuestionStatus.newQuestion,
      );
      expect(newWrongs, isEmpty);
    });

    test('Exam models json_serializable serialization roundtrip', () {
      final now = DateTime.now();

      // 1. ExamPaperModel
      final paper = ExamPaperModel(
        id: 'paper_1',
        title: 'Title 1',
        category: ExamCategory.toeic,
        level: '800',
        durationMinutes: 45,
        totalQuestions: 50,
        passingScore: 70,
        iconName: 'book',
        version: 2,
        isPublished: true,
        isDownloaded: true,
        createdAt: now,
        updatedAt: now,
      );
      final paperJson = paper.toJson();
      final paperDeserialized = ExamPaperModel.fromJson(paperJson);
      expect(paperDeserialized.id, equals(paper.id));
      expect(paperDeserialized.category, equals(ExamCategory.toeic));
      expect(paperDeserialized.durationMinutes, equals(45));
      expect(paperDeserialized.isDownloaded, isTrue);

      // 2. ExamSectionModel
      const section = ExamSectionModel(
        id: 'sec_1',
        examId: 'paper_1',
        title: 'Section 1',
        sectionType: 'listening',
        orderIndex: 1,
        instruction: 'Listen carefully',
      );
      final sectionJson = section.toJson();
      final sectionDeserialized = ExamSectionModel.fromJson(sectionJson);
      expect(sectionDeserialized.id, equals(section.id));
      expect(sectionDeserialized.sectionType, equals('listening'));

      // 3. ExamQuestionOption & ExamQuestionModel
      const optA = ExamQuestionOption(id: 'A', text: 'Option A');
      const optB = ExamQuestionOption(id: 'B', text: 'Option B');
      const question = ExamQuestionModel(
        id: 'q_1',
        examId: 'paper_1',
        sectionId: 'sec_1',
        questionNumber: 1,
        questionText: 'What is this?',
        options: [optA, optB],
        correctAnswer: 'A',
        explanation: 'Because it is A',
        points: 2,
      );
      final qJson = question.toJson();
      final qDeserialized = ExamQuestionModel.fromJson(qJson);
      expect(qDeserialized.id, equals(question.id));
      expect(qDeserialized.options.length, equals(2));
      expect(qDeserialized.options[0].id, equals('A'));
      expect(qDeserialized.options[1].text, equals('Option B'));

      // 4. ExamSubmissionModel
      final submission = ExamSubmissionModel(
        id: 'sub_1',
        examId: 'paper_1',
        score: 100,
        totalCorrect: 1,
        totalQuestions: 1,
        durationSeconds: 120,
        answers: {'q_1': 'A'},
        submittedAt: now,
        updatedAtHlc: '123_0001_node',
      );
      final subJson = submission.toJson();
      final subDeserialized = ExamSubmissionModel.fromJson(subJson);
      expect(subDeserialized.id, equals(submission.id));
      expect(subDeserialized.answers['q_1'], equals('A'));
      expect(subDeserialized.isPassed, isTrue);

      // 5. WrongQuestionModel
      final wrong = WrongQuestionModel(
        id: 'wq_1',
        examId: 'paper_1',
        questionId: 'q_1',
        userAnswer: 'B',
        explanation: 'Wrong guess',
        notes: 'Review vocabulary',
        status: WrongQuestionStatus.reviewing,
        createdAt: now,
        updatedAt: now,
        updatedAtHlc: '123_0002_node',
      );
      final wrongJson = wrong.toJson();
      final wrongDeserialized = WrongQuestionModel.fromJson(wrongJson);
      expect(wrongDeserialized.id, equals(wrong.id));
      expect(wrongDeserialized.status, equals(WrongQuestionStatus.reviewing));
      expect(wrongDeserialized.userAnswer, equals('B'));
    });
  });
}
