import '../../../core/sync/anki_web_sync_service.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../../core/importer/apkg_importer_service.dart';
import '../../../core/notifiers/card_browser_notifier.dart';

import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/stats_notifier.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/models/deck.dart';
import '../../../core/storage/database_service.dart';
import '../../widgets/sync_conflict_dialog.dart';
import '../../widgets/sync_progress_toast.dart';
import '../auth/anki_web_auth_sheet.dart';
import 'widgets/custom_study_modal.dart';
import 'widgets/create_deck_modal.dart';

class DecksScreen extends HookConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final stats = ref.watch(statsNotifierProvider);
    final studySettings = ref.watch(studySettingsProvider);
    final l10n = context.l10n;

    // Hooks: Search query and filter state
    final searchQuery = useState('');
    final isSyncing = useState(false);
    final isDialOpen = useState(false);

    useEffect(() {
      Future.microtask(() {
        deckNotifier.refresh();
        ref.read(statsNotifierProvider.notifier).refresh();
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

    Future<void> handleSyncTap() async {
      if (!authState.isAuthenticated || authState.hostKey == null) {
        final loggedIn = await AnkiWebAuthSheet.show(context);
        if (loggedIn != true) return;
      }

      isSyncing.value = true;
      final syncService = AnkiWebSyncService(
        messages: SyncProgressMessages.fromL10n(l10n),
      );

      final lastSyncTime = authState.lastSyncedAt;
      final hasLocalChanges = DatabaseService.instance.hasLocalChangesSince(lastSyncTime);

      final check = await syncService.checkSyncStatus(
        hostKey: authState.hostKey!,
        lastSyncTime: lastSyncTime,
        hasLocalChanges: hasLocalChanges,
      );

      SyncConflictChoice? choice;
      if (check.action == SyncActionRequired.conflict) {
        if (!context.mounted) {
          isSyncing.value = false;
          return;
        }
        choice = await SyncConflictDialog.show(
          context,
          localLastSync: check.localLastSync,
          serverMod: check.serverMod,
        );
        if (choice == null) {
          isSyncing.value = false;
          return;
        }
      }

      final shouldUpload = choice == SyncConflictChoice.upload ||
          (choice == null && check.action == SyncActionRequired.upload);

      final statusNotifier = ValueNotifier<SyncProgressStatus>(
        SyncProgressStatus(
          title: l10n.syncAnkiWeb,
          message: shouldUpload
              ? l10n.preparingUpload
              : l10n.connectingToAnkiWeb,
          progress: 0.05,
        ),
      );

      ToastOverlay? toastOverlay;
      if (context.mounted) {
        toastOverlay = SyncProgressToast.show(
          context: context,
          statusNotifier: statusNotifier,
        );
      }

      try {
        final AnkiWebSyncResult syncResult;
        if (shouldUpload) {
          final dbBytes = await DatabaseService.instance.exportToAnki2Db();
          syncResult = await syncService.uploadCollection(
            hostKey: authState.hostKey!,
            dbBytes: dbBytes,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: progress,
              );
            },
          );
        } else {
          syncResult = await syncService.syncCollection(
            hostKey: authState.hostKey!,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: progress,
              );
            },
          );
        }

        if (context.mounted) {
          if (syncResult.success) {
            ref.read(authNotifierProvider.notifier).recordSyncSuccess();

            if (syncResult.decks.isNotEmpty) {
              await deckNotifier.addDecks(syncResult.decks);
            }
            if (syncResult.cards.isNotEmpty) {
              await ref
                  .read(cardBrowserProvider.notifier)
                  .addCards(syncResult.cards);
            }
            await deckNotifier.refresh();

            statusNotifier.value = SyncProgressStatus(
              title: l10n.syncCompleted,
              message: syncResult.message,
              progress: 1.0,
              isCompleted: true,
            );
            Future.delayed(const Duration(seconds: 4), () {
              toastOverlay?.close();
            });
          } else {
            statusNotifier.value = SyncProgressStatus(
              title: l10n.syncFailed,
              message: syncResult.message,
              progress: 1.0,
              isError: true,
            );
            Future.delayed(const Duration(seconds: 5), () {
              toastOverlay?.close();
            });
          }
        }
      } catch (e) {
        statusNotifier.value = SyncProgressStatus(
          title: l10n.syncError,
          message: e.toString(),
          progress: 1.0,
          isError: true,
        );
        Future.delayed(const Duration(seconds: 5), () {
          toastOverlay?.close();
        });
      } finally {
        isSyncing.value = false;
      }
    }

    Future<void> handleApkgImport() async {
      try {
        final result = await FilePicker.pickFiles(
          type: FileType.any,
          withData: true,
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

        final fileBytes =
            selectedFile.bytes ??
            (selectedFile.path != null
                ? File(selectedFile.path!).readAsBytesSync()
                : null);

        if (fileBytes == null) {
          throw const FormatException('File data unreadable');
        }

        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(
          fileBytes,
          defaultDeckDescription: l10n.importedDeckDefaultDesc,
        );

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

    void openCramModal() {
      m.showModalBottomSheet(
        context: context,
        useRootNavigator: false,
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return m.Material(
            type: m.MaterialType.transparency,
            child: CustomStudyModal(
              onStartCram: (name, tag, limit, mode) {
                deckNotifier.createCramDeck(
                  name: name,
                  filterTag: tag,
                  cardLimit: limit,
                  mode: mode,
                  description: l10n.cramDeckDefaultDesc,
                );
                showToast(
                  context: context,
                  builder: (context, overlay) {
                    return SurfaceCard(
                      child: Basic(
                        title: Text(l10n.cramDeckCreated),
                        subtitle: Text(l10n.cramDeckCreatedDesc(limit, tag)),
                        leading: const Icon(
                          LucideIcons.zap,
                          color: m.Colors.amber,
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
            ),
          );
        },
      );
    }

    void openCreateDeckModal() {
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

    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            children: [
              const Icon(LucideIcons.zap, size: 20),
              const SizedBox(width: 8),
              Text(
                'Flanki',
                style: theme.typography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  studySettings.fsrsEnabled ? 'FSRS v5' : 'SM-2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          trailing: [
            // AnkiWeb sync button
            GhostButton(
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
                      color: authState.isAuthenticated ? m.Colors.green : null,
                    ),
              child: Text(
                authState.isAuthenticated ? l10n.linkedBadge : l10n.syncBadge,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ],
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Daily Goal & Streak Hero Card
                  Card(
                    filled: true,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.flame,
                                  color: m.Colors.deepOrange,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.streakDaysBadge(stats.streakDays),
                                  style: theme.typography.h4.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              l10n.targetRetentionBadge(
                                '${(studySettings.desiredRetention * 100).toInt()}%',
                              ),
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.foreground.withValues(
                                  alpha: 0.65,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatMiniBox(
                                label: l10n.dueCards,
                                value: '$totalDue',
                                color: totalDue > 0
                                    ? theme.colorScheme.destructive
                                    : theme.colorScheme.foreground,
                                icon: LucideIcons.clock,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatMiniBox(
                                label: l10n.newCards,
                                value: '$totalNew',
                                color: theme.colorScheme.primary,
                                icon: LucideIcons.sparkles,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar + Desktop Toolbar
                  SizedBox(
                    height: 38,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: TextField(
                            features: [
                              InputFeature.leading(
                                Icon(
                                  LucideIcons.search,
                                  size: 18,
                                  color: theme.colorScheme.mutedForeground,
                                ),
                              ),
                            ],
                            placeholder: Text(l10n.searchDecks),
                            onChanged: (val) => searchQuery.value = val,
                          ),
                        ),
                        if (MediaQuery.sizeOf(context).width >= 768) ...[
                          const SizedBox(width: 12),
                          PrimaryButton(
                            leading: const Icon(LucideIcons.plus, size: 16),
                            onPressed: openCreateDeckModal,
                            child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          OutlineButton(
                            leading: const Icon(LucideIcons.fileUp, size: 16),
                            onPressed: handleApkgImport,
                            child: Text(l10n.importApkg, maxLines: 1, softWrap: false),
                          ),
                          const SizedBox(width: 8),
                          GhostButton(
                            leading: const Icon(LucideIcons.zap, size: 16),
                            onPressed: openCramModal,
                            child: Text(l10n.customStudy, maxLines: 1, softWrap: false),
                          ),
                        ],
                      ],
                    ),
                  ),
              const SizedBox(height: 20),

              // Header Section: clean title & total count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.navDecks} (${filteredDecks.length})',
                    style: theme.typography.semiBold,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Deck list
              if (filteredDecks.isEmpty)
                Padding(
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
                          onPressed: openCreateDeckModal,
                          leading: const Icon(LucideIcons.plus, size: 16),
                          child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // 1. Render Grouped Decks (e.g. from APKG imports with "Parent::Child" hierarchy)
                ...groupedMap.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GroupedDeckCard(
                      parentName: entry.key,
                      subdecks: entry.value,
                      autoExpand: searchQuery.value.isNotEmpty,
                      onStudyDeck: (deckId) {
                        context.push('/decks/$deckId/study');
                      },
                    ),
                  );
                }),

                // 2. Render Standalone Decks
                ...standaloneDecks.map((deck) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MobileDeckCard(
                      deckId: deck.id,
                      title: deck.title,
                      description: deck.description,
                      dueCount: deck.dueCount,
                      newCount: deck.newCount,
                      totalCount: deck.totalCount,
                      onStudy: () {
                        context.push('/decks/${deck.id}/study');
                      },
                    ),
                  );
                }),
              ],
              const SizedBox(
                height: 120,
              ), // Space for bottom navigation bar and floating speed dial
            ],
          ),
        ),
      ),

          // Scrim backdrop when speed dial is open (mobile only)
          if (isDialOpen.value && MediaQuery.sizeOf(context).width < 768)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => isDialOpen.value = false,
                child: Container(color: m.Colors.black.withValues(alpha: 0.35)),
              ),
            ),

          // Floating Speed Dial Button (mobile only)
          if (MediaQuery.sizeOf(context).width < 768)
            Positioned(
              bottom: 24,
              right: 20,
              child: _DeckSpeedDial(
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
  }
}

class _StatMiniBox extends StatelessWidget {
  final String label;
  final String value;
  final m.Color color;
  final IconData icon;

  const _StatMiniBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileDeckCard extends StatelessWidget {
  final String deckId;
  final String title;
  final String description;
  final int dueCount;
  final int newCount;
  final int totalCount;
  final VoidCallback onStudy;

  const _MobileDeckCard({
    required this.deckId,
    required this.title,
    required this.description,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse Hierarchical deck title (Parent::Child)
    final parts = title.split('::');
    final hasHierarchy = parts.length > 1;
    final parentPath = hasHierarchy
        ? parts.sublist(0, parts.length - 1).join(' › ')
        : null;
    final leafName = parts.last;
    final isCram = title.contains('Cram');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStudy,
      child: Card(
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
                    color: isCram
                        ? m.Colors.amber.withValues(alpha: 0.15)
                        : theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCram ? LucideIcons.zap : LucideIcons.folder,
                    size: 20,
                    color: isCram
                        ? m.Colors.amber
                        : theme.colorScheme.foreground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parentPath != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            parentPath,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ),
                      Text(
                        leafName,
                        style: theme.typography.h4.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (dueCount > 0)
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
                            '$dueCount ${context.l10n.dueCards}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.destructive,
                            ),
                          ),
                        ),
                      if (newCount > 0)
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
                            '$newCount ${context.l10n.newCards}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      Text(
                        context.l10n.cardsCount(totalCount),
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
                  onPressed: onStudy,
                  size: ButtonSize.small,
                  leading: const Center(child: Icon(LucideIcons.play, size: 14)),
                  child: Center(child: Text(context.l10n.studyNow)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupedDeckCard extends HookWidget {
  final String parentName;
  final List<DeckModel> subdecks;
  final bool autoExpand;
  final void Function(String deckId) onStudyDeck;

  const _GroupedDeckCard({
    required this.parentName,
    required this.subdecks,
    required this.autoExpand,
    required this.onStudyDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
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
          GestureDetector(
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
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
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
                                  color: theme.colorScheme.destructive
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$totalDue ${context.l10n.dueCards}',
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
                                  '$totalNew ${context.l10n.newCards}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            Text(
                              context.l10n.cardsCount(totalCards),
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
                        leading: const Center(child: Icon(LucideIcons.play, size: 14)),
                        child: Center(child: Text(context.l10n.studyNow)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded.value) ...[
            Divider(height: 1, color: theme.colorScheme.border),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.muted.withValues(alpha: 0.25),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: subdecks.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 44,
                  endIndent: 16,
                  color: theme.colorScheme.border.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final deck = subdecks[index];
                  final leafName = deck.title.split('::').last;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onStudyDeck(deck.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 16,
                            color: theme.colorScheme.mutedForeground,
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
                                    color: theme.colorScheme.destructive
                                        .withValues(alpha: 0.15),
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
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
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
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeckSpeedDial extends HookWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateDeck;
  final VoidCallback onImportApkg;
  final VoidCallback onCram;

  const _DeckSpeedDial({
    required this.isOpen,
    required this.onToggle,
    required this.onCreateDeck,
    required this.onImportApkg,
    required this.onCram,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    useEffect(() {
      if (isOpen) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [isOpen]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen || controller.value > 0)
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final p = controller.value;
              return Opacity(
                opacity: p.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - p)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _SpeedDialOption(
                        icon: LucideIcons.folderPlus,
                        iconColor: m.Colors.green,
                        label: l10n.createDeckAction,
                        onTap: onCreateDeck,
                      ),
                      const SizedBox(height: 12),
                      _SpeedDialOption(
                        icon: LucideIcons.upload,
                        iconColor: m.Colors.blue,
                        label: l10n.importApkgAction,
                        onTap: onImportApkg,
                      ),
                      const SizedBox(height: 12),
                      _SpeedDialOption(
                        icon: LucideIcons.zap,
                        iconColor: m.Colors.amber,
                        label: l10n.cramAction,
                        onTap: onCram,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedRotation(
                turns: isOpen ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  LucideIcons.plus,
                  color: theme.colorScheme.primaryForeground,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedDialOption extends StatelessWidget {
  final IconData icon;
  final m.Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SpeedDialOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: m.Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.cardForeground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: m.Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
        ],
      ),
    );
  }
}
