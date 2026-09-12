import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';
import 'package:flanki/features/grammar/providers/grammar_session_notifier.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/features/grammar/data/grammar_repository.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:flanki/features/grammar/ui/grammar_practice_screen.dart';

Finder findRichText(String text) {
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      return widget.text.toPlainText().contains(text);
    }
    return false;
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'flanki_grammar_practice_flow_test_',
    );
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_practice_flow.db',
    );
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  const mockUnit = GrammarUnit(
    unitId: 'unit_test_01',
    title: 'Unit Test Tenses & Traps',
    category: GrammarCategory.tenses,
    level: GrammarLevel.foundation,
    coreConcept: 'Test concept',
    formulas: {'simple': 'S + V'},
    commonTraps: [
      GrammarTrap(
        trap: 'Trap 1',
        exampleWrong: 'Wrong sentence',
        exampleRight: 'Right sentence',
        note: 'Trap note',
      ),
    ],
    exercises: [
      GrammarExercise(
        id: 'ex_c1',
        type: GrammarExerciseType.choice,
        difficulty: GrammarDifficulty.recognition,
        prompt: 'Choice question 1: She _______ every morning.',
        options: ['runs', 'running', 'is run', 'ran'],
        correctAnswer: 'runs',
        explanation: GrammarExplanation(
          translation: 'Cô ấy chạy bộ mỗi sáng.',
          keySignal: 'every morning',
          rule: 'Hiện tại đơn',
          whyCorrect: 'runs phù hợp chủ ngữ số ít She',
        ),
      ),
      GrammarExercise(
        id: 'ex_e1',
        type: GrammarExerciseType.errorId,
        difficulty: GrammarDifficulty.analysis,
        prompt: 'They [A] has [B] been [C] working [D] hard.',
        options: ['A', 'B', 'C', 'D'],
        correctAnswer: 'A',
        explanation: GrammarExplanation(
          translation: 'Họ đã làm việc chăm chỉ.',
          keySignal: 'Chủ ngữ số nhiều They',
          rule: 'Hòa hợp chủ vị',
          whyCorrect: 'has phải sửa thành have',
        ),
      ),
      GrammarExercise(
        id: 'ex_z1',
        type: GrammarExerciseType.cloze,
        difficulty: GrammarDifficulty.recognition,
        prompt: 'The sun ________ (rise) in the east.',
        options: [],
        correctAnswer: 'rises',
        explanation: GrammarExplanation(
          translation: 'Mặt trời mọc ở hướng đông.',
          keySignal: 'Sự thật hiển nhiên',
          rule: 'Hiện tại đơn chân lý',
          whyCorrect: 'rises số ít',
        ),
      ),
    ],
  );

  testWidgets(
    'Grammar Practice Flow: choice, errorId, cloze, FSRS DB persistence & summary',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initial session start
      container
          .read(grammarSessionNotifierProvider.notifier)
          .startUnitSession(mockUnit);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const ShadcnApp(
            locale: Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ShadcnLocalizationsViDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: GrammarPracticeScreen(unitId: 'unit_test_01'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. QUESTION 1: Choice
      expect(find.text('Câu 1 / 3'), findsOneWidget);
      expect(find.text('TRẮC NGHIỆM'), findsOneWidget);
      expect(
        findRichText('Choice question 1: She _______ every morning.'),
        findsOneWidget,
      );

      // Select wrong answer 'running' (auto-submits)
      await tester.tap(find.text('running'));
      await tester.pumpAndSettle();

      // Explanation sheet should show incorrect feedback
      expect(find.text('Chưa chính xác — Ghi nhớ bẫy này!'), findsOneWidget);
      expect(findRichText('Cô ấy chạy bộ mỗi sáng.'), findsOneWidget);

      // Advance to Question 2
      await tester.tap(find.text('Câu Tiếp Theo'));
      await tester.pumpAndSettle();

      // 2. QUESTION 2: Error ID
      expect(find.text('Câu 2 / 3'), findsOneWidget);
      expect(find.text('TÌM LỖI SAI'), findsOneWidget);

      // Select correct answer [A] (auto-submits)
      await tester.tap(find.text('[A]').last);
      await tester.pumpAndSettle();

      expect(find.text('Chính xác! Rất tốt!'), findsOneWidget);
      expect(findRichText('Họ đã làm việc chăm chỉ.'), findsOneWidget);

      // Advance to Question 3
      await tester.tap(find.text('Câu Tiếp Theo'));
      await tester.pumpAndSettle();

      // 3. QUESTION 3: Cloze
      expect(find.text('Câu 3 / 3'), findsOneWidget);
      expect(find.text('ĐIỀN TỪ'), findsOneWidget);

      // Enter correct answer 'rises' and submit via onSubmitted
      await tester.enterText(find.byType(TextField), 'rises');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Chính xác! Rất tốt!'), findsOneWidget);

      // Finish session
      await tester.tap(find.text('Xem Tổng Kết Bài Học'));
      await tester.pumpAndSettle();

      // 4. SUMMARY DIALOG
      expect(find.text('Tổng Kết Phiên Luyện Tập'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget); // 2 correct out of 3
      expect(find.text('Xóa Điểm Yếu Ngay (1 câu sai)'), findsOneWidget);

      // 5. REPOSITORY & DRIFT DB VERIFICATION
      final repo = container.read(grammarRepositoryProvider);
      final summary = repo.getUnitSummary('unit_test_01', totalExercises: 3);

      expect(summary.completedCount, equals(3));
      expect(summary.ghostCount, equals(1)); // ex_c1 was answered wrongly
      expect(repo.getAllGhosts().length, equals(1));
      expect(repo.getAllGhosts().first.exerciseId, equals('ex_c1'));

      final exC1Progress = repo.getProgress('unit_test_01', 'ex_c1');
      expect(exC1Progress, isNotNull);
      expect(exC1Progress!.isGhost, isTrue);
      expect(exC1Progress.isCompleted, isTrue);
      expect(exC1Progress.lapses, equals(1));

      final exZ1Progress = repo.getProgress('unit_test_01', 'ex_z1');
      expect(exZ1Progress, isNotNull);
      expect(exZ1Progress!.isGhost, isFalse);
      expect(exZ1Progress.isCompleted, isTrue);

      // 6. GHOST CHALLENGE CLEARING
      // Start ghost challenge from summary
      await tester.tap(find.text('Xóa Điểm Yếu Ngay (1 câu sai)'));
      await tester.pumpAndSettle();

      expect(find.text('Thử Thách Ghost Review'), findsOneWidget);
      expect(find.text('Câu 1 / 1'), findsOneWidget);
      expect(
        findRichText('Choice question 1: She _______ every morning.'),
        findsOneWidget,
      );

      // Now answer correctly: 'runs' (auto-submits)
      await tester.tap(find.text('runs'));
      await tester.pumpAndSettle();

      expect(find.text('Chính xác! Rất tốt!'), findsOneWidget);

      await tester.tap(find.text('Xem Tổng Kết Bài Học'));
      await tester.pumpAndSettle();

      // Verify Ghost is now cleared!
      final updatedGhostProgress = repo.getProgress('unit_test_01', 'ex_c1');
      expect(updatedGhostProgress!.isGhost, isFalse);
      expect(repo.getAllGhosts().length, equals(0));
    },
  );
}
