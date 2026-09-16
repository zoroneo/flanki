import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../providers/exam_session_notifier.dart';

class ExamTimerBadge extends ConsumerWidget {
  const ExamTimerBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remainingSec = ref.watch(
      examSessionProvider.select((s) => s.remainingSeconds),
    );

    final mins = remainingSec ~/ 60;
    final secs = remainingSec % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isUrgent = remainingSec < 300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent ? m.Colors.red.shade700 : theme.colorScheme.secondary,
        borderRadius: AppRadius.borderLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            RadixIcons.clock,
            size: 14,
            color: isUrgent ? m.Colors.white : theme.colorScheme.foreground,
          ),
          AppGaps.h8,
          Text(
            timeStr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUrgent ? m.Colors.white : theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
