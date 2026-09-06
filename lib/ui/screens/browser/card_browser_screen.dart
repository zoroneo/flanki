import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../study/widgets/card_action_sheet.dart';

class CardBrowserScreen extends HookConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final browserState = ref.watch(cardBrowserProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);

    final searchController = useTextEditingController(
      text: browserState.searchQuery,
    );
    final filteredCards = browserState.filteredCards;

    const pageSize = 30;
    final displayedCount = useState(pageSize);

    useEffect(
      () {
        displayedCount.value = pageSize;
        return null;
      },
      [
        browserState.searchQuery,
        browserState.filterType,
        browserState.selectedDeckId,
      ],
    );

    final visibleCount = math.min(displayedCount.value, filteredCards.length);
    final hasMore = visibleCount < filteredCards.length;

    void openCardDetail(CardModel card) {
      m.showModalBottomSheet(
        context: context,
        useRootNavigator: false,
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return m.Material(
            type: m.MaterialType.transparency,
            child: CardActionSheet(
              card: card,
              onSetFlag: (flag) => browserNotifier.setCardFlag(card.id, flag),
              onBury: () => browserNotifier.toggleCardBury(card.id),
              onSuspend: () => browserNotifier.toggleCardSuspend(card.id),
              onDelete: () => browserNotifier.deleteCard(card.id),
              onEdit: (f, b) {
                browserNotifier.updateCard(card.copyWith(front: f, back: b));
              },
            ),
          );
        },
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200) {
            if (displayedCount.value < filteredCards.length) {
              displayedCount.value = (displayedCount.value + pageSize).clamp(
                0,
                filteredCards.length,
              );
            }
          }
          return false;
        },
        child: m.NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPersistentHeader(
                pinned: true,
                floating: true,
                delegate: _SearchHeaderDelegate(
                  topPadding: topPadding,
                  theme: theme,
                  titleRow: AppBar(
                    backgroundColor: m.Colors.transparent,
                    useSafeArea: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(l10n.navBrowser),
                    trailing: [
                      IconButton.ghost(
                        size: ButtonSize.small,
                        icon: const Icon(LucideIcons.plus, size: 20),
                        onPressed: () => context.push('/editor'),
                      ),
                    ],
                  ),
                  searchBox: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    child: TextField(
                      controller: searchController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      placeholder: Text(l10n.searchCardsPlaceholder),
                      onChanged: (val) => browserNotifier.setSearchQuery(val),
                      features: [
                        InputFeature.leading(
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 6),
                            child: Icon(
                              LucideIcons.search,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                        if (browserState.searchQuery.isNotEmpty)
                          InputFeature.trailing(
                            IconButton.ghost(
                              size: ButtonSize.small,
                              icon: const Icon(LucideIcons.x, size: 14),
                              onPressed: () {
                                searchController.clear();
                                browserNotifier.setSearchQuery('');
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  filterRow: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(
                          label:
                              '${l10n.filterAll} • ${browserState.allCards.length}',
                          isSelected:
                              browserState.filterType == CardFilterType.all,
                          onTap: () =>
                              browserNotifier.setFilterType(CardFilterType.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterDue,
                          isSelected:
                              browserState.filterType == CardFilterType.due,
                          onTap: () =>
                              browserNotifier.setFilterType(CardFilterType.due),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterNew,
                          isSelected:
                              browserState.filterType == CardFilterType.newCard,
                          onTap: () => browserNotifier.setFilterType(
                            CardFilterType.newCard,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterFlagged,
                          isSelected:
                              browserState.filterType == CardFilterType.flagged,
                          onTap: () => browserNotifier.setFilterType(
                            CardFilterType.flagged,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterSuspended,
                          isSelected:
                              browserState.filterType ==
                              CardFilterType.suspended,
                          onTap: () => browserNotifier.setFilterType(
                            CardFilterType.suspended,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
            ];
          },
          body: filteredCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.inbox,
                        size: 48,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noCardsFound,
                        style: theme.typography.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: visibleCount + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= visibleCount) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final card = filteredCards[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Dismissible(
                        key: ValueKey(card.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.destructive,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                m.Icons.delete_outline,
                                color: m.Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.delete,
                                style: const TextStyle(
                                  color: m.Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          browserNotifier.deleteCard(card.id);
                          showToast(
                            context: context,
                            builder: (toastCtx, overlay) {
                              return SurfaceCard(
                                child: Basic(
                                  title: Text(l10n.cardDeleted),
                                  subtitle: Text(
                                    card.front,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  leading: const Icon(
                                    m.Icons.delete_outline,
                                    color: m.Colors.red,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GhostButton(
                                        size: ButtonSize.small,
                                        onPressed: () {
                                          overlay.close();
                                          browserNotifier.addCard(card);
                                        },
                                        child: Text(
                                          l10n.undo,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      IconButton.ghost(
                                        icon: const Icon(
                                          m.Icons.close,
                                          size: 14,
                                        ),
                                        onPressed: () => overlay.close(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openCardDetail(card),
                          child: Opacity(
                            opacity: card.isSuspended ? 0.6 : 1.0,
                            child: Card(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Flag or suspend indicator
                                  Container(
                                    width: 4,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: card.hasFlag
                                          ? (CardActionSheet.ankiFlagColors[card
                                                    .flag] ??
                                                m.Colors.grey)
                                          : (card.isSuspended
                                                ? m.Colors.grey
                                                : theme.colorScheme.border),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                card.front,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.typography.semiBold
                                                    .copyWith(
                                                      decoration:
                                                          card.isSuspended
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                              ),
                                            ),
                                            if (card.noteType == NoteType.cloze)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1.5,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Cloze',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card.back,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.typography.xSmall
                                              .copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .mutedForeground,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              l10n.deckPrefix(card.deckId),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: theme
                                                    .colorScheme
                                                    .mutedForeground,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              card.intervalDays > 0
                                                  ? l10n.intervalBadge(
                                                      card.intervalDays,
                                                    )
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
                                        ),
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
                  },
                ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final Widget titleRow;
  final Widget searchBox;
  final Widget filterRow;
  final ThemeData theme;

  static const double _titleHeight = 44.0;
  static const double _searchHeight = 46.0;
  static const double _filterHeight = 38.0;

  _SearchHeaderDelegate({
    required this.topPadding,
    required this.titleRow,
    required this.searchBox,
    required this.filterRow,
    required this.theme,
  });

  @override
  double get minExtent => topPadding + _searchHeight + _filterHeight + 6.0;

  @override
  double get maxExtent =>
      topPadding + _titleHeight + _searchHeight + _filterHeight + 6.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / _titleHeight).clamp(0.0, 1.0);
    final borderAlpha = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final currentTop = (topPadding + _titleHeight - shrinkOffset).clamp(
      topPadding,
      topPadding + _titleHeight,
    );

    return Container(
      color: theme.colorScheme.background,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Title & Action Buttons (AppBar): fade out and slide up as you scroll
          Positioned(
            top: topPadding - (shrinkOffset * 0.8),
            left: 0,
            right: 0,
            height: _titleHeight,
            child: Opacity(
              opacity: (1.0 - progress * 1.8).clamp(0.0, 1.0),
              child: titleRow,
            ),
          ),
          // Search box: smoothly glides up into the top bar under status bar
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            height: _searchHeight,
            child: searchBox,
          ),
          // Filter row: stays pinned directly below search box
          Positioned(
            top: currentTop + _searchHeight,
            left: 0,
            right: 0,
            height: _filterHeight,
            child: filterRow,
          ),
          // Subtle border divider when collapsed
          if (borderAlpha > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 1,
                color: theme.colorScheme.border.withValues(alpha: borderAlpha),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.titleRow != titleRow ||
        oldDelegate.searchBox != searchBox ||
        oldDelegate.filterRow != filterRow ||
        oldDelegate.theme != theme;
  }
}
