import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/notifiers/locale_notifier.dart';
import '../../../core/models/deck.dart';
import '../providers/deck_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import '../../stats/providers/stats_notifier.dart';
import '../../sync/ui/sync_flow_coordinator.dart';
import 'widgets/create_deck_modal.dart';
import 'widgets/custom_study_modal.dart';
import 'widgets/deck_app_bar.dart';
import 'widgets/deck_empty_state.dart';
import 'widgets/deck_import_helper.dart';
import 'widgets/deck_slivers.dart';
import 'widgets/deck_speed_dial.dart';
import 'widgets/deck_stats_bar.dart';
import 'widgets/deck_toolbar.dart';

class DecksScreen extends HookConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final l10n = context.l10n;

    final searchQuery = useState('');
    final isSyncing = useState(false);
    final isDialOpen = useState(false);

    useEffect(() {
      Future.microtask(() {
        if (!context.mounted) return;
        deckNotifier.refresh();
        ref.read(statsNotifierProvider.notifier).refresh();
        SyncFlowCoordinator.runAutoSync(context: context, ref: ref, l10n: l10n);
      });
      return null;
    }, const []);

    final filteredDecks = decks.where((d) {
      if (searchQuery.value.isEmpty) return true;
      return d.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          d.description.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    // Filter unique decks by title to avoid duplicates in UI
    final Map<String, DeckModel> uniqueTitleDecks = {};
    for (final d in filteredDecks) {
      final key = d.title.trim().toLowerCase();
      if (!uniqueTitleDecks.containsKey(key) ||
          (d.totalCount > (uniqueTitleDecks[key]?.totalCount ?? 0))) {
        uniqueTitleDecks[key] = d;
      }
    }
    final deduplicatedFilteredDecks = uniqueTitleDecks.values.toList();

    // Group hierarchical decks (e.g. "Parent::Child")
    final Map<String, List<DeckModel>> groupedMap = {};
    final List<DeckModel> standaloneDecks = [];

    for (final deck in deduplicatedFilteredDecks) {
      if (deck.title.contains('::')) {
        final parts = deck.title.split('::');
        final parentName = parts.sublist(0, parts.length - 1).join(' › ');
        groupedMap.putIfAbsent(parentName, () => []).add(deck);
      } else {
        standaloneDecks.add(deck);
      }
    }

    for (final parent in groupedMap.keys) {
      standaloneDecks.removeWhere((d) => d.title == parent);
    }

    final totalDue = decks.fold<int>(0, (sum, d) => sum + d.dueCount);
    final totalNew = decks.fold<int>(0, (sum, d) => sum + d.newCount);
    final groupedEntries = groupedMap.entries.toList(growable: false);

    Future<void> handleSyncTap() async {
      await SyncFlowCoordinator.runSyncFlow(
        context: context,
        ref: ref,
        l10n: l10n,
        isSyncing: isSyncing,
      );
    }

    Future<void> handleApkgImport() async {
      await DeckImportHelper.executeApkgImport(
        context: context,
        ref: ref,
        deckNotifier: deckNotifier,
        l10n: l10n,
      );
    }

    void openCramModal() => _showCramModal(context, deckNotifier, l10n);
    void openCreateDeckModal() =>
        _showCreateDeckModal(context, decks, deckNotifier, l10n);

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          headers: [
            DeckAppBar(isSyncing: isSyncing, onSync: handleSyncTap, l10n: l10n),
          ],
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer(
                                builder: (context, ref, _) {
                                  final streakDays = ref.watch(
                                    statsNotifierProvider.select(
                                      (s) => s.streakDays,
                                    ),
                                  );
                                  final desiredRetention = ref.watch(
                                    studySettingsProvider.select(
                                      (s) => s.desiredRetention,
                                    ),
                                  );
                                  return DeckStatsBar(
                                    totalDue: totalDue,
                                    totalNew: totalNew,
                                    streakDays: streakDays,
                                    desiredRetention: desiredRetention,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              DeckToolbar(
                                isMobile: isMobile,
                                searchQuery: searchQuery,
                                onAddDeck: openCreateDeckModal,
                                onImportApkg: handleApkgImport,
                                onCustomStudy: openCramModal,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '${l10n.navDecks} (${filteredDecks.length})',
                                style: theme.typography.semiBold,
                              ),
                              const SizedBox(height: 12),
                              if (filteredDecks.isEmpty)
                                DeckEmptyState(
                                  l10n: l10n,
                                  onAddDeck: openCreateDeckModal,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (filteredDecks.isNotEmpty)
                        ...DeckSlivers.buildList(
                          context: context,
                          groupedEntries: groupedEntries,
                          standaloneDecks: standaloneDecks,
                          searchQuery: searchQuery.value,
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
              ),
              if (isDialOpen.value && isMobile)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => isDialOpen.value = false,
                    child: Container(
                      color: m.Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              if (isMobile)
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: DeckSpeedDial(
                    isOpen: isDialOpen.value,
                    onToggle: () => isDialOpen.value = !isDialOpen.value,
                    onCreateDeck: () {
                      isDialOpen.value = false;
                      openCreateDeckModal();
                    },
                    onImportApkg: () {
                      isDialOpen.value = false;
                      handleApkgImport();
                    },
                    onCram: () {
                      isDialOpen.value = false;
                      openCramModal();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCramModal(
    BuildContext context,
    DeckNotifier deckNotifier,
    dynamic l10n,
  ) {
    CustomStudyModal.show(
      context,
      onStartCram: (name, tag, limit, mode) {
        final customTitle = tag.isNotEmpty
            ? l10n.cramDeckTitleWithTag(name, tag)
            : l10n.cramDeckTitlePrefix(name);

        deckNotifier.createCramDeck(
          name: name,
          filterTag: tag,
          cardLimit: limit,
          mode: mode,
          title: customTitle,
          description: l10n.cramDeckDefaultDesc,
        );
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.cramDeckCreated),
                subtitle: Text(l10n.cramDeckCreatedDesc(limit, tag)),
                leading: const Icon(LucideIcons.zap, color: m.Colors.amber),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateDeckModal(
    BuildContext context,
    List<DeckModel> decks,
    DeckNotifier deckNotifier,
    dynamic l10n,
  ) {
    CreateDeckModal.show(
      context,
      existingDeckNames: decks.map((d) => d.title).toList(),
      onCreateDeck: (name, description) {
        final newDeck = DeckModel(
          id: 'deck_${DateTime.now().millisecondsSinceEpoch}',
          title: name,
          description: description,
          dueCount: 0,
          newCount: 0,
          totalCount: 0,
          lastStudied: null,
        );
        deckNotifier.addDeck(newDeck);
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.deckCreatedSuccess),
                subtitle: Text(l10n.deckCreatedSuccessDesc(name)),
                leading: const Icon(
                  LucideIcons.circleCheck,
                  color: m.Colors.green,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
