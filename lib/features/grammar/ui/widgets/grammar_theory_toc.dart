import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final levelLabel = unit.level.getLocalizedName(l10n);
    final levelColor = unit.level.color;

    return Card(
      padding: isMobile ? AppEdgeInsets.h12v8 : AppEdgeInsets.all20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppEdgeInsets.h8v4,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  levelLabel,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ),
              AppGaps.h8,
              Container(
                padding: AppEdgeInsets.h8v4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  unit.category.code.toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          isMobile ? AppGaps.v6 : AppGaps.v12,
          Text(
            unit.title,
            style: isMobile
                ? TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.listTree,
                size: AppIconSize.xs,
                color: theme.colorScheme.primary,
              ),
              AppGaps.h8,
              Text(
                l10n.grammarTableOfContents,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppGaps.v12,
          GrammarTocItem(
            icon: LucideIcons.lightbulb,
            iconColor: m.Colors.amber,
            title: l10n.grammarCoreConceptTitle,
            onTap: onScrollToConcept,
          ),
          if (unit.formulas.isNotEmpty && onScrollToFormulas != null) ...[
            AppGaps.v2,
            GrammarTocItem(
              icon: LucideIcons.sigma,
              iconColor: m.Colors.blue,
              title: l10n.grammarFormulasTitle,
              onTap: onScrollToFormulas!,
            ),
          ],
          if (unit.commonTraps.isNotEmpty && onScrollToTraps != null) ...[
            AppGaps.v2,
            GrammarTocItem(
              icon: LucideIcons.triangleAlert,
              iconColor: m.Colors.orange,
              title: l10n.grammarCommonTrapsTitle,
              onTap: onScrollToTraps!,
            ),
          ],
          if (unit.extraGuides.isNotEmpty && onScrollToGuides != null) ...[
            AppGaps.v2,
            GrammarTocItem(
              icon: LucideIcons.bookOpen,
              iconColor: m.Colors.purple,
              title: l10n.grammarExtraGuidesTitle,
              onTap: onScrollToGuides!,
            ),
          ],
        ],
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
          padding: AppEdgeInsets.h12v8,
          decoration: const BoxDecoration(borderRadius: AppRadius.borderSm),
          child: Row(
            children: [
              Icon(icon, size: AppIconSize.xs, color: iconColor),
              AppGaps.h8,
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
                size: AppIconSize.xs,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
