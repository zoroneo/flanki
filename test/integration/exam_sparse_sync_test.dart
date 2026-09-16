import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/features/exam/models/exam_models.dart';

import '../helpers/virtual_sync_cluster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseCloudHub cloudHub;
  late VirtualSyncNode nodeA;
  late VirtualSyncNode nodeB;

  setUp(() async {
    cloudHub = MockSupabaseCloudHub();
    nodeA = VirtualSyncNode(nodeId: 'device_exam_node_A', cloudHub: cloudHub);
    nodeB = VirtualSyncNode(nodeId: 'device_exam_node_B', cloudHub: cloudHub);

    await nodeA.init();
    await nodeB.init();
  });

  tearDown(() async {
    await nodeA.close();
    await nodeB.close();
  });

  group('Exam Sparse Sync & Multi-Device Replicator Integration Tests', () {
    test('Sparse Sync: Only metadata fetched on catalog pull, full questions downloaded on-demand', () async {
      const examId = 'jlpt_n2_mock_sparse';
      final now = DateTime.utc(2026, 9, 16);

      // 1. Populate remote cloud hub catalog
      cloudHub.mockPapers.add({
        'id': examId,
        'title': 'JLPT N2 Mock Exam Online',
        'description': 'Đề thi N2 tải từ đám mây.',
        'category': 'jlpt',
        'level': 'N2',
        'duration_minutes': 45,
        'total_questions': 2,
        'passing_score': 60,
        'icon_name': 'book',
        'version': 1,
        'is_published': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      cloudHub.mockSections[examId] = [
        {
          'id': 'sec_n2_01',
          'exam_id': examId,
          'title': 'Từ vựng N2',
          'section_type': 'vocabulary',
          'order_index': 1,
          'instruction': 'Chọn đáp án đúng.',
        },
      ];

      cloudHub.mockQuestions[examId] = [
        {
          'id': 'q_n2_01',
          'exam_id': examId,
          'section_id': 'sec_n2_01',
          'question_number': 1,
          'question_text': 'この計画を実行するのは【困難】だ。',
          'options_json': [
            {'id': 'A', 'text': 'こんなん'},
            {'id': 'B', 'text': 'かんのん'},
          ],
          'correct_answer': 'A',
          'explanation': '困難 (こんなん) nghĩa là gian nan, khó khăn.',
          'points': 10,
        },
        {
          'id': 'q_n2_02',
          'exam_id': examId,
          'section_id': 'sec_n2_01',
          'question_number': 2,
          'question_text': '彼は約束を【守る】人だ。',
          'options_json': [
            {'id': 'A', 'text': 'まもる'},
            {'id': 'B', 'text': 'とまる'},
          ],
          'correct_answer': 'A',
          'explanation': '守る (まもる) nghĩa là tuân thủ, giữ gìn.',
          'points': 10,
        },
      ];

      // 2. Node A fetches catalog online -> verify only lightweight metadata cached
      final catalog = await nodeA.engine.fetchExamCatalogOnline();
      expect(catalog.any((p) => p.id == examId), isTrue);

      final localPaper = await nodeA.dbService.getExamPaperById(examId);
      expect(localPaper, isNotNull);
      expect(localPaper!.isDownloaded, isFalse);

      // Verify questions are NOT loaded yet into local SQLite (Sparse Sync invariant)
      final preQuestions = await nodeA.dbService.getExamQuestions(examId);
      expect(preQuestions, isEmpty);

      // 3. Node A downloads exam offline on-demand
      final downloaded = await nodeA.engine.downloadExamPaperOffline(examId);
      expect(downloaded.isDownloaded, isTrue);

      // Verify sections and questions are now stored in Node A SQLite
      final sections = await nodeA.dbService.getExamSections(examId);
      expect(sections.length, equals(1));
      expect(sections.first.id, equals('sec_n2_01'));

      final questions = await nodeA.dbService.getExamQuestions(examId);
      expect(questions.length, equals(2));
      expect(questions.first.questionText, contains('困難'));
    });

    test(
      'Offline exam submission replicates across devices via Outbox Replicator',
      () async {
        const examId = 'jlpt_n2_mock_sparse';
        final now = DateTime.utc(2026, 9, 16);

        // Setup paper on Node A
        final paper = ExamPaperModel(
          id: examId,
          title: 'JLPT N2 Mock Exam',
          description: 'Test paper',
          category: ExamCategory.jlpt,
          level: 'N2',
          durationMinutes: 45,
          totalQuestions: 2,
          passingScore: 60,
          isPublished: true,
          isDownloaded: true,
          createdAt: now,
          updatedAt: now,
        );
        await nodeA.dbService.saveExamPaperWithQuestions(paper, [], []);

        // 1. Node A submits exam result offline
        final submission = ExamSubmissionModel(
          id: 'sub_node_a_001',
          examId: examId,
          score: 10,
          totalCorrect: 1,
          totalQuestions: 2,
          durationSeconds: 1200,
          answers: {'q_n2_01': 'A', 'q_n2_02': 'B'},
          submittedAt: now,
        );

        final wrongQuestion = WrongQuestionModel(
          id: 'wq_node_a_001',
          examId: examId,
          questionId: 'q_n2_02',
          userAnswer: 'B',
          explanation: 'Sai đáp án câu 2',
          status: WrongQuestionStatus.newQuestion,
          createdAt: now,
          updatedAt: now,
        );

        await nodeA.dbService.submitExamResult(submission, [wrongQuestion]);

        // Verify pending outbox mutations on Node A
        final outboxBeforeSync = await nodeA.dbService.getPendingOutboxBatch();
        expect(outboxBeforeSync.length, equals(2));

        // 2. Node A synchronizes with CloudHub (Push)
        final pushResult = await nodeA.engine.sync();
        expect(pushResult.isSuccess, isTrue);
        expect(pushResult.pushedCount, equals(2));

        // Verify cloudHub received mutations
        expect(cloudHub.examSubmissions.containsKey('sub_node_a_001'), isTrue);
        expect(cloudHub.wrongQuestions.containsKey('wq_node_a_001'), isTrue);

        // 3. Node B synchronizes with CloudHub (Pull)
        final pullResult = await nodeB.engine.sync();
        expect(pullResult.isSuccess, isTrue);
        expect(pullResult.pulledCount, greaterThanOrEqualTo(2));

        // 4. Verify Node B now has the submission and wrong question
        final nodeBSubmissions = await nodeB.dbService.getExamSubmissions(
          examId,
        );
        expect(nodeBSubmissions.length, equals(1));
        expect(nodeBSubmissions.first.id, equals('sub_node_a_001'));
        expect(nodeBSubmissions.first.score, equals(10));

        final nodeBWrongs = await nodeB.dbService.getWrongQuestions(
          examId: examId,
        );
        expect(nodeBWrongs.length, equals(1));
        expect(nodeBWrongs.first.id, equals('wq_node_a_001'));
        expect(nodeBWrongs.first.userAnswer, equals('B'));
      },
    );
  });
}
