import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/grammar_repository.dart';
import '../data/grammar_service.dart';
import '../models/grammar_models.dart';
import '../providers/grammar_session_notifier.dart';
import 'widgets/grammar_exit_dialog.dart';
import 'widgets/grammar_practice_layouts.dart';
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
  DraggableScrollableController _sheetController =
      DraggableScrollableController();
  String? _lastExerciseId;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

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
                icon: const Icon(LucideIcons.x, size: AppIconSize.md),
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
    if (currentExercise?.id != _lastExerciseId) {
      _lastExerciseId = currentExercise?.id;
      _sheetController.dispose();
      _sheetController = DraggableScrollableController();
    }
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
        if (currentExercise != null &&
            currentExercise.options.length >=
                GrammarConstants.standardChoiceOptionCount) ...{
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
                  icon: const Icon(LucideIcons.x, size: AppIconSize.md),
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
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      borderRadius: AppRadius.borderSm,
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
            mobile: (context) => GrammarPracticeMobileLayout(
              progressFraction: progressFraction,
              currentExercise: currentExercise,
              isSubmitted: isSubmitted,
              isCurrentCorrect: isCurrentCorrect,
              isLastQuestion: isLastQuestion,
              currentIndex: questionIndices.$1,
              totalQuestions: questionIndices.$2,
              selectedAnswer: selectedAnswer,
              notifier: notifier,
              sheetController: _sheetController,
            ),
            desktop: (context) => GrammarPracticeDesktopLayout(
              progressFraction: progressFraction,
              currentExercise: currentExercise,
              isSubmitted: isSubmitted,
              isCurrentCorrect: isCurrentCorrect,
              isLastQuestion: isLastQuestion,
              currentIndex: questionIndices.$1,
              totalQuestions: questionIndices.$2,
              selectedAnswer: selectedAnswer,
              notifier: notifier,
            ),
          ),
        ),
      ),
    );
  }
}
