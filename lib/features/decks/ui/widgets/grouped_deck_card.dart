import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';
import '../../../../core/models/deck.dart';

class GroupedDeckCard extends HookWidget {
  final String parentName;
  final List<DeckModel> subdecks;
  final bool autoExpand;
  final void Function(String deckId) onStudyDeck;

  const GroupedDeckCard({
    super.key,
    required this.parentName,
    required this.subdecks,
    required this.autoExpand,
    required this.onStudyDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpanded = useState(autoExpand);

    useEffect(() {
      if (autoExpand) {
        isExpanded.value = true;
      }
      return null;
    }, [autoExpand]);

    final totalDue = subdecks.fold<int>(0, (sum, d) => sum + d.dueCount);
    final totalNew = subdecks.fold<int>(0, (sum, d) => sum + d.newCount);
    final totalCards = subdecks.fold<int>(0, (sum, d) => sum + d.totalCount);

    final targetStudyDeck = subdecks.firstWhere(
      (d) => d.dueCount > 0,
      orElse: () => subdecks.firstWhere(
        (d) => d.newCount > 0,
        orElse: () => subdecks.first,
      ),
    );

    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParentHeader(
            context: context,
            theme: theme,
            isExpanded: isExpanded,
            totalDue: totalDue,
            totalNew: totalNew,
            totalCards: totalCards,
            targetStudyDeck: targetStudyDeck,
          ),
          if (isExpanded.value) ...[
            Divider(height: 1, color: theme.colorScheme.border),
            _buildSubdecksList(context: context, theme: theme),
          ],
        ],
      ),
    );
  }

  Widget _buildParentHeader({
    required BuildContext context,
    required ThemeData theme,
    required ValueNotifier<bool> isExpanded,
    required int totalDue,
    required int totalNew,
    required int totalCards,
    required DeckModel targetStudyDeck,
  }) {
    final l10n = context.l10n;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        isExpanded.value = !isExpanded.value;
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExpanded.value
                        ? LucideIcons.folderOpen
                        : LucideIcons.folder,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.subdecksCount(subdecks.length),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondaryForeground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        parentName,
                        style: theme.typography.h4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.importedFromApkg,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.ghost(
                  size: ButtonSize.small,
                  icon: AnimatedRotation(
                    turns: isExpanded.value ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(LucideIcons.chevronDown, size: 18),
                  ),
                  onPressed: () {
                    isExpanded.value = !isExpanded.value;
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (totalDue > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.destructive.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$totalDue ${l10n.dueCards}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ),
                      if (totalNew > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$totalNew ${l10n.newCards}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      Text(
                        l10n.cardsCount(totalCards),
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PrimaryButton(
                  alignment: Alignment.center,
                  onPressed: () => onStudyDeck(targetStudyDeck.id),
                  size: ButtonSize.small,
                  leading: const Center(
                    child: Icon(LucideIcons.play, size: 14),
                  ),
                  child: Center(child: Text(l10n.studyNow)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubdecksList({
    required BuildContext context,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.25),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int index = 0; index < subdecks.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  indent: 44,
                  endIndent: 16,
                  color: theme.colorScheme.border.withValues(alpha: 0.4),
                ),
              _buildSubdeckItem(
                context: context,
                theme: theme,
                deck: subdecks[index],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubdeckItem({
    required BuildContext context,
    required ThemeData theme,
    required DeckModel deck,
  }) {
    final l10n = context.l10n;
    final leafName = deck.title.split('::').last;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onStudyDeck(deck.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              deck.isCram ? LucideIcons.zap : LucideIcons.fileText,
              size: 16,
              color: deck.isCram
                  ? m.Colors.amber
                  : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 12),
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
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.destructive.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(4),
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
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
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
            const SizedBox(width: 8),
            IconButton.ghost(
              size: ButtonSize.small,
              icon: const Icon(LucideIcons.play, size: 14),
              onPressed: () => onStudyDeck(deck.id),
            ),
          ],
        ),
      ),
    );
  }
}
