import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';

class ExplanationSheet extends StatelessWidget {
  final GrammarExercise exercise;
  final bool isCorrect;
  final bool isLastQuestion;
  final VoidCallback onNext;

  const ExplanationSheet({
    super.key,
    required this.exercise,
    required this.isCorrect,
    required this.isLastQuestion,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final explanation = exercise.explanation;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(
            color: isCorrect ? Colors.green : Colors.red,
            width: 2.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Status
          Row(
            children: [
              Icon(
                isCorrect ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? 'Chính xác! Rất tốt!' : 'Chưa chính xác — Ghi nhớ bẫy này!',
                style: theme.typography.large.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Explanation details
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Translation
                  if (explanation.translation.isNotEmpty)
                    _buildSection(
                      context,
                      icon: LucideIcons.languages,
                      title: 'Dịch nghĩa câu',
                      content: explanation.translation,
                      color: theme.colorScheme.primary,
                    ),

                  // 2. Key Signal
                  if (explanation.keySignal.isNotEmpty)
                    _buildSection(
                      context,
                      icon: LucideIcons.sparkles,
                      title: 'Dấu hiệu nhận diện (Key Signal)',
                      content: explanation.keySignal,
                      color: Colors.amber,
                    ),

                  // 3. Rule
                  if (explanation.rule.isNotEmpty)
                    _buildSection(
                      context,
                      icon: LucideIcons.bookOpenCheck,
                      title: 'Quy tắc bản xứ',
                      content: explanation.rule,
                      color: Colors.blue,
                    ),

                  // 4. Why Correct
                  if (explanation.whyCorrect.isNotEmpty)
                    _buildSection(
                      context,
                      icon: LucideIcons.checkCheck,
                      title: 'Lý giải vì sao đúng',
                      content: explanation.whyCorrect,
                      color: Colors.green,
                    ),

                  // 5. Distractor Breakdown
                  if (explanation.distractorBreakdown.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.shieldAlert, size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Phân tích bẫy phương án sai:',
                            style: theme.typography.small.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...explanation.distractorBreakdown.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${entry.key}: ',
                                      style: theme.typography.small.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.foreground,
                                      ),
                                    ),
                                    TextSpan(
                                      text: entry.value,
                                      style: theme.typography.small.copyWith(
                                        color: theme.colorScheme.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Next Button
          PrimaryButton(
            onPressed: onNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isLastQuestion ? 'Xem Tổng Kết Bài Học' : 'Câu Tiếp Theo'),
                const SizedBox(width: 8),
                Icon(
                  isLastQuestion ? LucideIcons.flag : LucideIcons.arrowRight,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required m.Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: Text(
              content,
              style: theme.typography.small.copyWith(
                height: 1.5,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
