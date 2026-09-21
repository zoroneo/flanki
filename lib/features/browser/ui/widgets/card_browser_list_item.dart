import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';

import 'package:flanki/features/study/ui/widgets/card_action_sheet.dart';

final _htmlTagRegex = RegExp(r'<[^>]*>');
final _whitespaceRegex = RegExp(r'\s+');

String stripHtml(String text) {
  if (!text.contains('<')) return text;
  return text
      .replaceAll(_htmlTagRegex, ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll(_whitespaceRegex, ' ')
      .trim();
}

class DesktopCardRowItem extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback onTap;

  const DesktopCardRowItem({
    super.key,
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.smPlus,
              vertical: AppSpacing.s10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (card.hasFlag)
                      Container(
                        width: AppSpacing.sm,
                        height: AppSpacing.sm,
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color:
                              CardActionSheet.ankiFlagColors[card.flag] ??
                              AppColors.mutedGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        stripHtml(card.front),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (isSelected
                                    ? context.textStyles.navBold
                                    : context.textStyles.nav)
                                .copyWith(
                                  color: theme.colorScheme.foreground,
                                  decoration: card.isSuspended
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                      ),
                    ),
                    if (card.isSuspended)
                      Container(
                        padding: AppEdgeInsets.badgeSm,
                        decoration: BoxDecoration(
                          color: context.colors.warning.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          l10n.filterSuspended,
                          style: context.textStyles.badge.copyWith(
                            color: context.colors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                AppGaps.v4,
                Text(
                  stripHtml(card.back),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.subMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileCardRowItem extends StatelessWidget {
  final CardModel card;
  final String? deckTitle;
  final VoidCallback onTap;

  const MobileCardRowItem({
    super.key,
    required this.card,
    this.deckTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        key: AppWidgetKeys.card(card.id),
        filled: true,
        padding: EdgeInsets.zero,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: AppEdgeInsets.all16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.hasFlag)
                    Container(
                      width: AppSpacing.sm,
                      height: AppSpacing.sm,
                      margin: const EdgeInsets.only(
                        top: AppSpacing.xs,
                        right: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color:
                            CardActionSheet.ankiFlagColors[card.flag] ??
                            AppColors.mutedGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFrontText(context, theme),
                        AppGaps.v4,
                        _buildBackText(context, theme),
                        AppGaps.v8,
                        _buildMetaRow(context, theme, l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontText(BuildContext context, ThemeData theme) {
    return Text(
      stripHtml(card.front),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.smallSemiBold.copyWith(
        color: theme.colorScheme.foreground,
        decoration: card.isSuspended ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildBackText(BuildContext context, ThemeData theme) {
    return Text(
      stripHtml(card.back),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: context.textStyles.xSmallMuted,
    );
  }

  Widget _buildMetaRow(BuildContext context, ThemeData theme, dynamic l10n) {
    return Row(
      children: [
        Text(
          l10n.deckPrefix(deckTitle ?? card.deckId),
          style: context.textStyles.captionMuted,
        ),
        const Spacer(),
        Text(
          card.intervalDays > 0
              ? l10n.intervalBadge(card.intervalDays)
              : l10n.newBadge,
          style: context.textStyles.captionSemiBold.copyWith(
            color: card.intervalDays > 0
                ? theme.colorScheme.primary
                : context.colors.success,
          ),
        ),
      ],
    );
  }
}
