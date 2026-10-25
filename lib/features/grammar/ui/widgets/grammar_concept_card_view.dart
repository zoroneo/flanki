import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';
import '../../models/grammar_models.dart';

import 'grammar_contrast_matrix.dart';

/// Structured, card-based presentation for grammar unit core concepts.
/// Transforms long walls of text into distinct, scannable educational cards.
class GrammarConceptCardView extends StatelessWidget {
  final GrammarUnit unit;
  final bool isMobile;

  const GrammarConceptCardView({
    super.key,
    required this.unit,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final l10n = context.l10n;

    final raw = unit.coreConcept;
    final normalized = raw.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    final parts = normalized.split(RegExp(r'\n+(?=\d+\.\s)'));

    // Fallback if content doesn't match standard multi-part format
    if (parts.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            padding: isMobile ? AppEdgeInsets.h12v8 : AppEdgeInsets.all20,
            child: RichCardContent(
              content: unit.coreConcept,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? AppTypography.nav : AppTypography.base,
                height: 1.5,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      );
    }

    final leadIntro = parts.first.trim();
    final sections = parts.sublist(1);
    final hasContrast = GrammarContrastMatrix.hasContrastData(unit.unitId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leadIntro.isNotEmpty) ...[
          _buildLeadTakeawayCard(context, theme, colors, l10n, leadIntro),
          AppGaps.v12,
        ],
        if (hasContrast) ...[
          GrammarContrastMatrix(unitId: unit.unitId, isMobile: isMobile),
          AppGaps.v12,
        ],
        _ExpandableDetailSection(
          sections: sections,
          isMobile: isMobile,
          theme: theme,
          colors: colors,
        ),
      ],
    );
  }

  /// Elegant callout card for the core mindset takeaway
  Widget _buildLeadTakeawayCard(
    BuildContext context,
    ThemeData theme,
    AppColorsExtension colors,
    AppLocalizations l10n,
    String content,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: isMobile ? AppEdgeInsets.all12 : AppEdgeInsets.all16,
      decoration: BoxDecoration(
        color: isDark
            ? colors.cramAmber.withValues(alpha: 0.08)
            : colors.cramAmber.withValues(alpha: 0.06),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: colors.cramAmber.withValues(alpha: isDark ? 0.3 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.lightbulb,
                size: isMobile ? AppIconSize.xs : AppIconSize.sm,
                color: colors.cramAmber,
              ),
              AppGaps.h8,
              Text(
                l10n.grammarCoreConceptTitle,
                style: TextStyle(
                  fontSize: isMobile
                      ? AppTypography.xSmallPlus
                      : AppTypography.nav,
                  fontWeight: FontWeight.w700,
                  color: colors.cramAmber,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          AppGaps.v8,
          RichCardContent(
            content: content.replaceAll('\n', '<br/>'),
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              fontSize: isMobile ? AppTypography.nav : AppTypography.base,
              height: 1.5,
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable accordion section to prevent wall-of-text fatigue.
/// Collapsed by default so user sees interactive visual tools first.
class _ExpandableDetailSection extends StatefulWidget {
  final List<String> sections;
  final bool isMobile;
  final ThemeData theme;
  final AppColorsExtension colors;

  const _ExpandableDetailSection({
    required this.sections,
    required this.isMobile,
    required this.theme,
    required this.colors,
  });

  @override
  State<_ExpandableDetailSection> createState() =>
      _ExpandableDetailSectionState();
}

class _ExpandableDetailSectionState extends State<_ExpandableDetailSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.isMobile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = widget.colors;
    final isMobile = widget.isMobile;
    final isDark = theme.brightness == Brightness.dark;

    if (!isMobile) {
      // Desktop: Render flat cards directly on the canvas without outer container border or accordion button
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.sections.asMap().entries.map((entry) {
          final index = entry.key;
          final content = entry.value.trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _buildSectionCard(
              context,
              theme,
              colors,
              index,
              content,
              false,
            ),
          );
        }).toList(),
      );
    }

    // Mobile: Collapsible accordion to save vertical space
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.border
              : theme.colorScheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header toggle button
          OutlineButton(
            density: ButtonDensity.compact,
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: isMobile ? AppEdgeInsets.all8 : AppEdgeInsets.all12,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.bookOpen,
                    size: isMobile ? AppIconSize.xs : AppIconSize.sm,
                    color: colors.info,
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(
                      context.l10n.grammarReadDetailedTheory(
                        widget.sections.length,
                      ),
                      style: TextStyle(
                        fontSize: isMobile
                            ? AppTypography.caption
                            : AppTypography.nav,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppDurations.normal,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: isMobile
                        ? AppEdgeInsets.all12
                        : AppEdgeInsets.all16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.sections.asMap().entries.map((entry) {
                        final index = entry.key;
                        final content = entry.value.trim();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildSectionCard(
                            context,
                            theme,
                            colors,
                            index,
                            content,
                            isMobile,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    ThemeData theme,
    AppColorsExtension colors,
    int index,
    String content,
    bool isMobile,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    final (Color accentColor, _) = switch (index) {
      0 => (colors.success, LucideIcons.circleCheck),
      1 => (colors.info, LucideIcons.timer),
      _ => (colors.cramAmber, LucideIcons.arrowLeftRight),
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.muted.withValues(alpha: 0.15)
            : theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sm),
              ),
            ),
          ),
          Padding(
            padding: isMobile ? AppEdgeInsets.all8 : AppEdgeInsets.all12,
            child: RichCardContent(
              content: content.replaceAll('\n', '<br/>'),
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: isMobile ? AppTypography.nav : AppTypography.base,
                height: 1.5,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
