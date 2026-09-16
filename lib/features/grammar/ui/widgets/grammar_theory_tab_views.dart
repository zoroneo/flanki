import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/grammar_models.dart';
export 'grammar_theory_extra_tab_views.dart';

class GrammarConceptTabView extends StatelessWidget {
  final GrammarUnit unit;

  const GrammarConceptTabView({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GrammarTabSectionHeader(
            icon: LucideIcons.lightbulb,
            iconColor: m.Colors.amber,
            title: l10n.grammarCoreConceptTitle,
          ),
          AppGaps.v8,
          RichCardContent(
            content: unit.coreConcept,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class GrammarFormulasTabView extends StatelessWidget {
  final GrammarUnit unit;

  const GrammarFormulasTabView({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GrammarTabSectionHeader(
            icon: LucideIcons.sigma,
            iconColor: m.Colors.blue,
            title: l10n.grammarFormulasTitle,
          ),
          AppGaps.v8,
          ...unit.formulas.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: AppEdgeInsets.h12v8,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.35),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: theme.colorScheme.border.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppGaps.v4,
                  RichCardContent(
                    content: entry.value,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class GrammarTabSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const GrammarTabSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: AppIconSize.sm, color: iconColor),
        AppGaps.h8,
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.foreground,
          ),
        ),
      ],
    );
  }
}

class GrammarExampleBox extends StatelessWidget {
  final String icon;
  final String content;
  final m.MaterialColor color;
  final bool isBold;

  const GrammarExampleBox({
    super.key,
    required this.icon,
    required this.content,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.h8v4,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          Expanded(
            child: RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
