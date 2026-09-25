import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rich_card_content.dart';

class ExplanationSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final m.Color color;

  const ExplanationSection({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.xs, color: color),
              AppGaps.h8,
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.xSmallPlus,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v4,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xl),
            child: RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: AppTypography.nav,
                height: 1.4,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DistractorItemCard extends StatelessWidget {
  final String rawKey;
  final String explanation;

  const DistractorItemCard({
    super.key,
    required this.rawKey,
    required this.explanation,
  });

  (String badgeText, String? detailText) _parseDistractorKey(
    String rawKey,
    AppLocalizations l10n,
  ) {
    final match = RegExp(
      r'^(?:option\s*)?([A-D])(?:\s*[:(]\s*(.*?)[)]?)?$',
      caseSensitive: false,
    ).firstMatch(rawKey.trim());
    if (match != null) {
      final letter = match.group(1)!.toUpperCase();
      final detail = match.group(2)?.trim();
      return (
        l10n.grammarOptionBadge(letter),
        detail != null && detail.isNotEmpty ? detail : null,
      );
    }
    return (rawKey, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = context.colors;
    final (badgeText, detailText) = _parseDistractorKey(rawKey, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppEdgeInsets.h8v4,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.x,
                      size: AppIconSize.xs,
                      color: colors.error,
                    ),
                    AppGaps.h4,
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: AppTypography.subPlus,
                        fontWeight: FontWeight.bold,
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
              ),
              if (detailText != null) ...[
                AppGaps.h8,
                Expanded(
                  child: Text(
                    detailText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypography.xSmall,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          AppGaps.v4,
          RichCardContent(
            content: explanation,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              fontSize: AppTypography.xSmallPlus,
              height: 1.4,
              color: theme.colorScheme.foreground.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
