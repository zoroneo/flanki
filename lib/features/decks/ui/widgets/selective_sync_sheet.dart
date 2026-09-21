import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_modal.dart';
import '../../providers/deck_notifier.dart';

/// Modal sheet allowing users to selectively enable or disable cloud sync per deck.
class SelectiveSyncSheet extends ConsumerWidget {
  const SelectiveSyncSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAdaptiveModal<void>(
      context: context,
      builder: (context, isDesktop) => const SelectiveSyncSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final notifier = ref.read(deckListProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.mutedForeground.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: AppRadius.borderXs,
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Icon(
                  LucideIcons.cloudCog,
                  size: AppIconSize.md,
                  color: theme.colorScheme.primary,
                ),
                AppGaps.h8,
                Expanded(
                  child: Text(
                    l10n.selectiveSyncTitle,
                    style: theme.typography.large.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppGaps.v4,
            Text(
              l10n.selectiveSyncSubtitle,
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            AppGaps.v16,
            const Divider(),
            AppGaps.v8,

            // Decks List
            if (decks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Center(
                  child: Text(
                    l10n.noDecksFound,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: decks.length,
                  separatorBuilder: (context, index) => AppGaps.v8,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    final isSyncEnabled = deck.isSyncEnabled;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: theme.colorScheme.border.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deck.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                AppGaps.v2,
                                Row(
                                  children: [
                                    Text(
                                      '${deck.totalCount} ${l10n.cardsCount}',
                                      style: theme.typography.xSmall.copyWith(
                                        color:
                                            theme.colorScheme.mutedForeground,
                                      ),
                                    ),
                                    AppGaps.h8,
                                    Container(
                                      padding: AppEdgeInsets.h4v2,
                                      decoration: BoxDecoration(
                                        color: isSyncEnabled
                                            ? AppColors.success.withValues(
                                                alpha: 0.15,
                                              )
                                            : theme.colorScheme.mutedForeground
                                                  .withValues(alpha: 0.15),
                                        borderRadius: AppRadius.borderSm,
                                      ),
                                      child: Text(
                                        isSyncEnabled
                                            ? l10n.deckSyncActive
                                            : l10n.deckExcludedFromSync,
                                        style: context.textStyles.caption
                                            .copyWith(
                                              color: isSyncEnabled
                                                  ? AppColors.success
                                                  : theme
                                                        .colorScheme
                                                        .mutedForeground,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isSyncEnabled,
                            onChanged: (val) {
                              notifier.toggleDeckSync(deck.id, val);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            AppGaps.v16,
          ],
        ),
      ),
    );
  }
}
