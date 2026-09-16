import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../providers/exam_session_notifier.dart';

class ExamTakingDialogs {
  const ExamTakingDialogs._();

  static void showConfirmSubmit({
    required BuildContext context,
    required ExamSessionState state,
    required ExamSessionNotifier notifier,
  }) {
    final l10n = context.l10n;
    final unanswered = state.questions.length - state.answeredCount;
    m.showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmSubmitExamTitle),
        content: Text(
          unanswered > 0
              ? l10n.confirmSubmitUnfinished(unanswered)
              : l10n.confirmSubmitFinished,
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.continueExam),
          ),
          PrimaryButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.submitExam();
            },
            child: Text(l10n.submitExamNow),
          ),
        ],
      ),
    );
  }

  static void showConfirmExit(BuildContext context) {
    final l10n = context.l10n;
    m.showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmExitExamTitle),
        content: Text(l10n.confirmExitExamDesc),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.stayInExam),
          ),
          DestructiveButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(l10n.exitExam),
          ),
        ],
      ),
    );
  }
}
