import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/models/grammar/grammar_models.dart';
import '../../../core/notifiers/grammar_session_notifier.dart';
import '../../../core/services/grammar_service.dart';
import '../../../core/storage/grammar_repository.dart';
import 'widgets/choice_question_widget.dart';
import 'widgets/cloze_question_widget.dart';
import 'widgets/error_id_question_widget.dart';
import 'widgets/explanation_sheet.dart';
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
  ConsumerState<GrammarPracticeScreen> createState() => _GrammarPracticeScreenState();
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
    final session = ref.watch(grammarSessionNotifierProvider);
    final notifier = ref.read(grammarSessionNotifierProvider.notifier);

    // If session finished, show summary dialog
    if (session.isFinished) {
      return Scaffold(
        headers: [
          AppBar(
            title: const Text('Tổng Kết Phiên Luyện Tập'),
            trailing: [
              IconButton.ghost(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ],
        child: SessionSummaryDialog(
          totalQuestions: session.totalQuestions,
          correctCount: session.correctCount,
          ghostCount: session.ghostChallengeQueue.length,
          isGhostChallenge: session.isGhostChallenge,
          onStartGhostChallenge: () => notifier.startGhostChallenge(),
          onReturnCatalog: () => context.pop(),
          onRestart: () => notifier.restartSession(),
        ),
      );
    }

    final currentExercise = session.currentExercise;

    final shortcuts = <ShortcutActivator, VoidCallback>{
      if (session.isSubmitted) ...{
        const SingleActivator(LogicalKeyboardKey.enter): () => notifier.nextQuestion(),
        const SingleActivator(LogicalKeyboardKey.space): () => notifier.nextQuestion(),
      } else if (currentExercise?.type != GrammarExerciseType.cloze) ...{
        if (session.selectedAnswer?.trim().isNotEmpty ?? false)
          const SingleActivator(LogicalKeyboardKey.enter): () => notifier.submitAnswer(),
        if (currentExercise != null && currentExercise.options.length >= 4) ...{
          const SingleActivator(LogicalKeyboardKey.digit1): () =>
              notifier.selectAnswer(currentExercise.options[0]),
          const SingleActivator(LogicalKeyboardKey.digit2): () =>
              notifier.selectAnswer(currentExercise.options[1]),
          const SingleActivator(LogicalKeyboardKey.digit3): () =>
              notifier.selectAnswer(currentExercise.options[2]),
          const SingleActivator(LogicalKeyboardKey.digit4): () =>
              notifier.selectAnswer(currentExercise.options[3]),
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
              onPressed: () => _confirmExit(context),
            ),
          ],
          title: Text(
            session.isGhostChallenge
                ? 'Thử Thách Ghost Review'
                : (session.unit?.title ?? 'Luyện Tập Ngữ Pháp'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: [
            if (currentExercise != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currentExercise.type.label,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
      child: Column(
        children: [
          // Step Progress Bar
          LinearProgressIndicator(
            value: session.progressFraction,
            minHeight: 4,
          ),

          // Main Question Content
          Expanded(
            child: currentExercise == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question counter
                            Text(
                              'Câu ${session.currentIndex + 1} / ${session.totalQuestions}',
                              style: theme.typography.small.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Dynamic Question Formats
                            if (currentExercise.type == GrammarExerciseType.choice)
                              ChoiceQuestionWidget(
                                exercise: currentExercise,
                                selectedAnswer: session.selectedAnswer,
                                isSubmitted: session.isSubmitted,
                                onSelectAnswer: (ans) => notifier.selectAnswer(ans),
                              )
                            else if (currentExercise.type == GrammarExerciseType.errorId)
                              ErrorIdQuestionWidget(
                                exercise: currentExercise,
                                selectedAnswer: session.selectedAnswer,
                                isSubmitted: session.isSubmitted,
                                onSelectAnswer: (ans) => notifier.selectAnswer(ans),
                              )
                            else if (currentExercise.type == GrammarExerciseType.cloze)
                              ClozeQuestionWidget(
                                exercise: currentExercise,
                                selectedAnswer: session.selectedAnswer,
                                isSubmitted: session.isSubmitted,
                                isCorrect: session.isCurrentCorrect,
                                onAnswerChanged: (ans) => notifier.selectAnswer(ans),
                                onSubmit: () => notifier.submitAnswer(),
                              ),

                            // Submit Button (only when not submitted)
                            if (!session.isSubmitted) ...[
                              const SizedBox(height: 24),
                              PrimaryButton(
                                size: ButtonSize.large,
                                onPressed: (session.selectedAnswer?.trim().isNotEmpty ?? false)
                                    ? () => notifier.submitAnswer()
                                    : null,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.checkCheck, size: 18),
                                    SizedBox(width: 8),
                                    Text('Kiểm Tra Đáp Án'),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          // Bottom Explanation Sheet (when submitted)
          if (session.isSubmitted && currentExercise != null)
            ExplanationSheet(
              exercise: currentExercise,
              isCorrect: session.isCurrentCorrect ?? false,
              isLastQuestion: session.isLastQuestion,
              onNext: () => notifier.nextQuestion(),
            ),
        ],
      ),
    ),
    ),
    );
  }

  void _confirmExit(BuildContext context) {
    m.showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thoát Phiên Luyện Tập?'),
        content: const Text(
          'Tiến độ của các câu đã làm vẫn được lưu vào hệ thống FSRS. Bạn có chắc muốn dừng bài học lúc này?',
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tiếp tục làm'),
          ),
          DestructiveButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }
}
