import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../models/exam_models.dart';
import '../providers/exam_session_notifier.dart';
import 'widgets/exam_question_cards.dart';
import 'widgets/exam_questions_sheet.dart';
import 'widgets/exam_section_header.dart';
import 'widgets/exam_taking_dialogs.dart';
import 'widgets/exam_taking_toolbar.dart';
import 'widgets/exam_timer_badge.dart';

class ExamTakingScreen extends HookConsumerWidget {
  final String examId;

  const ExamTakingScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final notifier = ref.read(examSessionProvider.notifier);

    useEffect(() {
      Future.microtask(() => notifier.initSession(examId));
      return null;
    }, [examId]);

    final question = ref.watch(
      examSessionProvider.select((s) => s.currentQuestion),
    );

    // Auto-heal if questions were loaded from unseeded/empty cache
    useEffect(() {
      if (question != null && question.options.isEmpty) {
        Future.microtask(() => notifier.reloadQuestions());
      }
      return null;
    }, [question?.options.isEmpty]);

    // When exam finishes, navigate to result screen
    ref.listen<ExamSessionState>(examSessionProvider, (prev, next) {
      if (next.isFinished && next.submission != null) {
        context.pushReplacement('/exams/$examId/result');
      }
    });

    final isLoading = ref.watch(examSessionProvider.select((s) => s.isLoading));
    final error = ref.watch(examSessionProvider.select((s) => s.error));

    if (isLoading) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      final localizedErr = ref.watch(
        examSessionProvider.select((s) => s.getLocalizedError(l10n)),
      );
      return Scaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(RadixIcons.exclamationTriangle, size: AppIconSize.hero),
              AppGaps.v12,
              Text(localizedErr ?? error),
              AppGaps.v16,
              PrimaryButton(
                onPressed: () => context.pop(),
                child: Text(l10n.backButton),
              ),
            ],
          ),
        ),
      );
    }

    if (question == null) {
      return Scaffold(child: Center(child: Text(l10n.examNoQuestions)));
    }

    final paperTitle = ref.watch(
      examSessionProvider.select((s) => s.paper?.title),
    );
    final remainingSec = ref.watch(
      examSessionProvider.select((s) => s.remainingSeconds),
    );
    final timeElapsedRatio = ref.watch(
      examSessionProvider.select((s) => s.timeElapsedRatio),
    );
    final isUrgent = remainingSec < ExamConstants.urgentTimerSeconds;
    final selectedAnswer = ref.watch(
      examSessionProvider.select((s) => s.selectedAnswers[question.id]),
    );
    final currentIndex = ref.watch(
      examSessionProvider.select((s) => s.currentIndex),
    );
    final questionsLength = ref.watch(
      examSessionProvider.select((s) => s.questions.length),
    );
    final isFlagged = ref.watch(
      examSessionProvider.select(
        (s) => s.flaggedQuestionIds.contains(question.id),
      ),
    );
    final sectionTitle = ref.watch(
      examSessionProvider.select((s) {
        final sec = s.sections.firstWhere(
          (sec) => sec.id == question.sectionId,
          orElse: () => const ExamSectionModel(id: '', examId: '', title: ''),
        );
        return sec.title;
      }),
    );

    return Scaffold(
      headers: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              child: SizedBox(
                height: AppDimensions.touchTargetMin,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.ghost(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        icon: const Icon(
                          RadixIcons.arrowLeft,
                          size: AppIconSize.sm,
                        ),
                        onPressed: () =>
                            ExamTakingDialogs.showConfirmExit(context),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: ExamTimerBadge(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryButton(
                        size: ButtonSize.normal,
                        onPressed: () => ExamTakingDialogs.showConfirmSubmit(
                          context: context,
                          state: ref.read(examSessionProvider),
                          notifier: notifier,
                        ),
                        child: Text(
                          l10n.submitExam,
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Progress indicator bar attached to the bottom of the AppBar
            SizedBox(
              width: double.infinity,
              child: LinearProgressIndicator(
                value: timeElapsedRatio,
                minHeight: 3,
                color: isUrgent
                    ? theme.colorScheme.destructive
                    : theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.muted.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scrollable question area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageMobile,
                  vertical: AppSpacing.smPlus,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subheader with paper title, section & progress
                    ExamSectionHeader(
                      paperTitle: paperTitle,
                      sectionTitle: sectionTitle,
                      currentIndex: currentIndex,
                      totalQuestions: questionsLength,
                    ),
                    AppGaps.v12,

                    // Context Passage (if present)
                    if (question.contextPassage != null &&
                        question.contextPassage!.isNotEmpty) ...[
                      ExamPassageCard(passage: question.contextPassage!),
                      AppGaps.v12,
                    ],

                    // Question prompt card
                    ExamQuestionPromptCard(
                      question: question,
                      isFlagged: isFlagged,
                      onToggleBookmark: () => notifier.toggleFlag(question.id),
                    ),
                    AppGaps.v16,

                    // Multiple choice options
                    if (question.options.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            l10n.examNoQuestions,
                            style: theme.typography.small.copyWith(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    else
                      ...question.options.map((opt) {
                        final isSelected = selectedAnswer == opt.id;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.smPlus,
                          ),
                          child: ExamOptionCard(
                            opt: opt,
                            isSelected: isSelected,
                            onTap: () =>
                                notifier.selectAnswer(question.id, opt.id),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Toolbar
            ExamTakingToolbar(
              isFirst: currentIndex == 0,
              isLast: currentIndex == questionsLength - 1,
              onPrev: () => notifier.prevQuestion(),
              onNext: () => notifier.nextQuestion(),
              onOpenSheet: () => ExamQuestionsSheet.show(
                context: context,
                state: ref.read(examSessionProvider),
                notifier: notifier,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
