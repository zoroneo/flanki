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
import '../../../core/auth/auth_notifier.dart';
import 'widgets/custom_study_modal.dart';

class DecksScreen extends HookConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final l10n = context.l10n;

    // Hooks: Search query and filter state
    final searchQuery = useState('');
    final isSyncing = useState(false);

    final filteredDecks = decks.where((d) {
      if (searchQuery.value.isEmpty) return true;
      return d.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          d.description.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();

    final totalDue = decks.fold<int>(0, (sum, d) => sum + d.dueCount);
    final totalNew = decks.fold<int>(0, (sum, d) => sum + d.newCount);

    Future<void> handleSyncTap() async {
      if (!authState.isAuthenticated || authState.hostKey == null) {
        context.push('/auth');
        return;
      }

      isSyncing.value = true;
      final syncService = AnkiWebSyncService();

      try {
        final syncResult = await syncService.syncCollection(
          hostKey: authState.hostKey!,
        );

        if (context.mounted) {
          isSyncing.value = false;

          if (syncResult.success) {
            ref.read(authNotifierProvider.notifier).recordSyncSuccess();

            if (syncResult.decks.isNotEmpty) {
              deckNotifier.addDecks(syncResult.decks);
            }
            if (syncResult.cards.isNotEmpty) {
              ref.read(cardBrowserProvider.notifier).addCards(syncResult.cards);
            }

            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text('Đồng bộ thành công'),
                    subtitle: Text(syncResult.message),
                    leading: const Icon(m.Icons.cloud_done_rounded, color: m.Colors.green),
                    trailing: IconButton.ghost(
                      icon: const Icon(m.Icons.close),
                      onPressed: () => overlay.close(),
                    ),
                  ),
                );
              },
            );
          } else {
            showToast(
              context: context,
              builder: (context, overlay) {
                return SurfaceCard(
                  child: Basic(
                    title: const Text('Đồng bộ thất bại'),
                    subtitle: Text(syncResult.message),
                    leading: const Icon(m.Icons.cloud_off_rounded, color: m.Colors.red),
                    trailing: IconButton.ghost(
                      icon: const Icon(m.Icons.close),
                      onPressed: () => overlay.close(),
                    ),
                  ),
                );
              },
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          isSyncing.value = false;
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: const Text('Lỗi đồng bộ'),
                  subtitle: Text(e.toString()),
                  leading: const Icon(m.Icons.error_outline_rounded, color: m.Colors.red),
                  trailing: IconButton.ghost(
                    icon: const Icon(m.Icons.close),
                    onPressed: () => overlay.close(),
                  ),
                ),
              );
            },
          );
        }
      }
    }

    Future<void> handleApkgImport() async {
      try {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['apkg', 'zip'],
          withData: true,
        );

        if (result == null || result.files.isEmpty) return;

        final fileBytes = result.files.first.bytes ??
            (result.files.first.path != null ? File(result.files.first.path!).readAsBytesSync() : null);

        if (fileBytes == null) {
          throw const FormatException('Không thể đọc dữ liệu file .apkg.');
        }

        final importer = ApkgImporterService();
        final importResult = importer.importApkgBytes(fileBytes);

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
                  title: const Text('Import .apkg thành công!'),
                  subtitle: Text('Đã nạp ${importResult.decks.length} bộ thẻ, ${importResult.cards.length} thẻ (${importResult.mediaCount} files media).'),
                  leading: const Icon(m.Icons.check_circle_rounded, color: m.Colors.green),
                  trailing: IconButton.ghost(
                    icon: const Icon(m.Icons.close),
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
                  title: const Text('Lỗi Import .apkg'),
                  subtitle: Text(e.toString()),
                  leading: const Icon(m.Icons.error_outline_rounded, color: m.Colors.red),
                  trailing: IconButton.ghost(
                    icon: const Icon(m.Icons.close),
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
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return m.Material(
            type: m.MaterialType.transparency,
            child: CustomStudyModal(
              onStartCram: (name, tag, limit) {
                deckNotifier.createCramDeck(name: name, filterTag: tag, cardLimit: limit);
                showToast(
                  context: context,
                  builder: (context, overlay) {
                    return SurfaceCard(
                      child: Basic(
                        title: const Text('Đã tạo Cram Deck'),
                        subtitle: Text('Đã lọc $limit thẻ ôn cấp tốc (#$tag).'),
                        leading: const Icon(m.Icons.bolt_rounded, color: m.Colors.amber),
                        trailing: IconButton.ghost(
                          icon: const Icon(m.Icons.close),
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

    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            children: [
              const Icon(m.Icons.bolt_rounded, size: 22),
              const SizedBox(width: 8),
              Text(
                'Flanki',
                style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'FSRS v5',
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
            OutlineButton(
              onPressed: isSyncing.value ? null : handleSyncTap,
              leading: isSyncing.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      authState.isAuthenticated
                          ? m.Icons.cloud_done_outlined
                          : m.Icons.cloud_outlined,
                      size: 16,
                      color: authState.isAuthenticated ? m.Colors.green : null,
                    ),
              child: Text(
                authState.isAuthenticated ? 'Đã liên kết' : 'Sync AnkiWeb',
              ),
            ),
          ],
        ),
      ],
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
                          m.Icons.local_fire_department_rounded,
                          color: m.Colors.deepOrange,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '14 Ngày Streak',
                          style: theme.typography.h4.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      'Mục tiêu 85% nhớ',
                      style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
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
                        color: totalDue > 0 ? theme.colorScheme.destructive : theme.colorScheme.foreground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatMiniBox(
                        label: l10n.newCards,
                        value: '$totalNew',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Bar with leading icon
          Card(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Icon(m.Icons.search_rounded, size: 18, color: theme.colorScheme.mutedForeground),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    placeholder: Text(l10n.searchDecks),
                    onChanged: (val) => searchQuery.value = val,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header Section with Cram Mode & Import
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.navDecks} (${filteredDecks.length})',
                style: theme.typography.semiBold,
              ),
              Row(
                children: [
                  GhostButton(
                    onPressed: openCramModal,
                    leading: const Icon(m.Icons.bolt_rounded, size: 16, color: m.Colors.amber),
                    child: const Text('Cram'),
                  ),
                  const SizedBox(width: 4),
                  GhostButton(
                    onPressed: handleApkgImport,
                    leading: const Icon(m.Icons.file_upload_outlined, size: 16),
                    child: Text(l10n.importApkg),
                  ),
                ],
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
                    Icon(m.Icons.search_off_rounded, size: 48, color: theme.colorScheme.mutedForeground),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noDecksFound,
                      style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredDecks.map((deck) {
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
          const SizedBox(height: 80), // Space for bottom navigation bar
        ],
      ),
    );
  }
}

class _StatMiniBox extends StatelessWidget {
  final String label;
  final String value;
  final m.Color color;

  const _StatMiniBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
    final parentPath = hasHierarchy ? parts.sublist(0, parts.length - 1).join(' › ') : null;
    final leafName = parts.last;
    final isCram = title.contains('Cram');

    return Card(
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
                  isCram ? m.Icons.bolt_rounded : m.Icons.folder_outlined,
                  size: 24,
                  color: isCram ? m.Colors.amber : theme.colorScheme.foreground,
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
                      style: theme.typography.h4.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
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
              Row(
                children: [
                  if (dueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.destructive.withValues(alpha: 0.15),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
                    style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                  ),
                ],
              ),
              PrimaryButton(
                onPressed: onStudy,
                leading: const Icon(m.Icons.play_arrow_rounded, size: 16),
                child: Text(context.l10n.studyNow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
