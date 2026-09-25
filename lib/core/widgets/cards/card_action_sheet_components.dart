import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/card.dart';
import '../../theme/app_tokens.dart';

Color getAnkiFlagColor(BuildContext context, CardFlag flag) {
  final colors = context.colors;
  return switch (flag) {
    CardFlag.none => AppColors.mutedGrey,
    CardFlag.red => colors.flagRed,
    CardFlag.orange => colors.flagOrange,
    CardFlag.green => colors.flagGreen,
    CardFlag.blue => colors.flagBlue,
    CardFlag.pink => colors.flagPink,
    CardFlag.turquoise => colors.flagTurquoise,
    CardFlag.purple => colors.flagPurple,
  };
}

class CardFlagSelector extends StatelessWidget {
  final CardFlag currentFlag;
  final ValueChanged<CardFlag> onSelectFlag;

  const CardFlagSelector({
    super.key,
    required this.currentFlag,
    required this.onSelectFlag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => onSelectFlag(CardFlag.none),
          child: Container(
            width: AppDimensions.touchTargetMin,
            height: AppDimensions.touchTargetMin,
            alignment: Alignment.center,
            child: Container(
              width: AppSpacing.xxl,
              height: AppSpacing.xxl,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: currentFlag == CardFlag.none
                      ? theme.colorScheme.foreground
                      : theme.colorScheme.border,
                  width: currentFlag == CardFlag.none ? 2 : 1,
                ),
              ),
              child: Icon(
                LucideIcons.ban,
                size: AppIconSize.sm,
                color: currentFlag == CardFlag.none
                    ? theme.colorScheme.foreground
                    : theme.colorScheme.mutedForeground,
              ),
            ),
          ),
        ),
        ...CardFlag.values.where((f) => f != CardFlag.none).map((flag) {
          final isSelected = currentFlag == flag;
          final c = getAnkiFlagColor(context, flag);

          return GestureDetector(
            onTap: () => onSelectFlag(flag),
            child: Container(
              width: AppDimensions.touchTargetMin,
              height: AppDimensions.touchTargetMin,
              alignment: Alignment.center,
              child: Container(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.foreground,
                          width: AppDimensions.borderThick,
                        )
                      : Border.all(
                          color: c,
                          width: AppDimensions.borderFocus,
                        ),
                ),
                child: isSelected
                    ? const Icon(
                        LucideIcons.check,
                        size: AppIconSize.sm,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class CardFsrsStatsCard extends StatelessWidget {
  final CardModel card;

  const CardFsrsStatsCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      padding: AppEdgeInsets.all12,
      filled: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatMini(
            label: l10n.stabilityLabel,
            value: '${card.stability.toStringAsFixed(1)}d',
          ),
          _StatMini(
            label: l10n.difficultyLabel,
            value: card.difficulty.toStringAsFixed(1),
          ),
          _StatMini(label: l10n.repsLabel, value: '${card.reps}'),
          _StatMini(label: l10n.lapsesLabel, value: '${card.lapses}'),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.typography.semiBold),
        AppGaps.v2,
        Text(label, style: context.textStyles.captionMuted),
      ],
    );
  }
}
