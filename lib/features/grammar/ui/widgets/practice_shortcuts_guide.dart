import 'package:shadcn_flutter/shadcn_flutter.dart';

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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(12),
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
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.grammarShortcutsTitle,
                style: theme.typography.large.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildShortcutRow(
            context,
            '1, 2, 3, 4',
            l10n.grammarShortcutSelectCheck,
          ),
          const SizedBox(height: 12),
          _buildShortcutRow(
            context,
            'Enter / Space',
            l10n.grammarShortcutNextQuestion,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: 18,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.grammarPracticeTipTitle,
                style: theme.typography.base.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(6),
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
        const SizedBox(width: 12),
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
