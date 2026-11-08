import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Labels for the 21 FSRS v5 parameters.
const List<String> kFsrsParameterNames = [
  'w[0] - S_again',
  'w[1] - S_hard',
  'w[2] - S_good',
  'w[3] - S_easy',
  'w[4] - D_init',
  'w[5] - D_slope',
  'w[6] - D_delta',
  'w[7] - D_reversion',
  'w[8] - S_recall_base',
  'w[9] - S_recall_pow',
  'w[10] - S_recall_exp',
  'w[11] - S_forget_base',
  'w[12] - S_forget_diff',
  'w[13] - S_forget_stab',
  'w[14] - S_forget_ret',
  'w[15] - Hard_penalty',
  'w[16] - Easy_bonus',
  'w[17] - Short_mult',
  'w[18] - Short_offset',
  'w[19] - Short_stab_pow',
  'w[20] - Memory_decay',
];

/// Displays partitioned matrix of 21 FSRS parameters comparing baseline vs optimized.
class FsrsParameterMatrixView extends StatelessWidget {
  final List<double> baseline;
  final List<double> candidate;

  const FsrsParameterMatrixView({
    super.key,
    required this.baseline,
    required this.candidate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroup(
          theme,
          title: l10n.fsrsGroupInitialStability,
          startIndex: 0,
          endIndex: 4,
        ),
        AppGaps.v12,
        _buildGroup(
          theme,
          title: l10n.fsrsGroupDifficulty,
          startIndex: 4,
          endIndex: 8,
        ),
        AppGaps.v12,
        _buildGroup(
          theme,
          title: l10n.fsrsGroupRecall,
          startIndex: 8,
          endIndex: 11,
        ),
        AppGaps.v12,
        _buildGroup(
          theme,
          title: l10n.fsrsGroupForget,
          startIndex: 11,
          endIndex: 15,
        ),
        AppGaps.v12,
        _buildGroup(
          theme,
          title: l10n.fsrsGroupDecay,
          startIndex: 15,
          endIndex: 21,
        ),
      ],
    );
  }

  Widget _buildGroup(
    ThemeData theme, {
    required String title,
    required int startIndex,
    required int endIndex,
  }) {
    return SurfaceCard(
      padding: AppEdgeInsets.all12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.v8,
          for (int i = startIndex; i < endIndex; i++) ...[
            _buildParamRow(theme, i),
            if (i < endIndex - 1) const Divider(),
          ],
        ],
      ),
    );
  }

  Widget _buildParamRow(ThemeData theme, int index) {
    final oldVal = baseline[index];
    final newVal = candidate[index];
    final diff = newVal - oldVal;
    final isModified = diff.abs() > 1e-4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              kFsrsParameterNames[index],
              style: theme.typography.small.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                oldVal.toStringAsFixed(4),
                style: theme.typography.xSmall.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.mutedForeground,
                  decoration:
                      isModified ? TextDecoration.lineThrough : null,
                ),
              ),
              if (isModified) ...[
                AppGaps.h6,
                Icon(
                  LucideIcons.arrowRight,
                  size: AppIconSize.xs,
                  color: theme.colorScheme.mutedForeground,
                ),
                AppGaps.h6,
                Text(
                  newVal.toStringAsFixed(4),
                  style: theme.typography.small.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    color: diff > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.destructive,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
