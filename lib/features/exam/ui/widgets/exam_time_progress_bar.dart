import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/exam_constants.dart';
import '../../providers/exam_session_notifier.dart';

/// Progress indicator bar attached to the bottom of the Exam AppBar.
/// Isolates the 1-second timer tick so the parent ExamTakingScreen does not rebuild.
class ExamTimeProgressBar extends ConsumerWidget {
  const ExamTimeProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeElapsedRatio = ref.watch(
      examSessionProvider.select((s) => s.timeElapsedRatio),
    );
    final isUrgent = ref.watch(
      examSessionProvider.select(
        (s) => s.remainingSeconds < ExamConstants.urgentTimerSeconds,
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: LinearProgressIndicator(
        value: timeElapsedRatio,
        minHeight: 3,
        color: isUrgent
            ? theme.colorScheme.destructive
            : theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.muted.withValues(alpha: 0.35),
      ),
    );
  }
}
