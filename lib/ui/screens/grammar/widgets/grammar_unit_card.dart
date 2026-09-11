import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarUnitCard extends StatelessWidget {
  final GrammarUnit unit;
  final UnitProgressSummary summary;

  const GrammarUnitCard({
    super.key,
    required this.unit,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final levelColor = unit.level.color;
    final levelText = unit.level.getLocalizedName(l10n);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBadges(theme, l10n, levelColor, levelText),
                const SizedBox(height: 10),
                Text(
                  unit.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.base.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMasteryBar(theme, l10n),
                const SizedBox(height: 10),
                _buildActionButtons(context, theme, l10n),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadges(
    ThemeData theme,
    AppLocalizations l10n,
    m.Color levelColor,
    String levelText,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: levelColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            levelText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: levelColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              unit.category.code.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ),
        ),
        if (summary.ghostCount > 0 || summary.dueCount > 0) const Spacer(),
        if (summary.ghostCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: m.Colors.red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.grammarGhostsCount(summary.ghostCount),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: m.Colors.red,
              ),
            ),
          ),
        if (summary.dueCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: m.Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.grammarBadgeDue(summary.dueCount),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: m.Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMasteryBar(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: summary.masteryPercentage / 100.0,
            minHeight: 5,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          l10n.grammarMasteryPercentage(
              summary.masteryPercentage.toStringAsFixed(0)),
          style: theme.typography.xSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: summary.isMastered
                ? m.Colors.green
                : theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return LayoutBuilder(
      builder: (context, cardConstraints) {
        final isNarrow = cardConstraints.maxWidth < 360;
        final progressWidget = Text(
          l10n.grammarCompletedProgress(
            summary.completedCount,
            GrammarConstants.exercisesPerUnit,
          ),
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
            fontSize: 11,
          ),
        );

        final theoryButton = OutlineButton(
          size: ButtonSize.small,
          onPressed: () => context.push('/grammar/${unit.unitId}/theory'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.bookOpen, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.grammarTheoryButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

        final practiceButton = PrimaryButton(
          size: ButtonSize.small,
          onPressed: () => context.push('/grammar/${unit.unitId}/practice'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.play, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.grammarPracticeButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              progressWidget,
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: theoryButton),
                  const SizedBox(width: 6),
                  Expanded(child: practiceButton),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            progressWidget,
            const Spacer(),
            theoryButton,
            const SizedBox(width: 6),
            practiceButton,
          ],
        );
      },
    );
  }
}
