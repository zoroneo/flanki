import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';
import '../../models/grammar_models.dart';

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
    final l10n = context.l10n;
    final colors = context.colors;

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
                color: colors.warning,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  l10n.grammarCommonTrapsTitle,
                  style: isMobile
                      ? TextStyle(
                          fontSize: AppTypography.navPlus,
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
                  _buildWrongExample(colors, isMobile, trap.exampleWrong),
                  AppGaps.v4,
                  _buildRightExample(colors, isMobile, trap.exampleRight),
                  isMobile ? AppGaps.v6 : AppGaps.v12,
                  _buildNote(colors, theme, isMobile, trap.note),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWrongExample(AppColorsExtension colors, bool isMobile, String wrong) {
    return Container(
      padding: isMobile ? AppEdgeInsets.h8v4 : AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('❌ ', style: TextStyle(fontSize: AppTypography.xSmall)),
          Expanded(
            child: RichCardContent(
              content: wrong,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? AppTypography.xSmall : AppTypography.navPlus,
                color: colors.error,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightExample(AppColorsExtension colors, bool isMobile, String right) {
    return Container(
      padding: isMobile ? AppEdgeInsets.h8v4 : AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: colors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅ ', style: TextStyle(fontSize: AppTypography.xSmall)),
          Expanded(
            child: RichCardContent(
              content: right,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? AppTypography.xSmallPlus : AppTypography.navPlus,
                color: colors.success,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(AppColorsExtension colors, ThemeData theme, bool isMobile, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          LucideIcons.info,
          size: AppIconSize.xs,
          color: colors.warning,
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
    final l10n = context.l10n;
    final colors = context.colors;

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
                color: colors.accentPurple,
              ),
              isMobile ? AppGaps.h8 : AppGaps.h12,
              Expanded(
                child: Text(
                  l10n.grammarExtraGuidesTitle,
                  style: isMobile
                      ? TextStyle(
                          fontSize: AppTypography.navPlus,
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
                      color: colors.accentPurple,
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
