import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../study/widgets/card_action_sheet.dart';
import '../study/widgets/rich_card_content.dart';

class CardBrowserScreen extends HookConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final browserState = ref.watch(cardBrowserProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);
    final decks = ref.watch(deckListProvider);
    final deckMap = {for (final d in decks) d.id: d.title};

    final searchController = useTextEditingController(
      text: browserState.searchQuery,
    );
    final filteredCards = browserState.filteredCards;

    // Desktop selected card ID state
    final selectedCardId = useState<String?>(null);

    // Auto-select first card if selection is invalid or null on desktop
    if (filteredCards.isNotEmpty &&
        (selectedCardId.value == null ||
            !filteredCards.any((c) => c.id == selectedCardId.value))) {
      selectedCardId.value = filteredCards.first.id;
    } else if (filteredCards.isEmpty) {
      selectedCardId.value = null;
    }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          final currentSelectedCard =
              filteredCards.cast<CardModel?>().firstWhere(
                    (c) => c?.id == selectedCardId.value,
                    orElse: () =>
                        filteredCards.isNotEmpty ? filteredCards.first : null,
                  );

          return Scaffold(
            child: Row(
              children: [
                // Left Column: Search, Filters & Card Table (Width: 420px)
                SizedBox(
                  width: 420,
                  child: Column(
                    children: [
                      // Desktop Search Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: SizedBox(
                          height: 38,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  placeholder: Text(l10n.searchCardsPlaceholder),
                                  onChanged: (val) =>
                                      browserNotifier.setSearchQuery(val),
                                  features: [
                                    InputFeature.leading(
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 6),
                                        child: Icon(
                                          LucideIcons.search,
                                          size: 16,
                                          color:
                                              theme.colorScheme.mutedForeground,
                                        ),
                                      ),
                                    ),
                                    if (browserState.searchQuery.isNotEmpty)
                                      InputFeature.trailing(
                                        IconButton.ghost(
                                          size: ButtonSize.small,
                                          icon:
                                              const Icon(LucideIcons.x, size: 14),
                                          onPressed: () {
                                            searchController.clear();
                                            browserNotifier.setSearchQuery('');
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              PrimaryButton(
                                leading: const Icon(LucideIcons.plus, size: 16),
                                child: Text(l10n.addCardButton, maxLines: 1, softWrap: false),
                                onPressed: () => context.push('/editor'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            _FilterChip(
                              label:
                                  '${l10n.filterAll} • ${browserState.allCards.length}',
                              isSelected:
                                  browserState.filterType == CardFilterType.all,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.all),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: l10n.filterDue,
                              isSelected:
                                  browserState.filterType == CardFilterType.due,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.due),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: l10n.filterNew,
                              isSelected: browserState.filterType ==
                                  CardFilterType.newCard,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.newCard),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: l10n.filterFlagged,
                              isSelected: browserState.filterType ==
                                  CardFilterType.flagged,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.flagged),
                            ),
                            const SizedBox(width: 6),
                            _FilterChip(
                              label: l10n.filterSuspended,
                              isSelected: browserState.filterType ==
                                  CardFilterType.suspended,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.suspended),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 12),

                      // Cards List
                      Expanded(
                        child: filteredCards.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.noCardsFound,
                                  style: theme.typography.small.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredCards.length,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                itemBuilder: (context, index) {
                                  final card = filteredCards[index];
                                  final isSelected =
                                      card.id == selectedCardId.value;

                                  return _DesktopCardRowItem(
                                    card: card,
                                    isSelected: isSelected,
                                    onTap: () => selectedCardId.value = card.id,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const VerticalDivider(width: 1),

                // Right Column: Instant Live Preview & Actions Panel
                Expanded(
                  child: filteredCards.isEmpty || currentSelectedCard == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.mousePointerClick,
                                size: 48,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.selectCardToViewDetails,
                                style: theme.typography.xSmall.copyWith(
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _DesktopCardDetailPane(
                          card: currentSelectedCard,
                          deckTitle: deckMap[currentSelectedCard.deckId] ??
                              currentSelectedCard.deckId,
                          browserNotifier: browserNotifier,
                        ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout (< 900px): Preserves NestedScrollView with Bottom Sheet
        return Scaffold(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
                if (displayedCount.value < filteredCards.length) {
                  displayedCount.value =
                      (displayedCount.value + pageSize).clamp(
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
                          onChanged: (val) =>
                              browserNotifier.setSearchQuery(val),
                          features: [
                            InputFeature.leading(
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 4, right: 6),
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
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.all),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: l10n.filterDue,
                              isSelected:
                                  browserState.filterType == CardFilterType.due,
                              onTap: () => browserNotifier
                                  .setFilterType(CardFilterType.due),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: l10n.filterNew,
                              isSelected: browserState.filterType ==
                                  CardFilterType.newCard,
                              onTap: () => browserNotifier.setFilterType(
                                CardFilterType.newCard,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: l10n.filterFlagged,
                              isSelected: browserState.filterType ==
                                  CardFilterType.flagged,
                              onTap: () => browserNotifier.setFilterType(
                                CardFilterType.flagged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: l10n.filterSuspended,
                              isSelected: browserState.filterType ==
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
                      itemCount: visibleCount + (hasMore ? 1 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        if (index == visibleCount) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: OutlineButton(
                                size: ButtonSize.small,
                                child: Text(l10n.more),
                                onPressed: () {
                                  displayedCount.value =
                                      (displayedCount.value + pageSize).clamp(
                                    0,
                                    filteredCards.length,
                                  );
                                },
                              ),
                            ),
                          );
                        }

                        final card = filteredCards[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            filled: true,
                            padding: EdgeInsets.zero,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => openCardDetail(card),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (card.hasFlag) ...[
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                              top: 5, right: 10),
                                          decoration: BoxDecoration(
                                            color:
                                                CardActionSheet.ankiFlagColors[
                                                        card.flag] ??
                                                    m.Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _stripHtml(card.front),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: theme
                                                    .colorScheme.foreground,
                                                decoration: card.isSuspended
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _stripHtml(card.back),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.colorScheme
                                                    .mutedForeground,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  l10n.deckPrefix(
                                                      deckMap[card.deckId] ??
                                                          card.deckId),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: theme.colorScheme
                                                        .mutedForeground,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  card.intervalDays > 0
                                                      ? l10n.intervalBadge(
                                                          card.intervalDays)
                                                      : l10n.newBadge,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: card.intervalDays > 0
                                                        ? theme
                                                            .colorScheme.primary
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
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop Master-Detail Row Item
// ---------------------------------------------------------------------------

class _DesktopCardRowItem extends StatelessWidget {
  final CardModel card;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopCardRowItem({
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
          color:
              isSelected ? theme.colorScheme.primary : theme.colorScheme.border,
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
                          color: CardActionSheet.ankiFlagColors[card.flag] ??
                              m.Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _stripHtml(card.front),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
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
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: m.Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.filterSuspended,
                          style: const TextStyle(
                              fontSize: 9,
                              color: m.Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _stripHtml(card.back),
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

// ---------------------------------------------------------------------------
// Desktop Card Detail & Live Preview Pane
// ---------------------------------------------------------------------------

class _DesktopCardDetailPane extends HookWidget {
  final CardModel card;
  final String? deckTitle;
  final CardBrowserNotifier browserNotifier;

  const _DesktopCardDetailPane({
    required this.card,
    this.deckTitle,
    required this.browserNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final showAnswer = useState(false);
    final userTypedAnswer = useState('');

    useEffect(() {
      showAnswer.value = false;
      userTypedAnswer.value = '';
      return null;
    }, [card.id]);

    return Column(
      children: [
        // Top Action Bar for Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  deckTitle ?? card.deckId,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              if (card.noteType == NoteType.cloze)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l10n.clozeDeletion,
                      style:
                          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),

              const Spacer(),

              // Quick Actions
              OutlineButton(
                size: ButtonSize.small,
                leading: Icon(
                  card.isSuspended ? LucideIcons.play : LucideIcons.pause,
                  size: 14,
                ),
                child: Text(
                    card.isSuspended ? l10n.unsuspendCard : l10n.suspendCard),
                onPressed: () => browserNotifier.toggleCardSuspend(card.id),
              ),
              const SizedBox(width: 8),
              DestructiveButton(
                size: ButtonSize.small,
                leading: const Icon(LucideIcons.trash2, size: 14),
                child: Text(l10n.delete),
                onPressed: () => browserNotifier.deleteCard(card.id),
              ),
            ],
          ),
        ),

        // Scrollable Card Content Preview
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Front Label
                    Row(
                      children: [
                        const Icon(LucideIcons.fileQuestion, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.frontSide,
                          style: theme.typography.xSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        GhostButton(
                          size: ButtonSize.small,
                          leading: Icon(
                            showAnswer.value
                                ? LucideIcons.eyeOff
                                : LucideIcons.eye,
                            size: 14,
                          ),
                          child: Text(showAnswer.value
                              ? l10n.hideAnswer
                              : l10n.showAnswer),
                          onPressed: () => showAnswer.value = !showAnswer.value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SurfaceCard(
                      padding: const EdgeInsets.all(20),
                      child: RichCardContent(
                        content: card.front,
                        textAlign: TextAlign.left,
                        typedAnswer: userTypedAnswer.value,
                        onAnswerChanged: (v) => userTypedAnswer.value = v,
                        onSubmitAnswer: () => showAnswer.value = true,
                      ),
                    ),

                    if (!showAnswer.value) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: PrimaryButton(
                          leading: const Icon(LucideIcons.eye, size: 16),
                          child: Text(l10n.showAnswer),
                          onPressed: () => showAnswer.value = true,
                        ),
                      ),
                    ],

                    // Back Label & Content (Hidden until revealed or submitted)
                    if (showAnswer.value) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(LucideIcons.circleCheck, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            l10n.backSide,
                            style: theme.typography.xSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: RichCardContent(
                          content: card.back,
                          textAlign: TextAlign.left,
                          typedAnswer: userTypedAnswer.value,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // FSRS Metrics Grid
                    Text(
                      l10n.fsrsScheduleTitle,
                      style: theme.typography.xSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: l10n.stabilityLabel,
                            value: '${card.stability.toStringAsFixed(1)}d',
                            icon: LucideIcons.shieldCheck,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: l10n.difficultyLabel,
                            value: '${card.difficulty.toStringAsFixed(1)} / 10',
                            icon: LucideIcons.brain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: l10n.intervalLabel,
                            value: '${card.intervalDays}d',
                            icon: LucideIcons.calendar,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: l10n.repsAndLapsesLabel,
                            value: '${card.reps} / ${card.lapses}',
                            icon: LucideIcons.rotateCw,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10, color: theme.colorScheme.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
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
          color:
              isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
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
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            height: _searchHeight,
            child: searchBox,
          ),
          Positioned(
            top: currentTop + _searchHeight,
            left: 0,
            right: 0,
            height: _filterHeight,
            child: filterRow,
          ),
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

String _stripHtml(String text) {
  if (!text.contains('<')) return text;
  return text
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
