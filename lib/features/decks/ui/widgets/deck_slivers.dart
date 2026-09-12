import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/deck.dart';
import 'deck_card.dart';
import 'grouped_deck_card.dart';

class DeckSlivers extends StatelessWidget {
  final List<MapEntry<String, List<DeckModel>>> groupedEntries;
  final List<DeckModel> standaloneDecks;
  final String searchQuery;

  const DeckSlivers({
    super.key,
    required this.groupedEntries,
    required this.standaloneDecks,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Not used directly, helper creates list of slivers
  }

  static List<Widget> buildList({
    required BuildContext context,
    required List<MapEntry<String, List<DeckModel>>> groupedEntries,
    required List<DeckModel> standaloneDecks,
    required String searchQuery,
  }) {
    return [
      if (groupedEntries.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList.separated(
            itemCount: groupedEntries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = groupedEntries[index];
              return GroupedDeckCard(
                key: ValueKey('group_${entry.key}'),
                parentName: entry.key,
                subdecks: entry.value,
                autoExpand: searchQuery.isNotEmpty,
                onStudyDeck: (deckId) {
                  context.push('/decks/$deckId/study');
                },
              );
            },
          ),
        ),
      if (groupedEntries.isNotEmpty && standaloneDecks.isNotEmpty)
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      if (standaloneDecks.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList.separated(
            itemCount: standaloneDecks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final deck = standaloneDecks[index];
              return DeckCard(
                key: ValueKey('deck_${deck.id}'),
                deckId: deck.id,
                title: deck.title,
                description: deck.description,
                dueCount: deck.dueCount,
                newCount: deck.newCount,
                totalCount: deck.totalCount,
                onStudy: () {
                  context.push('/decks/${deck.id}/study');
                },
              );
            },
          ),
        ),
    ];
  }
}
