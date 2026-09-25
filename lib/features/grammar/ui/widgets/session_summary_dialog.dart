import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';

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
    final colors = context.colors;
    final l10n = context.l10n;
    final accuracy = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100.0
        : 0.0;
    final isPerfect = correctCount == totalQuestions;

    return Center(
      child: Container(
        constraints:
            const BoxConstraints(maxWidth: AppDimensions.modalDesktopMaxWidth),
        margin: AppEdgeInsets.all24,
        child: Card(
          child: Padding(
            padding: AppEdgeInsets.all24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  width: AppDimensions.summaryIconContainerSize,
                  height: AppDimensions.summaryIconContainerSize,
                  decoration: BoxDecoration(
                    color: isPerfect
                        ? colors.success.withValues(alpha: 0.15)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPerfect ? LucideIcons.trophy : LucideIcons.award,
                    size: AppIconSize.xl,
                    color: isPerfect ? colors.success : theme.colorScheme.primary,
                  ),
                ),
                AppGaps.v16,

                Text(
                  isGhostChallenge
                      ? l10n.grammarGhostChallengeCompleted
                      : (isPerfect
                            ? l10n.grammarPerfectScoreTitle
                            : l10n.grammarUnitSessionCompleted),
                  style: theme.typography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppGaps.v8,
                Text(
                  isGhostChallenge
                      ? l10n.grammarGhostChallengeCompletedSubtitle
                      : l10n.grammarUnitSessionCompletedSubtitle,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppGaps.v24,

                // Stats Row
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                    horizontal: AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted.withValues(alpha: 0.4),
                    borderRadius: AppRadius.borderLg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        context,
                        label: l10n.grammarStatCorrectCount,
                        value: '$correctCount / $totalQuestions',
                        color: colors.success,
                      ),
                      _buildStatColumn(
                        context,
                        label: l10n.grammarStatAccuracy,
                        value: '${accuracy.toStringAsFixed(1)}%',
                        color:
                            accuracy >= GrammarConstants.passAccuracyThreshold
                            ? colors.success
                            : colors.warning,
                      ),
                      if (!isGhostChallenge)
                        _buildStatColumn(
                          context,
                          label: l10n.grammarStatGhostsToFix,
                          value: '$ghostCount',
                          color: ghostCount > 0 ? colors.error : colors.success,
                        ),
                    ],
                  ),
                ),
                AppGaps.v24,

                // Action Buttons
                if (ghostCount > 0 && !isGhostChallenge) ...[
                  PrimaryButton(
                    onPressed: onStartGhostChallenge,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.flame, size: AppIconSize.md),
                        AppGaps.h8,
                        Text(l10n.grammarFixGhostsNow(ghostCount)),
                      ],
                    ),
                  ),
                  AppGaps.v12,
                  OutlineButton(
                    onPressed: onReturnCatalog,
                    child: Text(l10n.grammarBackToCatalog),
                  ),
                ] else ...[
                  PrimaryButton(
                    onPressed: onReturnCatalog,
                    child: Text(l10n.grammarBackToCatalog),
                  ),
                  AppGaps.v12,
                  GhostButton(
                    onPressed: onRestart,
                    child: Text(l10n.grammarRestartSession),
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
        AppGaps.v4,
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
