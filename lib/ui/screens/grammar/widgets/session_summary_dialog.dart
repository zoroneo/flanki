import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';

class SessionSummaryDialog extends StatelessWidget {
  final int totalQuestions;
  final int correctCount;
  final int ghostCount;
  final bool isGhostChallenge;
  final VoidCallback onStartGhostChallenge;
  final VoidCallback onReturnCatalog;
  final VoidCallback onRestart;

  const SessionSummaryDialog({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.ghostCount,
    required this.isGhostChallenge,
    required this.onStartGhostChallenge,
    required this.onReturnCatalog,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = totalQuestions > 0 ? (correctCount / totalQuestions) * 100.0 : 0.0;
    final isPerfect = correctCount == totalQuestions;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isPerfect
                        ? Colors.green.withValues(alpha: 0.15)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPerfect ? LucideIcons.trophy : LucideIcons.award,
                    size: 32,
                    color: isPerfect ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 18),

                Text(
                  isGhostChallenge
                      ? 'Hoàn Thành Thử Thách Ghost!'
                      : (isPerfect ? 'Xuất Sắc! Hoàn Hảo 100%!' : 'Hoàn Thành Bài Học!'),
                  style: theme.typography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isGhostChallenge
                      ? 'Bạn đã ôn tập lại các câu hỏi từng làm sai.'
                      : 'Hệ thống đã cập nhật chu kỳ ghi nhớ FSRS v4.5 vào bộ não của bạn.',
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        context,
                        label: 'Số câu đúng',
                        value: '$correctCount / $totalQuestions',
                        color: Colors.green,
                      ),
                      _buildStatColumn(
                        context,
                        label: 'Độ chính xác',
                        value: '${accuracy.toStringAsFixed(1)}%',
                        color: accuracy >= GrammarConstants.passAccuracyThreshold
                            ? Colors.green
                            : Colors.orange,
                      ),
                      if (!isGhostChallenge)
                        _buildStatColumn(
                          context,
                          label: 'Cần sửa lỗi',
                          value: '$ghostCount',
                          color: ghostCount > 0 ? Colors.red : Colors.green,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                if (ghostCount > 0 && !isGhostChallenge) ...[
                  PrimaryButton(
                    onPressed: onStartGhostChallenge,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.flame, size: 18),
                        const SizedBox(width: 8),
                        Text('Xóa Điểm Yếu Ngay ($ghostCount câu sai)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlineButton(
                    onPressed: onReturnCatalog,
                    child: const Text('Về Danh Mục Chuyên Đề'),
                  ),
                ] else ...[
                  PrimaryButton(
                    onPressed: onReturnCatalog,
                    child: const Text('Về Danh Mục Chuyên Đề'),
                  ),
                  const SizedBox(height: 10),
                  GhostButton(
                    onPressed: onRestart,
                    child: const Text('Luyện Tập Lại Bài Này'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String label,
    required String value,
    required m.Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.typography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
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
