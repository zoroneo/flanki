import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../study/widgets/rich_card_content.dart';

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
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: isMobile ? 18 : 20, color: iconColor),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    title,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 14),
            RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: isMobile
                  ? TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: theme.colorScheme.foreground,
                    )
                  : theme.typography.base.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.foreground,
                    ),
            ),
          ],
        ),
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
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sigma,
                    size: isMobile ? 18 : 20, color: m.Colors.blue),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarFormulasTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...formulas.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    : const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: isMobile ? 12.5 : 13.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichCardContent(
                      content: entry.value,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.start,
                      textStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: isMobile ? 12.5 : 14,
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
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.triangleAlert,
                    size: isMobile ? 18 : 20, color: m.Colors.orange),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarCommonTrapsTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...commonTraps.map((trap) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 10 : 16),
                padding: isMobile
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(10),
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
                        fontSize: isMobile ? 13.5 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 10),
                    _buildWrongExample(isMobile, trap.exampleWrong),
                    const SizedBox(height: 6),
                    _buildRightExample(isMobile, trap.exampleRight),
                    SizedBox(height: isMobile ? 6 : 10),
                    _buildNote(theme, isMobile, trap.note),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongExample(bool isMobile, String wrong) {
    return Container(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: m.Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: m.Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❌ ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: RichCardContent(
              content: wrong,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? 12.5 : 13.5,
                color: m.Colors.red,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightExample(bool isMobile, String right) {
    return Container(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: m.Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: m.Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ ', style: TextStyle(fontSize: 13)),
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
        Icon(LucideIcons.info,
            size: isMobile ? 13 : 15, color: m.Colors.orange),
        const SizedBox(width: 6),
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
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.bookOpen,
                    size: isMobile ? 18 : 20, color: m.Colors.purple),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarExtraGuidesTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...extraGuides.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 10 : 14),
                padding: isMobile
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: isMobile ? 13.5 : 15,
                        fontWeight: FontWeight.bold,
                        color: m.Colors.purple,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    RichCardContent(
                      content: entry.value,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.start,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 13 : 14.5,
                        height: isMobile ? 1.45 : 1.55,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
