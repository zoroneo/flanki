import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../router/app_router.dart';
import '../data/exam_repository.dart';
import '../models/exam_models.dart';
import 'widgets/exam_question_result_card.dart';
import 'widgets/exam_score_summary_card.dart';

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
              onPressed: () => context.go(AppRoutes.exams),
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
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(RadixIcons.arrowLeft, size: AppIconSize.smPlus),
              onPressed: () => context.go(AppRoutes.exams),
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
              ExamScoreSummaryCard(submission: sub, paper: p, l10n: l10n),
              AppGaps.v16,

              // Action Buttons
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: OutlineButton(
                        alignment: Alignment.center,
                        onPressed: () => context.push(AppRoutes.wrongNotebook),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(RadixIcons.bookmark, size: AppIconSize.xsPlus),
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
                            const Icon(RadixIcons.reload, size: AppIconSize.xsPlus),
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

              ...questions.map(
                (q) => ExamQuestionResultCard(
                  question: q,
                  userAnswer: sub.answers[q.id],
                  l10n: l10n,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
