import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/theme/app_tokens.dart';
import 'subdeck_row_item.dart';

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
        padding: AppEdgeInsets.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppEdgeInsets.all8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: Icon(
                    isExpanded.value
                        ? LucideIcons.folderOpen
                        : LucideIcons.folder,
                    size: AppIconSize.md,
                    color: theme.colorScheme.primary,
                  ),
                ),
                AppGaps.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: AppEdgeInsets.tag,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: Text(
                          l10n.subdecksCount(subdecks.length),
                          style: context.textStyles.captionBold.copyWith(
                            color: theme.colorScheme.secondaryForeground,
                          ),
                        ),
                      ),
                      AppGaps.v4,
                      Text(
                        parentName,
                        style: theme.typography.h4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      AppGaps.v4,
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
                    duration: AppDurations.normal,
                    child: const Icon(
                      LucideIcons.chevronDown,
                      size: AppIconSize.md,
                    ),
                  ),
                  onPressed: () {
                    isExpanded.value = !isExpanded.value;
                  },
                ),
              ],
            ),
            AppGaps.v16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.s6,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (totalDue > 0)
                        Container(
                          padding: AppEdgeInsets.countBadge,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.destructive.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Text(
                            '$totalDue ${l10n.dueCards}',
                            style: context.textStyles.sub.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ),
                      if (totalNew > 0)
                        Container(
                          padding: AppEdgeInsets.countBadge,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Text(
                            '$totalNew ${l10n.newCards}',
                            style: context.textStyles.sub.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      Text(
                        l10n.cardsCount(totalCards),
                        style: context.textStyles.xSmallMuted,
                      ),
                    ],
                  ),
                ),
                AppGaps.h8,
                PrimaryButton(
                  alignment: Alignment.center,
                  onPressed: () => onStudyDeck(targetStudyDeck.id),
                  size: ButtonSize.small,
                  leading: const Center(
                    child: Icon(LucideIcons.play, size: AppIconSize.sm),
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
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.md),
        ),
      ),
      child: Padding(
        padding: AppEdgeInsets.v4,
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
              SubdeckRowItem(deck: subdecks[index], onStudyDeck: onStudyDeck),
            ],
          ],
        ),
      ),
    );
  }
}
