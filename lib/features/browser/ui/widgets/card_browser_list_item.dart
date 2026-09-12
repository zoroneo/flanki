import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';
import '../../../../core/models/card.dart';
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
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.card,
        borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (card.hasFlag)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:
                              CardActionSheet.ankiFlagColors[card.flag] ??
                              m.Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        stripHtml(card.front),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: theme.colorScheme.foreground,
                          decoration: card.isSuspended
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (card.isSuspended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: m.Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.filterSuspended,
                          style: const TextStyle(
                            fontSize: 9,
                            color: m.Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stripHtml(card.back),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.mutedForeground,
                  ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        key: ValueKey('card_${card.id}'),
        filled: true,
        padding: EdgeInsets.zero,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.hasFlag)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 5, right: 10),
                      decoration: BoxDecoration(
                        color:
                            CardActionSheet.ankiFlagColors[card.flag] ??
                            m.Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFrontText(theme),
                        const SizedBox(height: 4),
                        _buildBackText(theme),
                        const SizedBox(height: 8),
                        _buildMetaRow(theme, l10n),
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

  Widget _buildFrontText(ThemeData theme) {
    return Text(
      stripHtml(card.front),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.foreground,
        decoration: card.isSuspended ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildBackText(ThemeData theme) {
    return Text(
      stripHtml(card.back),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: theme.colorScheme.mutedForeground),
    );
  }

  Widget _buildMetaRow(ThemeData theme, dynamic l10n) {
    return Row(
      children: [
        Text(
          l10n.deckPrefix(deckTitle ?? card.deckId),
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const Spacer(),
        Text(
          card.intervalDays > 0
              ? l10n.intervalBadge(card.intervalDays)
              : l10n.newBadge,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: card.intervalDays > 0
                ? theme.colorScheme.primary
                : m.Colors.green,
          ),
        ),
      ],
    );
  }
}
