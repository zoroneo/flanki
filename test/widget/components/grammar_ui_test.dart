import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/core/models/grammar/grammar_models.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:flanki/ui/screens/grammar/widgets/choice_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/cloze_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/error_id_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/explanation_sheet.dart';
import 'package:flanki/ui/screens/grammar/grammar_catalog_screen.dart';
import 'package:flanki/ui/screens/grammar/grammar_theory_screen.dart';
import 'package:flanki/ui/screens/study/widgets/rich_card_content.dart';
import 'package:drift/native.dart';
import 'package:flanki/core/storage/app_database.dart';
import 'package:flanki/core/storage/grammar_repository.dart';
import 'package:flanki/core/services/grammar_service.dart';
import 'package:flanki/core/notifiers/grammar_session_notifier.dart';
import 'package:flanki/ui/screens/grammar/grammar_practice_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late GrammarRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = GrammarRepository(db);
    await repo.init();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrapWithTheme(Widget child, [Locale locale = const Locale('vi')]) {
    return ShadcnApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShadcnLocalizationsViDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(child: child),
    );
  }

  Finder findRichText(String text) {
    return find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        return widget.text.toPlainText().contains(text);
      }
      return false;
    });
  }

  group('Grammar Question Widgets Tests', () {
    testWidgets(
      'ChoiceQuestionWidget renders prompt and handles option selection',
      (tester) async {
        const ex = GrammarExercise(
          id: 'ex_01',
          type: GrammarExerciseType.choice,
          difficulty: GrammarDifficulty.recognition,
          prompt: 'He _______ hard every day.',
          options: ['works', 'is working', 'work', 'worked'],
          correctAnswer: 'works',
          explanation: GrammarExplanation(
            translation: 'Anh ấy làm việc chăm chỉ mỗi ngày.',
            keySignal: 'every day',
            rule: 'Hiện tại đơn chỉ thói quen',
            whyCorrect: 'Chủ ngữ He số ít',
          ),
        );

        String? selected;

        await tester.pumpWidget(
          wrapWithTheme(
            StatefulBuilder(
              builder: (context, setState) {
                return ChoiceQuestionWidget(
                  exercise: ex,
                  selectedAnswer: selected,
                  isSubmitted: false,
                  onSelectAnswer: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(findRichText('He _______ hard every day.'), findsOneWidget);
        expect(find.text('works'), findsOneWidget);
        expect(find.text('is working'), findsOneWidget);

        // Tap 'works'
        await tester.tap(find.text('works'));
        await tester.pumpAndSettle();

        expect(selected, equals('works'));
      },
    );

    testWidgets(
      'ErrorIdQuestionWidget renders interactive tags and handles selection',
      (tester) async {
        const ex = GrammarExercise(
          id: 'ex_06',
          type: GrammarExerciseType.errorId,
          difficulty: GrammarDifficulty.analysis,
          prompt: 'She [A] are [B] reading [C] a [D] book.',
          options: ['A', 'B', 'C', 'D'],
          correctAnswer: 'A',
          explanation: GrammarExplanation(
            translation: 'Cô ấy đang đọc một cuốn sách.',
            keySignal: 'Chủ ngữ She',
            rule: 'Hòa hợp chủ vị',
            whyCorrect: 'She đi với is, không phải are',
          ),
        );

        String? selected;

        await tester.pumpWidget(
          wrapWithTheme(
            StatefulBuilder(
              builder: (context, setState) {
                return ErrorIdQuestionWidget(
                  exercise: ex,
                  selectedAnswer: selected,
                  isSubmitted: false,
                  onSelectAnswer: (val) {
                    setState(() => selected = val);
                  },
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('[A]'), findsWidgets);
        expect(find.text('[B]'), findsWidgets);

        // Tap [A]
        await tester.tap(find.text('[A]').last);
        await tester.pumpAndSettle();

        expect(selected, equals('A'));
      },
    );

    testWidgets('ClozeQuestionWidget renders input field and handles typing', (
      tester,
    ) async {
      const ex = GrammarExercise(
        id: 'ex_11',
        type: GrammarExerciseType.cloze,
        difficulty: GrammarDifficulty.recognition,
        prompt: 'Water ________ (boil) at 100 degrees.',
        options: [],
        correctAnswer: 'boils',
        explanation: GrammarExplanation(
          translation: 'Nước sôi ở 100 độ C.',
          keySignal: 'Chân lý khoa học',
          rule: 'Hiện tại đơn',
          whyCorrect: 'Sự thật hiển nhiên',
        ),
      );

      String? currentInput;

      await tester.pumpWidget(
        wrapWithTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return ClozeQuestionWidget(
                exercise: ex,
                selectedAnswer: currentInput,
                isSubmitted: false,
                isCorrect: null,
                onAnswerChanged: (val) {
                  setState(() => currentInput = val);
                },
                onSubmit: () {},
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        findRichText('Water ________ (boil) at 100 degrees.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'boils');
      await tester.pumpAndSettle();

      expect(currentInput, equals('boils'));
    });

    testWidgets(
      'ExplanationSheet displays translation, signals and distractor breakdowns',
      (tester) async {
        const ex = GrammarExercise(
          id: 'ex_01',
          type: GrammarExerciseType.choice,
          difficulty: GrammarDifficulty.recognition,
          prompt: 'Prompt',
          options: ['A', 'B'],
          correctAnswer: 'A',
          explanation: GrammarExplanation(
            translation: 'Dịch nghĩa mẫu',
            keySignal: 'Tín hiệu mẫu',
            rule: 'Quy tắc mẫu',
            whyCorrect: 'Lý do đúng',
            distractorBreakdown: {'Option B': 'Sai vì quá khứ'},
          ),
        );

        bool nextClicked = false;

        await tester.pumpWidget(
          wrapWithTheme(
            ExplanationSheet(
              exercise: ex,
              isCorrect: true,
              isLastQuestion: false,
              onNext: () => nextClicked = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Chính xác! Rất tốt!'), findsOneWidget);
        expect(findRichText('Dịch nghĩa mẫu'), findsOneWidget);
        expect(findRichText('Tín hiệu mẫu'), findsOneWidget);
        expect(findRichText('Quy tắc mẫu'), findsOneWidget);
        expect(findRichText('Lý do đúng'), findsOneWidget);
        expect(findRichText('Đáp án B'), findsOneWidget);

        await tester.tap(find.text('Câu Tiếp Theo'));
        expect(nextClicked, isTrue);
      },
    );

    testWidgets(
      'GrammarTheoryScreen renders rich formatted sections via RichCardContent',
      (tester) async {
        const unit = GrammarUnit(
          unitId: 'test_unit_01',
          title: 'Present Simple vs Continuous',
          category: GrammarCategory.tenses,
          level: GrammarLevel.foundation,
          coreConcept:
              '<b>Hiện tại đơn</b> diễn tả chân lý:\n- Sự thật hiển nhiên',
          formulas: {'presentSimple': 'Khẳng định: <code>S + V(s/es)</code>'},
          commonTraps: [
            GrammarTrap(
              trap: 'Bẫy 1: <span style="color: #f59e0b;">Stative verb</span>',
              exampleWrong: 'I am <b>knowing</b> you.',
              exampleRight: 'I <b>know</b> you.',
              note: 'Ghi chú: <span style="color:red">Không chia V-ing</span>',
            ),
          ],
          extraGuides: {
            'Stative Verbs': 'Các động từ chỉ trạng thái: <i>think, know</i>',
          },
          exercises: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              grammarUnitsProvider.overrideWith((ref) async => [unit]),
            ],
            child: wrapWithTheme(
              const GrammarTheoryScreen(unitId: 'test_unit_01'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Present Simple vs Continuous'), findsOneWidget);
        expect(findRichText('Stative verb'), findsOneWidget);
        expect(find.byType(RichCardContent), findsWidgets);
      },
    );

    testWidgets(
      'GrammarTheoryScreen renders Two-Pane layout and TOC on desktop',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const unit = GrammarUnit(
          unitId: 'test_unit_01',
          title: 'Present Simple vs Continuous',
          category: GrammarCategory.tenses,
          level: GrammarLevel.foundation,
          coreConcept: 'Core concept',
          formulas: {'f1': 'formula 1'},
          commonTraps: [],
          extraGuides: {},
          exercises: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              grammarUnitsProvider.overrideWith((ref) async => [unit]),
            ],
            child: wrapWithTheme(
              const GrammarTheoryScreen(unitId: 'test_unit_01'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Desktop shows Table of Contents sidebar
        expect(find.text('Mục Lục Chuyên Đề'), findsOneWidget);
        expect(find.text('Tư Duy Bản Xứ Cốt Lõi'), findsWidgets);
        expect(find.text('Công Thức Cú Pháp (Formulas)'), findsWidgets);
      },
    );

    testWidgets('GrammarTheoryScreen renders Sticky Bottom CTA on mobile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const unit = GrammarUnit(
        unitId: 'test_unit_01',
        title: 'Present Simple vs Continuous',
        category: GrammarCategory.tenses,
        level: GrammarLevel.foundation,
        coreConcept: 'Core concept',
        formulas: {},
        commonTraps: [],
        extraGuides: {},
        exercises: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarUnitsProvider.overrideWith((ref) async => [unit]),
          ],
          child: wrapWithTheme(
            const GrammarTheoryScreen(unitId: 'test_unit_01'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mobile does NOT show desktop TOC card
      expect(find.text('Mục Lục Chuyên Đề'), findsNothing);
      // Mobile renders Sticky Bottom CTA button
      expect(find.text('Bắt Đầu Luyện Tập 15 Câu Ngay'), findsOneWidget);
    });

    testWidgets(
      'GrammarCatalogScreen renders 3-column grid and wrap filter on desktop',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const unit = GrammarUnit(
          unitId: 'u1',
          title: 'Present Simple',
          category: GrammarCategory.tenses,
          level: GrammarLevel.foundation,
          coreConcept: 'Core',
          formulas: {},
          commonTraps: [],
          exercises: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              grammarUnitsProvider.overrideWith((ref) async => [unit]),
              grammarRepositoryProvider.overrideWithValue(repo),
            ],
            child: wrapWithTheme(const GrammarCatalogScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Present Simple'), findsOneWidget);
        // On desktop, Wrap is used for level filters
        expect(find.byType(Wrap), findsOneWidget);
        // SliverGrid with 3 columns
        final gridFinder = find.byType(SliverGrid);
        expect(gridFinder, findsOneWidget);
        final sliverGrid = tester.widget<SliverGrid>(gridFinder);
        final delegate =
            sliverGrid.gridDelegate
                as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, equals(3));
      },
    );

    testWidgets('GrammarCatalogScreen renders 2-column grid on tablet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const unit = GrammarUnit(
        unitId: 'u1',
        title: 'Present Simple',
        category: GrammarCategory.tenses,
        level: GrammarLevel.foundation,
        coreConcept: 'Core',
        formulas: {},
        commonTraps: [],
        exercises: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarUnitsProvider.overrideWith((ref) async => [unit]),
            grammarRepositoryProvider.overrideWithValue(repo),
          ],
          child: wrapWithTheme(const GrammarCatalogScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsOneWidget);
      final sliverGrid = tester.widget<SliverGrid>(gridFinder);
      final delegate =
          sliverGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(2));
    });

    testWidgets('GrammarCatalogScreen renders 1-column grid on mobile', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const unit = GrammarUnit(
        unitId: 'u1',
        title: 'Present Simple',
        category: GrammarCategory.tenses,
        level: GrammarLevel.foundation,
        coreConcept: 'Core',
        formulas: {},
        commonTraps: [],
        exercises: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarUnitsProvider.overrideWith((ref) async => [unit]),
            grammarRepositoryProvider.overrideWithValue(repo),
          ],
          child: wrapWithTheme(const GrammarCatalogScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final gridFinder = find.byType(SliverGrid);
      expect(gridFinder, findsOneWidget);
      final sliverGrid = tester.widget<SliverGrid>(gridFinder);
      final delegate =
          sliverGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(1));
      // On mobile, Wrap is not used for filter
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets(
      'ExplanationSheet renders side panel layout when isSidePanel is true',
      (tester) async {
        const ex = GrammarExercise(
          id: 'ex_side_01',
          type: GrammarExerciseType.choice,
          difficulty: GrammarDifficulty.recognition,
          prompt: 'Prompt side panel',
          options: ['A', 'B'],
          correctAnswer: 'A',
          explanation: GrammarExplanation(
            translation: 'Bản dịch side panel',
            keySignal: 'Tín hiệu side panel',
            rule: 'Quy tắc side panel',
            whyCorrect: 'Lý do side panel',
          ),
        );

        await tester.pumpWidget(
          wrapWithTheme(
            const SizedBox(
              height: 600,
              width: 400,
              child: ExplanationSheet(
                exercise: ex,
                isCorrect: true,
                isLastQuestion: false,
                onNext: _noop,
                isSidePanel: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Chính xác! Rất tốt!'), findsOneWidget);
        expect(findRichText('Bản dịch side panel'), findsOneWidget);
        expect(findRichText('Tín hiệu side panel'), findsOneWidget);
        expect(find.text('Câu Tiếp Theo'), findsOneWidget);
      },
    );

    testWidgets(
      'GrammarPracticeScreen renders dual-column layout with shortcut guide on desktop',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const unit = GrammarUnit(
          unitId: 'u_practice_desktop',
          title: 'Present Perfect',
          category: GrammarCategory.tenses,
          level: GrammarLevel.intermediate,
          coreConcept: 'Experience',
          formulas: {},
          commonTraps: [],
          exercises: [
            GrammarExercise(
              id: 'ex_d1',
              type: GrammarExerciseType.choice,
              difficulty: GrammarDifficulty.recognition,
              prompt: 'Have you ever _______ to Japan?',
              options: ['been', 'went', 'go', 'gone'],
              correctAnswer: 'been',
              explanation: GrammarExplanation(
                translation: 'Bạn đã từng đến Nhật Bản chưa?',
                keySignal: 'ever',
                rule: 'Present Perfect',
                whyCorrect: 'been dùng cho trải nghiệm',
              ),
            ),
          ],
        );

        final container = ProviderContainer(
          overrides: [grammarRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);
        container
            .read(grammarSessionNotifierProvider.notifier)
            .startUnitSession(unit);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: wrapWithTheme(
              const GrammarPracticeScreen(unitId: 'u_practice_desktop'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // On desktop, the shortcuts guide is visible on the right column
        expect(find.byIcon(LucideIcons.keyboard), findsOneWidget);
        expect(find.text('Phím tắt & Hướng dẫn'), findsOneWidget);
        expect(find.text('1, 2, 3, 4'), findsOneWidget);
        expect(find.text('Enter / Space'), findsOneWidget);
      },
    );

    testWidgets(
      'GrammarPracticeScreen renders single-column layout without shortcut guide on mobile',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const unit = GrammarUnit(
          unitId: 'u_practice_mobile',
          title: 'Past Simple',
          category: GrammarCategory.tenses,
          level: GrammarLevel.foundation,
          coreConcept: 'Finished past',
          formulas: {},
          commonTraps: [],
          exercises: [
            GrammarExercise(
              id: 'ex_m1',
              type: GrammarExerciseType.choice,
              difficulty: GrammarDifficulty.recognition,
              prompt: 'I _______ to school yesterday.',
              options: ['went', 'go', 'gone', 'going'],
              correctAnswer: 'went',
              explanation: GrammarExplanation(
                translation: 'Tôi đã đến trường hôm qua.',
                keySignal: 'yesterday',
                rule: 'Past Simple',
                whyCorrect: 'went là V2 của go',
              ),
            ),
          ],
        );

        final container = ProviderContainer(
          overrides: [grammarRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);
        container
            .read(grammarSessionNotifierProvider.notifier)
            .startUnitSession(unit);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: wrapWithTheme(
              const GrammarPracticeScreen(unitId: 'u_practice_mobile'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // On mobile, shortcut guide is NOT rendered
        expect(find.byIcon(LucideIcons.keyboard), findsNothing);
        expect(find.text('Phím tắt & Hướng dẫn'), findsNothing);
      },
    );
  });
}

void _noop() {}
