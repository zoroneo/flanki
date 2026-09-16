import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/grammar_models.dart';
import 'grammar_theory_tab_views.dart';

class GrammarTrapsTabView extends StatelessWidget {
  final GrammarUnit unit;

  const GrammarTrapsTabView({super.key, required this.unit});

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
            icon: LucideIcons.triangleAlert,
            iconColor: m.Colors.orange,
            title: l10n.grammarCommonTrapsTitle,
          ),
          AppGaps.v8,
          ...unit.commonTraps.map((trap) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: AppEdgeInsets.all8,
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichCardContent(
                    content: trap.trap,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppGaps.v8,
                  GrammarExampleBox(
                    icon: '❌ ',
                    content: trap.exampleWrong,
                    color: m.Colors.red,
                  ),
                  AppGaps.v4,
                  GrammarExampleBox(
                    icon: '✅ ',
                    content: trap.exampleRight,
                    color: m.Colors.green,
                    isBold: true,
                  ),
                  if (trap.note.isNotEmpty) ...[
                    AppGaps.v6,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          LucideIcons.info,
                          size: AppIconSize.xs,
                          color: m.Colors.orange,
                        ),
                        AppGaps.h4,
                        Expanded(
                          child: RichCardContent(
                            content: trap.note,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textAlign: TextAlign.start,
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.mutedForeground,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class GrammarGuidesTabView extends StatelessWidget {
  final GrammarUnit unit;

  const GrammarGuidesTabView({super.key, required this.unit});

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
            icon: LucideIcons.bookOpen,
            iconColor: m.Colors.purple,
            title: l10n.grammarExtraGuidesTitle,
          ),
          AppGaps.v8,
          ...unit.extraGuides.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: AppEdgeInsets.all8,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.25),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: theme.colorScheme.border.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: m.Colors.purple,
                    ),
                  ),
                  AppGaps.v4,
                  RichCardContent(
                    content: entry.value,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    textStyle: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: theme.colorScheme.foreground,
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
