import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
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
    final leafName = deck.title.split(AppConfig.deckHierarchyDelimiter).last;

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
                  ? AppColors.cramAmber
                  : theme.colorScheme.mutedForeground,
            ),
            AppGaps.h12,
            Expanded(
              child: Text(leafName, style: context.textStyles.smallSemiBold),
            ),
            Wrap(
              spacing: AppSpacing.s6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (deck.dueCount > 0)
                  Container(
                    padding: AppEdgeInsets.tag,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.destructive.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      l10n.badgeDue(deck.dueCount),
                      style: context.textStyles.captionBold.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ),
                if (deck.newCount > 0)
                  Container(
                    padding: AppEdgeInsets.tag,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: Text(
                      l10n.badgeNew(deck.newCount),
                      style: context.textStyles.captionBold.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Text(
                  l10n.badgeTotalCards(deck.totalCount),
                  style: context.textStyles.subMuted,
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
