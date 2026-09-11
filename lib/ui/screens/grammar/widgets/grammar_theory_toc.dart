import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarTheoryHeaderBanner extends StatelessWidget {
  final GrammarUnit unit;
  final bool isMobile;

  const GrammarTheoryHeaderBanner({
    super.key,
    required this.unit,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelLabel = unit.level.displayName;
    final levelColor = unit.level.color;

    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: isMobile ? 10.5 : 11,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unit.category.code.toUpperCase(),
                    style: TextStyle(
                      fontSize: isMobile ? 10.5 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Text(
              unit.title,
              style: isMobile
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: theme.colorScheme.foreground,
                    )
                  : theme.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class GrammarTheoryTocCard extends StatelessWidget {
  final GrammarUnit unit;
  final VoidCallback onScrollToConcept;
  final VoidCallback? onScrollToFormulas;
  final VoidCallback? onScrollToTraps;
  final VoidCallback? onScrollToGuides;

  const GrammarTheoryTocCard({
    super.key,
    required this.unit,
    required this.onScrollToConcept,
    this.onScrollToFormulas,
    this.onScrollToTraps,
    this.onScrollToGuides,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.listTree, size: 15, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.grammarTableOfContents,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GrammarTocItem(
              icon: LucideIcons.lightbulb,
              iconColor: m.Colors.amber,
              title: l10n.grammarCoreConceptTitle,
              onTap: onScrollToConcept,
            ),
            if (unit.formulas.isNotEmpty && onScrollToFormulas != null) ...[
              const SizedBox(height: 2),
              GrammarTocItem(
                icon: LucideIcons.sigma,
                iconColor: m.Colors.blue,
                title: l10n.grammarFormulasTitle,
                onTap: onScrollToFormulas!,
              ),
            ],
            if (unit.commonTraps.isNotEmpty && onScrollToTraps != null) ...[
              const SizedBox(height: 2),
              GrammarTocItem(
                icon: LucideIcons.triangleAlert,
                iconColor: m.Colors.orange,
                title: l10n.grammarCommonTrapsTitle,
                onTap: onScrollToTraps!,
              ),
            ],
            if (unit.extraGuides.isNotEmpty && onScrollToGuides != null) ...[
              const SizedBox(height: 2),
              GrammarTocItem(
                icon: LucideIcons.bookOpen,
                iconColor: m.Colors.purple,
                title: l10n.grammarExtraGuidesTitle,
                onTap: onScrollToGuides!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GrammarTocItem extends StatelessWidget {
  final IconData icon;
  final m.Color iconColor;
  final String title;
  final VoidCallback onTap;

  const GrammarTocItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
