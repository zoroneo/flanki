import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/theme/app_tokens.dart';

class SubdeckRowItem extends StatelessWidget {
  final DeckModel deck;
  final ValueChanged<String> onStudyDeck;

  const SubdeckRowItem({
    super.key,
    required this.deck,
    required this.onStudyDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final leafName = deck.title.split('::').last;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onStudyDeck(deck.id),
      child: Padding(
        padding: AppEdgeInsets.h16v8,
        child: Row(
          children: [
            Icon(
              deck.isCram ? LucideIcons.zap : LucideIcons.fileText,
              size: AppIconSize.sm,
              color: deck.isCram
                  ? m.Colors.amber
                  : theme.colorScheme.mutedForeground,
            ),
            AppGaps.h12,
            Expanded(
              child: Text(
                leafName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
            Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (deck.dueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.destructive.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      l10n.badgeDue(deck.dueCount),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ),
                if (deck.newCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      l10n.badgeNew(deck.newCount),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Text(
                  l10n.badgeTotalCards(deck.totalCount),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
            AppGaps.h8,
            IconButton.ghost(
              size: ButtonSize.small,
              icon: const Icon(LucideIcons.play, size: AppIconSize.sm),
              onPressed: () => onStudyDeck(deck.id),
            ),
          ],
        ),
      ),
    );
  }
}
