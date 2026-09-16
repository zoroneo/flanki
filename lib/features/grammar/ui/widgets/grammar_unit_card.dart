import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarUnitCard extends StatelessWidget {
  final GrammarUnit unit;
  final UnitProgressSummary summary;
  final bool isMobile;

  const GrammarUnitCard({
    super.key,
    required this.unit,
    required this.summary,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final levelColor = unit.level.color;
    final levelText = unit.level.getLocalizedName(l10n);

    return Card(
      child: Padding(
        padding: isMobile ? AppEdgeInsets.all12 : AppEdgeInsets.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBadges(theme, l10n, levelColor, levelText),
                isMobile ? AppGaps.v6 : AppGaps.v8,
                Text(
                  unit.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (isMobile
                              ? theme.typography.small
                              : theme.typography.base)
                          .copyWith(fontWeight: FontWeight.bold, height: 1.25),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMasteryBar(theme, l10n),
                isMobile ? AppGaps.v8 : AppGaps.v12,
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
          padding: AppEdgeInsets.h8v4,
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.borderSm,
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
        AppGaps.h8,
        Flexible(
          child: Container(
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: AppRadius.borderSm,
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
            margin: const EdgeInsets.only(right: AppSpacing.xs),
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: m.Colors.red.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderLg,
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
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: m.Colors.orange.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderLg,
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
    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: summary.masteryPercentage / 100.0,
              minHeight: 4,
            ),
          ),
          AppGaps.h8,
          Text(
            '${summary.completedCount}/${GrammarConstants.exercisesPerUnit} • ${summary.masteryPercentage.toStringAsFixed(0)}%',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: summary.isMastered
                  ? m.Colors.green
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: summary.masteryPercentage / 100.0,
            minHeight: 5,
          ),
        ),
        AppGaps.h8,
        Text(
          l10n.grammarMasteryPercentage(
            summary.masteryPercentage.toStringAsFixed(0),
          ),
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
    final theoryButton = OutlineButton(
      size: ButtonSize.small,
      onPressed: () => context.push(AppRoutes.grammarTheory(unit.unitId)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.bookOpen, size: AppIconSize.xs),
          AppGaps.h4,
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
      onPressed: () => context.push(AppRoutes.grammarPractice(unit.unitId)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.play, size: AppIconSize.xs),
          AppGaps.h4,
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

    if (isMobile) {
      return Row(
        children: [
          Expanded(child: theoryButton),
          AppGaps.h8,
          Expanded(child: practiceButton),
        ],
      );
    }

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

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              progressWidget,
              AppGaps.v8,
              Row(
                children: [
                  Expanded(child: theoryButton),
                  AppGaps.h8,
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
            AppGaps.h8,
            practiceButton,
          ],
        );
      },
    );
  }
}
