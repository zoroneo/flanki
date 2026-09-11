import 'dart:math' as math;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/notifiers/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../study/widgets/card_action_sheet.dart';
import 'widgets/browser_desktop_layout.dart';
import 'widgets/browser_mobile_layout.dart';

class CardBrowserScreen extends HookConsumerWidget {
  const CardBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final filteredCards = ref.watch(
      cardBrowserProvider.select((s) => s.filteredCards),
    );
    final filterType = ref.watch(
      cardBrowserProvider.select((s) => s.filterType),
    );
    final searchQuery = ref.watch(
      cardBrowserProvider.select((s) => s.searchQuery),
    );
    final selectedDeckId = ref.watch(
      cardBrowserProvider.select((s) => s.selectedDeckId),
    );
    final browserNotifier = ref.read(cardBrowserProvider.notifier);
    final decks = ref.watch(deckListProvider);
    final deckMap = {for (final d in decks) d.id: d.title};

    final searchController = useTextEditingController(text: searchQuery);

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

    useEffect(() {
      displayedCount.value = pageSize;
      return null;
    }, [searchQuery, filterType, selectedDeckId]);

    final visibleCount = math.min(displayedCount.value, filteredCards.length);
    final hasMore = visibleCount < filteredCards.length;

    void openCardDetail(CardModel card) {
      CardActionSheet.show(
        context,
        card: card,
        onSetFlag: (flag) => browserNotifier.setCardFlag(card.id, flag),
        onBury: () => browserNotifier.toggleCardBury(card.id),
        onSuspend: () => browserNotifier.toggleCardSuspend(card.id),
        onDelete: () => browserNotifier.deleteCard(card.id),
        onEdit: (f, b) {
          browserNotifier.updateCard(card.copyWith(front: f, back: b));
        },
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return ScreenTypeLayout.builder(
      desktop: (context) => BrowserDesktopLayout(
        theme: theme,
        l10n: l10n,
        filterType: filterType,
        browserNotifier: browserNotifier,
        decks: decks,
        deckMap: deckMap,
        filteredCards: filteredCards,
        selectedCardId: selectedCardId,
        searchController: searchController,
      ),
      mobile: (context) => BrowserMobileLayout(
        theme: theme,
        l10n: l10n,
        filterType: filterType,
        browserNotifier: browserNotifier,
        decks: decks,
        deckMap: deckMap,
        filteredCards: filteredCards,
        searchController: searchController,
        topPadding: topPadding,
        visibleCount: visibleCount,
        hasMore: hasMore,
        displayedCount: displayedCount,
        openCardDetail: openCardDetail,
      ),
    );
  }
}
