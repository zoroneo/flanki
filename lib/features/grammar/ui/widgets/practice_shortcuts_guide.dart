import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PracticeShortcutsGuide extends StatelessWidget {
  final GrammarExercise? exercise;

  const PracticeShortcutsGuide({super.key, this.exercise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: AppEdgeInsets.all24,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.keyboard,
                size: AppIconSize.md,
                color: theme.colorScheme.primary,
              ),
              AppGaps.h8,
              Text(
                l10n.grammarShortcutsTitle,
                style: theme.typography.large.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppGaps.v20,
          _buildShortcutRow(
            context,
            '1, 2, 3, 4',
            l10n.grammarShortcutSelectCheck,
          ),
          AppGaps.v12,
          _buildShortcutRow(
            context,
            'Enter / Space',
            l10n.grammarShortcutNextQuestion,
          ),
          AppGaps.v24,
          const Divider(),
          AppGaps.v20,
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: AppIconSize.md,
                color: theme.colorScheme.mutedForeground,
              ),
              AppGaps.h8,
              Text(
                l10n.grammarPracticeTipTitle,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppGaps.v12,
          Text(
            _getExerciseTip(exercise, l10n),
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(BuildContext context, String keyText, String desc) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: AppEdgeInsets.h8v4,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Text(
            keyText,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        AppGaps.h12,
        Expanded(child: Text(desc, style: theme.typography.small)),
      ],
    );
  }

  String _getExerciseTip(GrammarExercise? ex, AppLocalizations l10n) {
    if (ex == null) return '';
    switch (ex.type) {
      case GrammarExerciseType.choice:
        return l10n.grammarTipChoice;
      case GrammarExerciseType.errorId:
        return l10n.grammarTipErrorId;
      case GrammarExerciseType.cloze:
        return l10n.grammarTipCloze;
    }
  }
}
