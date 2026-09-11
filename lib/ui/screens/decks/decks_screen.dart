import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/importer/apkg_importer_service.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/deck.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/stats_notifier.dart';
import '../../widgets/sync_flow_coordinator.dart';
import 'widgets/create_deck_modal.dart';
import 'widgets/custom_study_modal.dart';
import 'widgets/deck_card.dart';
import 'widgets/deck_speed_dial.dart';
import 'widgets/deck_stats_bar.dart';
import 'widgets/deck_toolbar.dart';
import 'widgets/grouped_deck_card.dart';

class DecksScreen extends HookConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final l10n = context.l10n;

    // Hooks: Search query and filter state
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

    // Group hierarchical decks (e.g. "Parent::Child" from .apkg imports)
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
      await _executeApkgImport(context, ref, deckNotifier, l10n);
    }

    void openCramModal() {
      _showCramModal(context, deckNotifier, l10n);
    }

    void openCreateDeckModal() {
      _showCreateDeckModal(context, decks, deckNotifier, l10n);
    }

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          headers: [_buildAppBar(theme, isSyncing, handleSyncTap, l10n)],
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
                              _buildHeaderSection(
                                theme,
                                l10n,
                                filteredDecks.length,
                              ),
                              const SizedBox(height: 12),
                              if (filteredDecks.isEmpty)
                                _buildEmptyState(
                                  theme,
                                  l10n,
                                  openCreateDeckModal,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (filteredDecks.isNotEmpty)
                        ..._buildDeckSlivers(
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
                _buildFloatingSpeedDial(
                  isDialOpen: isDialOpen,
                  openCreateDeckModal: openCreateDeckModal,
                  handleApkgImport: handleApkgImport,
                  openCramModal: openCramModal,
                ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    ThemeData theme,
    ValueNotifier<bool> isSyncing,
    Future<void> Function() handleSyncTap,
    dynamic l10n,
  ) {
    return AppBar(
      title: Row(
        children: [
          const Icon(LucideIcons.zap, size: 20),
          const SizedBox(width: 8),
          Text(
            'Flanki',
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              final fsrsEnabled = ref.watch(
                studySettingsProvider.select((s) => s.fsrsEnabled),
              );
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fsrsEnabled ? 'FSRS v5' : 'SM-2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      trailing: [
        Consumer(
          builder: (context, ref, _) {
            final isAuthenticated = ref.watch(
              authNotifierProvider.select((s) => s.isAuthenticated),
            );
            return GhostButton(
              onPressed: isSyncing.value ? null : handleSyncTap,
              leading: isSyncing.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      LucideIcons.cloud,
                      size: 16,
                      color: isAuthenticated ? m.Colors.green : null,
                    ),
              child: Text(
                isAuthenticated ? l10n.linkedBadge : l10n.syncBadge,
                maxLines: 1,
                softWrap: false,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderSection(ThemeData theme, dynamic l10n, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${l10n.navDecks} ($count)', style: theme.typography.semiBold),
      ],
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    dynamic l10n,
    VoidCallback openCreateDeckModal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDecksFound,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              alignment: Alignment.center,
              onPressed: openCreateDeckModal,
              leading: const Icon(LucideIcons.plus, size: 16),
              child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDeckSlivers({
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

  Widget _buildFloatingSpeedDial({
    required ValueNotifier<bool> isDialOpen,
    required VoidCallback openCreateDeckModal,
    required VoidCallback handleApkgImport,
    required VoidCallback openCramModal,
  }) {
    return Positioned(
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
    );
  }

  Future<void> _executeApkgImport(
    BuildContext context,
    WidgetRef ref,
    DeckNotifier deckNotifier,
    dynamic l10n,
  ) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      final selectedFile = result.files.first;
      final ext =
          (selectedFile.extension ??
                  (selectedFile.name.contains('.')
                      ? selectedFile.name.split('.').last
                      : ''))
              .toLowerCase();

      if (ext != 'apkg' && ext != 'zip' && ext != 'colpkg') {
        if (context.mounted) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: Text(l10n.importApkgError),
                  subtitle: Text(l10n.selectApkgOrZipPrompt),
                  leading: const Icon(
                    LucideIcons.circleAlert,
                    color: m.Colors.red,
                  ),
                  trailing: IconButton.ghost(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => overlay.close(),
                  ),
                ),
              );
            },
          );
        }
        return;
      }

      ToastOverlay? loadingToast;
      if (context.mounted) {
        loadingToast = showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkg),
                subtitle: Text(selectedFile.name),
                leading: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        );
      }

      final importer = ApkgImporterService();
      final ApkgImportResult importResult;

      try {
        if (selectedFile.path != null && selectedFile.path!.isNotEmpty) {
          importResult = await importer.importApkgPath(
            selectedFile.path!,
            defaultDeckDescription: l10n.importedDeckDefaultDesc,
          );
        } else if (selectedFile.bytes != null) {
          importResult = importer.importApkgBytes(
            selectedFile.bytes!,
            defaultDeckDescription: l10n.importedDeckDefaultDesc,
          );
        } else {
          throw const FormatException('File data unreadable');
        }
      } finally {
        loadingToast?.close();
      }

      if (importResult.decks.isNotEmpty) {
        deckNotifier.addDecks(importResult.decks);
      }
      if (importResult.cards.isNotEmpty) {
        ref.read(cardBrowserProvider.notifier).addCards(importResult.cards);
      }

      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgSuccess),
                subtitle: Text(
                  l10n.importApkgSuccessDesc(
                    importResult.decks.length,
                    importResult.cards.length,
                    importResult.mediaCount,
                  ),
                ),
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
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgError),
                subtitle: Text(e.toString()),
                leading: const Icon(
                  LucideIcons.circleAlert,
                  color: m.Colors.red,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      }
    }
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
