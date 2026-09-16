import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/exam_repository.dart';
import '../models/exam_models.dart';

class ExamResultScreen extends HookConsumerWidget {
  final String examId;

  const ExamResultScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final repository = ref.watch(examRepositoryProvider);

    final isLoading = useState(true);
    final paper = useState<ExamPaperModel?>(null);
    final submission = useState<ExamSubmissionModel?>(null);
    final questions = useState<List<ExamQuestionModel>>([]);

    useEffect(() {
      Future.microtask(() async {
        final p = await repository.getExamPaper(examId);
        final subs = await repository.getSubmissions(examId);
        final qs = await repository.getExamQuestions(examId);

        paper.value = p;
        if (subs.isNotEmpty) {
          submission.value = subs.first;
        }
        questions.value = qs;
        isLoading.value = false;
      });
      return null;
    }, [examId]);

    if (isLoading.value) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    final sub = submission.value;
    final p = paper.value;
    if (sub != null && p != null) {
      return _buildResultScaffold(
        context: context,
        theme: theme,
        l10n: l10n,
        sub: sub,
        p: p,
        questions: questions.value,
      );
    }

    return Scaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.examResultNotFound),
            AppGaps.v16,
            PrimaryButton(
              onPressed: () => context.go('/exams'),
              child: Text(l10n.backToCatalog),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScaffold({
    required BuildContext context,
    required ThemeData theme,
    required dynamic l10n,
    required ExamSubmissionModel sub,
    required ExamPaperModel p,
    required List<ExamQuestionModel> questions,
  }) {
    final isPassed = sub.isPassed;
    final mins = sub.durationSeconds ~/ 60;
    final secs = sub.durationSeconds % 60;
    final durationStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(RadixIcons.arrowLeft, size: 18),
              onPressed: () => context.go('/exams'),
            ),
          ],
          title: Text(l10n.examResultTitle),
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Big Result Summary Card
              Card(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? m.Colors.green.shade600
                            : m.Colors.red.shade600,
                        borderRadius: AppRadius.borderXl,
                      ),
                      child: Text(
                        isPassed ? l10n.examPassed : l10n.examFailed,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: m.Colors.white,
                        ),
                      ),
                    ),
                    AppGaps.v12,
                    Text(
                      l10n.examScorePoints(sub.score),
                      style: theme.typography.xLarge.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isPassed
                            ? m.Colors.green.shade700
                            : theme.colorScheme.foreground,
                      ),
                    ),
                    AppGaps.v8,
                    Text(
                      p.title,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppGaps.v16,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          l10n.correctCountStat,
                          '${sub.totalCorrect}/${sub.totalQuestions}',
                          theme,
                        ),
                        _buildStatColumn(l10n.durationStat, durationStr, theme),
                        _buildStatColumn(
                          l10n.passingScoreStat,
                          '${p.passingScore}',
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppGaps.v16,

              // Action Buttons
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: OutlineButton(
                        alignment: Alignment.center,
                        onPressed: () => context.push('/exams/wrong-notebook'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(RadixIcons.bookmark, size: 14),
                            AppGaps.h8,
                            Text(l10n.wrongNotebook),
                          ],
                        ),
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: PrimaryButton(
                        alignment: Alignment.center,
                        onPressed: () =>
                            context.pushReplacement('/exams/$examId/taking'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(RadixIcons.reload, size: 14),
                            AppGaps.h8,
                            Text(l10n.retakeExam),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppGaps.v24,

              Text(
                l10n.questionDetails,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppGaps.v12,

              ...questions.map((q) {
                final userAns = sub.answers[q.id];
                final isCorrect =
                    userAns != null &&
                    userAns.trim().toUpperCase() ==
                        q.correctAnswer.trim().toUpperCase();

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.smPlus),
                  child: Card(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.questionNumberPrefix(q.questionNumber),
                              style: theme.typography.small.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCorrect)
                              Row(
                                children: [
                                  const Icon(
                                    RadixIcons.checkCircled,
                                    size: 16,
                                    color: m.Colors.green,
                                  ),
                                  AppGaps.h4,
                                  Text(
                                    l10n.correctBadge,
                                    style: const TextStyle(
                                      color: m.Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  const Icon(
                                    RadixIcons.crossCircled,
                                    size: 16,
                                    color: m.Colors.red,
                                  ),
                                  AppGaps.h4,
                                  Text(
                                    l10n.wrongBadge,
                                    style: const TextStyle(
                                      color: m.Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        AppGaps.v6,
                        Text(q.questionText, style: theme.typography.base),
                        AppGaps.v8,

                        // Options preview
                        ...q.options.map((opt) {
                          final isUserChoice = userAns == opt.id;
                          final isRightChoice =
                              q.correctAnswer.toUpperCase() ==
                              opt.id.toUpperCase();

                          m.Color? borderColor;
                          m.Color? bgColor;
                          if (isRightChoice) {
                            borderColor = m.Colors.green;
                            bgColor = m.Colors.green.withValues(alpha: 0.08);
                          } else if (isUserChoice) {
                            borderColor = m.Colors.red;
                            bgColor = m.Colors.red.withValues(alpha: 0.08);
                          }

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.smPlus,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(
                                color: borderColor ?? theme.colorScheme.border,
                              ),
                              color: bgColor,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${opt.id}. ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(child: Text(opt.text)),
                                if (isRightChoice)
                                  const Icon(
                                    RadixIcons.check,
                                    size: 14,
                                    color: m.Colors.green,
                                  )
                                else if (isUserChoice)
                                  const Icon(
                                    RadixIcons.cross1,
                                    size: 14,
                                    color: m.Colors.red,
                                  ),
                              ],
                            ),
                          );
                        }),

                        if (q.explanation.isNotEmpty) ...[
                          AppGaps.v8,
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: AppRadius.borderMd,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(RadixIcons.infoCircled, size: 14),
                                AppGaps.h8,
                                Expanded(
                                  child: Text(
                                    l10n.explanationPrefix(q.explanation),
                                    style: theme.typography.xSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.typography.base.copyWith(fontWeight: FontWeight.bold),
        ),
        AppGaps.v2,
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
