import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';
import '../../../../l10n/generated/app_localizations.dart';

export 'grammar_traps_guides_cards.dart';

class GrammarTheorySectionCard extends StatelessWidget {
  final IconData icon;
  final m.Color iconColor;
  final String title;
  final String content;
  final bool isMobile;

  const GrammarTheorySectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      padding: isMobile ? AppEdgeInsets.h12v8 : AppEdgeInsets.all20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isMobile ? AppIconSize.sm : AppIconSize.md,
                color: iconColor,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  title,
                  style: isMobile
                      ? TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        )
                      : theme.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ),
            ],
          ),
          isMobile ? AppGaps.v6 : AppGaps.v16,
          RichCardContent(
            content: content,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: isMobile
                ? TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: theme.colorScheme.foreground,
                  )
                : theme.typography.base.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.foreground,
                  ),
          ),
        ],
      ),
    );
  }
}

class GrammarTheoryFormulasCard extends StatelessWidget {
  final Map<String, String> formulas;
  final bool isMobile;

  const GrammarTheoryFormulasCard({
    super.key,
    required this.formulas,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      padding: isMobile ? AppEdgeInsets.h12v8 : AppEdgeInsets.all20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sigma,
                size: isMobile ? AppIconSize.sm : AppIconSize.md,
                color: m.Colors.blue,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  l10n.grammarFormulasTitle,
                  style: isMobile
                      ? TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        )
                      : theme.typography.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ),
            ],
          ),
          isMobile ? AppGaps.v8 : AppGaps.v16,
          ...formulas.entries.map((entry) {
            return Container(
              margin: EdgeInsets.only(
                bottom: isMobile ? AppSpacing.xs : AppSpacing.md,
              ),
              padding: isMobile ? AppEdgeInsets.h12v8 : AppEdgeInsets.all16,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.35),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  AppGaps.v4,
                  RichCardContent(
                    content: entry.value,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    textStyle: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
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
