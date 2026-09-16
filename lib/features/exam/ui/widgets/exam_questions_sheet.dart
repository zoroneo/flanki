import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/exam_session_notifier.dart';

class ExamQuestionsSheet {
  const ExamQuestionsSheet._();

  static void show({
    required BuildContext context,
    required ExamSessionState state,
    required ExamSessionNotifier notifier,
    required ThemeData theme,
  }) {
    final l10n = context.l10n;
    m.showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.questionListTitle,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppGaps.v12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(state.questions.length, (i) {
                  final q = state.questions[i];
                  final isAnswered = state.selectedAnswers.containsKey(q.id);
                  final isFlagged = state.flaggedQuestionIds.contains(q.id);
                  final isCurrent = state.currentIndex == i;

                  m.Color bg = theme.colorScheme.muted;
                  if (isCurrent) {
                    bg = theme.colorScheme.primary;
                  } else if (isFlagged) {
                    bg = m.Colors.amber.shade600;
                  } else if (isAnswered) {
                    bg = m.Colors.green.shade600;
                  }

                  return m.InkWell(
                    onTap: () {
                      notifier.jumpTo(i);
                      Navigator.pop(ctx);
                    },
                    borderRadius: AppRadius.borderMd,
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: AppRadius.borderMd,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: isAnswered || isCurrent || isFlagged
                              ? m.Colors.white
                              : theme.colorScheme.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
