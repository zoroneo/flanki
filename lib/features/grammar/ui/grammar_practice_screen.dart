import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../data/grammar_repository.dart';
import '../data/grammar_service.dart';
import '../models/grammar_models.dart';
import '../providers/grammar_session_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/explanation_sheet.dart';
import 'widgets/grammar_exit_dialog.dart';
import 'widgets/grammar_practice_question_content.dart';
import 'widgets/practice_shortcuts_guide.dart';
import 'widgets/session_summary_dialog.dart';

class GrammarPracticeScreen extends ConsumerStatefulWidget {
  final String unitId;
  final GrammarPracticeMode mode;

  const GrammarPracticeScreen({
    super.key,
    required this.unitId,
    this.mode = GrammarPracticeMode.unit,
  });

  @override
  ConsumerState<GrammarPracticeScreen> createState() =>
      _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends ConsumerState<GrammarPracticeScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _setupSession();
    }
  }

  Future<void> _setupSession() async {
    final notifier = ref.read(grammarSessionNotifierProvider.notifier);
    final repo = ref.read(grammarRepositoryProvider);
    final grammarService = ref.read(grammarServiceProvider);

    if (widget.mode == GrammarPracticeMode.ghost) {
      final ghosts = repo.getAllGhosts();
      final allUnits = await grammarService.loadAllUnits();
      final ghostExercises = <GrammarExercise>[];
      for (final g in ghosts) {
        for (final u in allUnits) {
          if (u.unitId == g.unitId) {
            final ex = u.exercises.cast<GrammarExercise?>().firstWhere(
              (e) => e?.id == g.exerciseId,
              orElse: () => null,
            );
            if (ex != null) ghostExercises.add(ex);
          }
        }
      }
      if (ghostExercises.isNotEmpty) {
        notifier.startGhostSession(ghostExercises);
      }
    } else {
      final unit = await grammarService.getUnit(widget.unitId);
      if (unit != null) {
        notifier.startUnitSession(unit);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(grammarSessionNotifierProvider.notifier);
    final isFinished = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.isFinished),
    );

    // If session finished, show summary dialog
    if (isFinished) {
      final summary = ref.watch(
        grammarSessionNotifierProvider.select(
          (s) => (
            totalQuestions: s.totalQuestions,
            correctCount: s.correctCount,
            ghostCount: s.ghostChallengeQueue.length,
            isGhostChallenge: s.isGhostChallenge,
          ),
        ),
      );
      return Scaffold(
        headers: [
          AppBar(
            title: Text(
              l10n.grammarPracticeSummaryTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: [
              IconButton.ghost(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ],
        child: SessionSummaryDialog(
          totalQuestions: summary.totalQuestions,
          correctCount: summary.correctCount,
          ghostCount: summary.ghostCount,
          isGhostChallenge: summary.isGhostChallenge,
          onStartGhostChallenge: () => notifier.startGhostChallenge(),
          onReturnCatalog: () => context.pop(),
          onRestart: () => notifier.restartSession(),
        ),
      );
    }

    final currentExercise = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.currentExercise),
    );
    final isSubmitted = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.isSubmitted),
    );
    final isCurrentCorrect = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.isCurrentCorrect),
    );
    final isLastQuestion = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.isLastQuestion),
    );
    final isGhostChallenge = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.isGhostChallenge),
    );
    final unitTitle = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.unit?.title),
    );
    final progressFraction = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.progressFraction),
    );
    final selectedAnswer = ref.watch(
      grammarSessionNotifierProvider.select((s) => s.selectedAnswer),
    );
    final questionIndices = ref.watch(
      grammarSessionNotifierProvider.select(
        (s) => (s.currentIndex, s.totalQuestions),
      ),
    );

    final shortcuts = <ShortcutActivator, VoidCallback>{
      if (isSubmitted) ...{
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            notifier.nextQuestion(),
        const SingleActivator(LogicalKeyboardKey.space): () =>
            notifier.nextQuestion(),
      } else if (currentExercise?.type != GrammarExerciseType.cloze) ...{
        if (currentExercise != null && currentExercise.options.length >= 4) ...{
          const SingleActivator(LogicalKeyboardKey.digit1): () {
            notifier.selectAnswer(currentExercise.options[0]);
            notifier.submitAnswer();
          },
          const SingleActivator(LogicalKeyboardKey.digit2): () {
            notifier.selectAnswer(currentExercise.options[1]);
            notifier.submitAnswer();
          },
          const SingleActivator(LogicalKeyboardKey.digit3): () {
            notifier.selectAnswer(currentExercise.options[2]);
            notifier.submitAnswer();
          },
          const SingleActivator(LogicalKeyboardKey.digit4): () {
            notifier.selectAnswer(currentExercise.options[3]);
            notifier.submitAnswer();
          },
        },
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          headers: [
            AppBar(
              leading: [
                IconButton.ghost(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => GrammarExitDialog.show(context),
                ),
              ],
              title: Text(
                isGhostChallenge
                    ? l10n.grammarGhostReviewScreenTitle
                    : (unitTitle ?? l10n.grammarPracticeScreenTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: [
                if (currentExercise != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentExercise.type.getLocalizedLabel(l10n),
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          child: ScreenTypeLayout.builder(
            mobile: (context) => Column(
              children: [
                // Step Progress Bar
                LinearProgressIndicator(value: progressFraction, minHeight: 4),

                // Main Question Content
                Expanded(
                  child: currentExercise == null
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            16 + MediaQuery.paddingOf(context).bottom,
                          ),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: GrammarPracticeQuestionContent(
                                theme: theme,
                                l10n: l10n,
                                currentIndex: questionIndices.$1,
                                totalQuestions: questionIndices.$2,
                                selectedAnswer: selectedAnswer,
                                isSubmitted: isSubmitted,
                                isCurrentCorrect: isCurrentCorrect,
                                notifier: notifier,
                                currentExercise: currentExercise,
                              ),
                            ),
                          ),
                        ),
                ),

                // Bottom Explanation Sheet (when submitted)
                if (isSubmitted && currentExercise != null)
                  ExplanationSheet(
                    exercise: currentExercise,
                    isCorrect: isCurrentCorrect ?? false,
                    isLastQuestion: isLastQuestion,
                    onNext: () => notifier.nextQuestion(),
                  ),
              ],
            ),
            desktop: (context) => Column(
              children: [
                LinearProgressIndicator(value: progressFraction, minHeight: 4),
                Expanded(
                  child: currentExercise == null
                      ? const Center(child: CircularProgressIndicator())
                      : Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            height: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Column (55%): Question & Actions
                                Expanded(
                                  flex: 55,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: GrammarPracticeQuestionContent(
                                      theme: theme,
                                      l10n: l10n,
                                      currentIndex: questionIndices.$1,
                                      totalQuestions: questionIndices.$2,
                                      selectedAnswer: selectedAnswer,
                                      isSubmitted: isSubmitted,
                                      isCurrentCorrect: isCurrentCorrect,
                                      notifier: notifier,
                                      currentExercise: currentExercise,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Right Column (45%): Live Explanation or Shortcut Guide
                                Expanded(
                                  flex: 45,
                                  child: isSubmitted
                                      ? ExplanationSheet(
                                          exercise: currentExercise,
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
            ),
          ),
        ),
      ),
    );
  }
}
