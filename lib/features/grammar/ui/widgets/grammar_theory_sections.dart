import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

import 'package:flanki/core/widgets/rich_card_content.dart';

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

class GrammarTheoryTrapsCard extends StatelessWidget {
  final List<GrammarTrap> commonTraps;
  final bool isMobile;

  const GrammarTheoryTrapsCard({
    super.key,
    required this.commonTraps,
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
                LucideIcons.triangleAlert,
                size: isMobile ? AppIconSize.sm : AppIconSize.md,
                color: m.Colors.orange,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  l10n.grammarCommonTrapsTitle,
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
          ...commonTraps.map((trap) {
            return Container(
              margin: EdgeInsets.only(
                bottom: isMobile ? AppSpacing.sm : AppSpacing.lg,
              ),
              padding: isMobile ? AppEdgeInsets.all8 : AppEdgeInsets.all16,
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
                    textStyle: TextStyle(
                      fontSize: isMobile ? 12.5 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  isMobile ? AppGaps.v6 : AppGaps.v12,
                  _buildWrongExample(isMobile, trap.exampleWrong),
                  AppGaps.v4,
                  _buildRightExample(isMobile, trap.exampleRight),
                  isMobile ? AppGaps.v6 : AppGaps.v12,
                  _buildNote(theme, isMobile, trap.note),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWrongExample(bool isMobile, String wrong) {
    return Container(
      padding: isMobile ? AppEdgeInsets.h8v4 : AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: m.Colors.red.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: m.Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❌ ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: RichCardContent(
              content: wrong,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? 12 : 13.5,
                color: m.Colors.red,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightExample(bool isMobile, String right) {
    return Container(
      padding: isMobile ? AppEdgeInsets.h8v4 : AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: m.Colors.green.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: m.Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: RichCardContent(
              content: right,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? 12.5 : 13.5,
                color: m.Colors.green,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(ThemeData theme, bool isMobile, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          LucideIcons.info,
          size: AppIconSize.xs,
          color: m.Colors.orange,
        ),
        AppGaps.h8,
        Expanded(
          child: RichCardContent(
            content: note,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: theme.colorScheme.mutedForeground,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class GrammarTheoryGuidesCard extends StatelessWidget {
  final Map<String, String> extraGuides;
  final bool isMobile;

  const GrammarTheoryGuidesCard({
    super.key,
    required this.extraGuides,
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
                LucideIcons.bookOpen,
                size: isMobile ? AppIconSize.sm : AppIconSize.md,
                color: m.Colors.purple,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  l10n.grammarExtraGuidesTitle,
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
          ...extraGuides.entries.map((entry) {
            return Container(
              margin: EdgeInsets.only(
                bottom: isMobile ? AppSpacing.sm : AppSpacing.md,
              ),
              padding: isMobile ? AppEdgeInsets.all8 : AppEdgeInsets.all16,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.25),
                borderRadius: AppRadius.borderSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: isMobile ? 12.5 : 15,
                      fontWeight: FontWeight.bold,
                      color: m.Colors.purple,
                    ),
                  ),
                  isMobile ? AppGaps.v4 : AppGaps.v8,
                  RichCardContent(
                    content: entry.value,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textAlign: TextAlign.start,
                    textStyle: TextStyle(
                      fontSize: isMobile ? 12.5 : 14.5,
                      height: isMobile ? 1.4 : 1.55,
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
