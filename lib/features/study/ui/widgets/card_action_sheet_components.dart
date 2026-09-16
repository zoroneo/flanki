import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';

const ankiFlagColors = {
  CardFlag.red: m.Colors.red,
  CardFlag.orange: m.Colors.orange,
  CardFlag.green: m.Colors.green,
  CardFlag.blue: m.Colors.blue,
  CardFlag.pink: m.Colors.pink,
  CardFlag.turquoise: m.Colors.cyan,
  CardFlag.purple: m.Colors.purple,
};

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
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Container(
              width: 32,
              height: 32,
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
          final c = ankiFlagColors[flag] ?? m.Colors.grey;

          return GestureDetector(
            onTap: () => onSelectFlag(flag),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: theme.colorScheme.foreground,
                          width: 2.5,
                        )
                      : Border.all(color: c, width: 1.5),
                ),
                child: isSelected
                    ? const Icon(
                        LucideIcons.check,
                        size: AppIconSize.sm,
                        color: m.Colors.white,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
