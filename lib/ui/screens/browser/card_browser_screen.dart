import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/models/card.dart';
import '../study/widgets/card_action_sheet.dart';

class CardBrowserScreen extends HookConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final browserState = ref.watch(cardBrowserProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);

    final searchController = useTextEditingController(text: browserState.searchQuery);
    final filteredCards = browserState.filteredCards;

    void openCardDetail(CardModel card) {
      m.showModalBottomSheet(
        context: context,
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return m.Material(
            type: m.MaterialType.transparency,
            child: CardActionSheet(
              card: card,
              onSetFlag: (flag) => browserNotifier.setCardFlag(card.id, flag),
              onBury: () {},
              onSuspend: () => browserNotifier.toggleCardSuspend(card.id),
              onEdit: (f, b) {
                browserNotifier.updateCard(card.copyWith(front: f, back: b));
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Trình Duyệt Thẻ (Browser)'),
          trailing: [
            PrimaryButton(
              onPressed: () => context.push('/editor'),
              leading: const Icon(m.Icons.add, size: 16),
              child: const Text('Thêm thẻ'),
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Card(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(m.Icons.search_rounded, size: 18, color: theme.colorScheme.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      placeholder: const Text('Tìm câu hỏi, đáp án, #tag...'),
                      onChanged: (val) => browserNotifier.setSearchQuery(val),
                    ),
                  ),
                  if (browserState.searchQuery.isNotEmpty)
                    IconButton.ghost(
                      icon: const Icon(m.Icons.clear, size: 16),
                      onPressed: () {
                        searchController.clear();
                        browserNotifier.setSearchQuery('');
                      },
                    ),
                ],
              ),
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả (${browserState.allCards.length})',
                  isSelected: browserState.filterType == CardFilterType.all,
                  onTap: () => browserNotifier.setFilterType(CardFilterType.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cần ôn (Due)',
                  isSelected: browserState.filterType == CardFilterType.due,
                  onTap: () => browserNotifier.setFilterType(CardFilterType.due),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Thẻ mới (New)',
                  isSelected: browserState.filterType == CardFilterType.newCard,
                  onTap: () => browserNotifier.setFilterType(CardFilterType.newCard),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Có cờ (Flagged)',
                  isSelected: browserState.filterType == CardFilterType.flagged,
                  onTap: () => browserNotifier.setFilterType(CardFilterType.flagged),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Đã tạm dừng (Suspended)',
                  isSelected: browserState.filterType == CardFilterType.suspended,
                  onTap: () => browserNotifier.setFilterType(CardFilterType.suspended),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Cards list
          Expanded(
            child: filteredCards.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(m.Icons.inbox_outlined, size: 48, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 12),
                        Text(
                          'Không có thẻ nào phù hợp',
                          style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: filteredCards.length,
                    itemBuilder: (context, index) {
                      final card = filteredCards[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GestureDetector(
                          onTap: () => openCardDetail(card),
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
                                        ? CardActionSheet.ankiFlagColors[card.flag - 1]
                                        : (card.isSuspended
                                            ? m.Colors.grey
                                            : theme.colorScheme.border),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              card.front,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.typography.semiBold.copyWith(
                                                decoration: card.isSuspended
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          if (card.noteType == 'cloze')
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text('Cloze', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        card.back,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.typography.xSmall.copyWith(
                                          color: theme.colorScheme.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'Deck: ${card.deckId}',
                                            style: TextStyle(fontSize: 10, color: theme.colorScheme.mutedForeground),
                                          ),
                                          const Spacer(),
                                          Text(
                                            card.intervalDays > 0
                                                ? '${card.intervalDays}d interval'
                                                : 'New',
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
                      );
                    },
                  ),
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
