import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/models/grammar/grammar_models.dart';
import 'package:flanki/ui/screens/grammar/widgets/choice_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/cloze_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/error_id_question_widget.dart';
import 'package:flanki/ui/screens/grammar/widgets/explanation_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(Widget child) {
    return ShadcnApp(
      home: Scaffold(
        child: child,
      ),
    );
  }

  group('Grammar Question Widgets Tests', () {
    testWidgets('ChoiceQuestionWidget renders prompt and handles option selection', (tester) async {
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

      expect(find.text('He _______ hard every day.'), findsOneWidget);
      expect(find.text('works'), findsOneWidget);
      expect(find.text('is working'), findsOneWidget);

      // Tap 'works'
      await tester.tap(find.text('works'));
      await tester.pumpAndSettle();

      expect(selected, equals('works'));
    });

    testWidgets('ErrorIdQuestionWidget renders interactive tags and handles selection', (tester) async {
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
    });

    testWidgets('ClozeQuestionWidget renders input field and handles typing', (tester) async {
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

      expect(find.text('Water ________ (boil) at 100 degrees.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'boils');
      await tester.pumpAndSettle();

      expect(currentInput, equals('boils'));
    });

    testWidgets('ExplanationSheet displays translation, signals and distractor breakdowns', (tester) async {
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
          distractorBreakdown: {
            'Option B': 'Sai vì quá khứ',
          },
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
      expect(find.text('Dịch nghĩa mẫu'), findsOneWidget);
      expect(find.text('Tín hiệu mẫu'), findsOneWidget);
      expect(find.text('Quy tắc mẫu'), findsOneWidget);
      expect(find.text('Lý do đúng'), findsOneWidget);
      expect(find.textContaining('Option B'), findsOneWidget);

      await tester.tap(find.text('Câu Tiếp Theo'));
      expect(nextClicked, isTrue);
    });
  });
}
