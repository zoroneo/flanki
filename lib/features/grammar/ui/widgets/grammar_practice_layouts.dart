import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/grammar_models.dart';
import '../../providers/grammar_session_notifier.dart';
import 'explanation_sheet.dart';
import 'grammar_practice_question_content.dart';
import 'practice_shortcuts_guide.dart';

class GrammarPracticeMobileLayout extends StatelessWidget {
  final double progressFraction;
  final GrammarExercise? currentExercise;
  final bool isSubmitted;
  final bool? isCurrentCorrect;
  final bool isLastQuestion;
  final int currentIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final GrammarSessionNotifier notifier;
  final DraggableScrollableController sheetController;

  const GrammarPracticeMobileLayout({
    super.key,
    required this.progressFraction,
    required this.currentExercise,
    required this.isSubmitted,
    required this.isCurrentCorrect,
    required this.isLastQuestion,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.notifier,
    required this.sheetController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Column(
          children: [
            LinearProgressIndicator(
              value: progressFraction,
              minHeight: AppSpacing.xs,
            ),
            Expanded(
              child: currentExercise == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.smPlus,
                        AppSpacing.smPlus,
                        AppSpacing.smPlus,
                        isSubmitted
                            ? 240
                            : AppSpacing.md +
                                  MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: GrammarPracticeQuestionContent(
                            theme: theme,
                            l10n: l10n,
                            currentIndex: currentIndex,
                            totalQuestions: totalQuestions,
                            selectedAnswer: selectedAnswer,
                            isSubmitted: isSubmitted,
                            isCurrentCorrect: isCurrentCorrect,
                            notifier: notifier,
                            currentExercise: currentExercise!,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        if (isSubmitted && currentExercise != null)
          DraggableScrollableSheet(
            key: ValueKey('explanation_sheet_${currentExercise!.id}'),
            controller: sheetController,
            initialChildSize: 0.50,
            minChildSize: 0.50,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.50, 1.0],
            builder: (context, scrollController) {
              return ExplanationSheet(
                exercise: currentExercise!,
                isCorrect: isCurrentCorrect ?? false,
                isLastQuestion: isLastQuestion,
                onNext: () => notifier.nextQuestion(),
                scrollController: scrollController,
                sheetController: sheetController,
              );
            },
          ),
      ],
    );
  }
}

class GrammarPracticeDesktopLayout extends StatelessWidget {
  final double progressFraction;
  final GrammarExercise? currentExercise;
  final bool isSubmitted;
  final bool? isCurrentCorrect;
  final bool isLastQuestion;
  final int currentIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final GrammarSessionNotifier notifier;

  const GrammarPracticeDesktopLayout({
    super.key,
    required this.progressFraction,
    required this.currentExercise,
    required this.isSubmitted,
    required this.isCurrentCorrect,
    required this.isLastQuestion,
    required this.currentIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progressFraction,
          minHeight: AppSpacing.xs,
        ),
        Expanded(
          child: currentExercise == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 55,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: GrammarPracticeQuestionContent(
                              theme: theme,
                              l10n: l10n,
                              currentIndex: currentIndex,
                              totalQuestions: totalQuestions,
                              selectedAnswer: selectedAnswer,
                              isSubmitted: isSubmitted,
                              isCurrentCorrect: isCurrentCorrect,
                              notifier: notifier,
                              currentExercise: currentExercise!,
                            ),
                          ),
                        ),
                        AppGaps.h16,
                        Expanded(
                          flex: 45,
                          child: isSubmitted
                              ? ExplanationSheet(
                                  exercise: currentExercise!,
                                  isCorrect: isCurrentCorrect ?? false,
                                  isLastQuestion: isLastQuestion,
                                  onNext: () => notifier.nextQuestion(),
                                  isSidePanel: true,
                                )
                              : Align(
                                  alignment: Alignment.topCenter,
                                  child: PracticeShortcutsGuide(
                                    exercise: currentExercise,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
