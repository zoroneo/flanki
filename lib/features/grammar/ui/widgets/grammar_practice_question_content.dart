import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/grammar_models.dart';
import '../../providers/grammar_session_notifier.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'choice_question_widget.dart';
import 'cloze_question_widget.dart';
import 'error_id_question_widget.dart';

class GrammarPracticeQuestionContent extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final int currentIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final bool isSubmitted;
  final bool? isCurrentCorrect;
  final GrammarSessionNotifier notifier;
  final GrammarExercise currentExercise;

  const GrammarPracticeQuestionContent({
    super.key,
    required this.theme,
    required this.l10n,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.isSubmitted,
    required this.isCurrentCorrect,
    required this.notifier,
    required this.currentExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question counter
        Text(
          l10n.grammarQuestionCounter(currentIndex + 1, totalQuestions),
          style: theme.typography.small.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),

        // Dynamic Question Formats
        if (currentExercise.type == GrammarExerciseType.choice)
          ChoiceQuestionWidget(
            exercise: currentExercise,
            selectedAnswer: selectedAnswer,
            isSubmitted: isSubmitted,
            onSelectAnswer: (ans) {
              notifier.selectAnswer(ans);
              notifier.submitAnswer();
            },
          )
        else if (currentExercise.type == GrammarExerciseType.errorId)
          ErrorIdQuestionWidget(
            exercise: currentExercise,
            selectedAnswer: selectedAnswer,
            isSubmitted: isSubmitted,
            onSelectAnswer: (ans) {
              notifier.selectAnswer(ans);
              notifier.submitAnswer();
            },
          )
        else if (currentExercise.type == GrammarExerciseType.cloze)
          ClozeQuestionWidget(
            exercise: currentExercise,
            selectedAnswer: selectedAnswer,
            isSubmitted: isSubmitted,
            isCorrect: isCurrentCorrect,
            onAnswerChanged: (ans) => notifier.selectAnswer(ans),
            onSubmit: () => notifier.submitAnswer(),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
