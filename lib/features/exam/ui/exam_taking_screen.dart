import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/exam_models.dart';
import '../providers/exam_session_notifier.dart';
import 'widgets/exam_question_cards.dart';
import 'widgets/exam_questions_sheet.dart';
import 'widgets/exam_taking_dialogs.dart';
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

    // When exam finishes, navigate to result screen
    ref.listen<ExamSessionState>(examSessionProvider, (prev, next) {
      if (next.isFinished && next.submission != null) {
        context.pushReplacement('/exams/$examId/result');
      }
    });

    final isLoading = ref.watch(examSessionProvider.select((s) => s.isLoading));
    final error = ref.watch(examSessionProvider.select((s) => s.error));
    final question = ref.watch(
      examSessionProvider.select((s) => s.currentQuestion),
    );

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
              const Icon(RadixIcons.exclamationTriangle, size: 48),
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

    return _buildTakingScaffold(
      context: context,
      ref: ref,
      notifier: notifier,
      theme: theme,
      l10n: l10n,
      question: question,
    );
  }

  Widget _buildTakingScaffold({
    required BuildContext context,
    required WidgetRef ref,
    required ExamSessionNotifier notifier,
    required ThemeData theme,
    required dynamic l10n,
    required ExamQuestionModel question,
  }) {
    final paperTitle = ref.watch(
      examSessionProvider.select((s) => s.paper?.title),
    );
    final progressRatio = ref.watch(
      examSessionProvider.select((s) => s.progressRatio),
    );
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
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(RadixIcons.arrowLeft, size: 18),
              onPressed: () => ExamTakingDialogs.showConfirmExit(context),
            ),
          ],
          title: Text(paperTitle ?? l10n.takingExamTitle),
          trailing: [
            const ExamTimerBadge(),
            AppGaps.h8,
            PrimaryButton(
              size: ButtonSize.small,
              onPressed: () => ExamTakingDialogs.showConfirmSubmit(
                context: context,
                state: ref.read(examSessionProvider),
                notifier: notifier,
              ),
              child: Text(l10n.submitExam),
            ),
          ],
        ),
      ],
      child: SafeArea(
        child: Column(
          children: [
            // Progress line
            LinearProgressIndicator(value: progressRatio, minHeight: 4),

            // Question content scrollable area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section header
                    _buildSectionHeader(
                      sectionTitle: sectionTitle,
                      currentIndex: currentIndex,
                      totalQuestions: questionsLength,
                      isFlagged: isFlagged,
                      onToggleFlag: () => notifier.toggleFlag(question.id),
                      theme: theme,
                      context: context,
                    ),
                    AppGaps.v16,

                    // Context Passage (if reading)
                    if (question.contextPassage != null &&
                        question.contextPassage!.isNotEmpty)
                      ExamPassageCard(passage: question.contextPassage!),

                    // Question text
                    Text(
                      '${l10n.questionNumberPrefix(question.questionNumber)}: ${question.questionText}',
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppGaps.v16,

                    // Multiple choice options
                    ...question.options.map((opt) {
                      final isSelected = selectedAnswer == opt.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
            _buildBottomToolbar(
              context: context,
              ref: ref,
              currentIndex: currentIndex,
              questionsLength: questionsLength,
              notifier: notifier,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String sectionTitle,
    required int currentIndex,
    required int totalQuestions,
    required bool isFlagged,
    required VoidCallback onToggleFlag,
    required ThemeData theme,
    required BuildContext context,
  }) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sectionTitle.isNotEmpty)
                Text(
                  sectionTitle,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                l10n.questionProgress(currentIndex + 1, totalQuestions),
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        IconButton.ghost(
          size: ButtonSize.small,
          icon: Icon(
            isFlagged ? RadixIcons.bookmarkFilled : RadixIcons.bookmark,
            color: isFlagged ? m.Colors.amber : null,
          ),
          onPressed: onToggleFlag,
        ),
      ],
    );
  }

  Widget _buildBottomToolbar({
    required BuildContext context,
    required WidgetRef ref,
    required int currentIndex,
    required int questionsLength,
    required ExamSessionNotifier notifier,
    required ThemeData theme,
  }) {
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == questionsLength - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            size: ButtonSize.small,
            onPressed: isFirst ? null : () => notifier.prevQuestion(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RadixIcons.arrowLeft, size: 14),
                AppGaps.h4,
                Text(context.l10n.previousQuestion),
              ],
            ),
          ),
          OutlineButton(
            size: ButtonSize.small,
            onPressed: () => ExamQuestionsSheet.show(
              context: context,
              state: ref.read(examSessionProvider),
              notifier: notifier,
              theme: theme,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(RadixIcons.viewGrid, size: 14),
                AppGaps.h4,
                Text(context.l10n.questionList),
              ],
            ),
          ),
          PrimaryButton(
            size: ButtonSize.small,
            onPressed: isLast
                ? () => ExamTakingDialogs.showConfirmSubmit(
                    context: context,
                    state: ref.read(examSessionProvider),
                    notifier: notifier,
                  )
                : () => notifier.nextQuestion(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLast ? context.l10n.submitExam : context.l10n.nextQuestion,
                ),
                AppGaps.h4,
                Icon(
                  isLast ? RadixIcons.check : RadixIcons.arrowRight,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
