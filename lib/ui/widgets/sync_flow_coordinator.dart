import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ToastOverlay;

import '../../core/auth/auth_notifier.dart';
import '../../core/notifiers/card_browser_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
import '../../core/notifiers/stats_notifier.dart';
import '../../core/storage/database_service.dart';
import '../../core/sync/anki_web_sync_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../screens/auth/anki_web_auth_sheet.dart';
import 'sync_conflict_dialog.dart';
import 'sync_progress_toast.dart';

/// Centralized coordinator for the AnkiWeb synchronization workflow.
///
/// Encapsulates authentication checks, conflict resolution modal dialogs,
/// progress toast overlays, collection upload/download, and Riverpod state updates.
class SyncFlowCoordinator {
  const SyncFlowCoordinator._();

  /// Executes the full AnkiWeb synchronization flow.
  ///
  /// Returns `true` if synchronization succeeded, `false` otherwise.
  static Future<bool> runSyncFlow({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    ValueNotifier<bool>? isSyncing,
    AnkiWebSyncService? syncService,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated || authState.hostKey == null) {
      final loggedIn = await AnkiWebAuthSheet.show(context);
      if (loggedIn != true) return false;
    }

    final currentAuthState = ref.read(authNotifierProvider);
    if (!currentAuthState.isAuthenticated || currentAuthState.hostKey == null) {
      return false;
    }

    if (isSyncing != null) isSyncing.value = true;

    final service = syncService ??
        AnkiWebSyncService(
          messages: SyncProgressMessages.fromL10n(l10n),
          l10n: l10n,
        );

    try {
      final lastSyncTime = currentAuthState.lastSyncedAt;
      final hasLocalChanges = DatabaseService.instance.hasLocalChangesSince(
        lastSyncTime,
      );

      final check = await service.checkSyncStatus(
        hostKey: currentAuthState.hostKey!,
        lastSyncTime: lastSyncTime,
        hasLocalChanges: hasLocalChanges,
      );

      SyncConflictChoice? choice;
      if (check.action == SyncActionRequired.conflict) {
        if (!context.mounted) return false;
        choice = await SyncConflictDialog.show(
          context,
          localLastSync: check.localLastSync,
          serverMod: check.serverMod,
        );
        if (choice == null) return false;
      }

      final shouldMerge = choice == SyncConflictChoice.merge;
      final shouldUpload = choice == SyncConflictChoice.upload ||
          (choice == null && check.action == SyncActionRequired.upload);

      final statusNotifier = ValueNotifier<SyncProgressStatus>(
        SyncProgressStatus(
          title: l10n.syncAnkiWeb,
          message: shouldMerge
              ? l10n.syncDownloadingCollection
              : (shouldUpload
                  ? l10n.preparingUpload
                  : l10n.connectingToAnkiWeb),
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
        if (shouldMerge) {
          // 1. Download cloud collection
          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncAnkiWeb,
            message: l10n.syncDownloadingCollection,
            progress: 0.2,
          );
          final downloadResult = await service.syncCollection(
            hostKey: currentAuthState.hostKey!,
            syncMediaFiles: false,
          );

          if (!downloadResult.success) {
            statusNotifier.value = SyncProgressStatus(
              title: l10n.syncFailed,
              message: downloadResult.message,
              progress: 1.0,
              isError: true,
            );
            Future.delayed(const Duration(seconds: 5), () {
              toastOverlay?.close();
            });
            return false;
          }

          // 2. Non-destructive merge of decks, cards and review logs
          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncAnkiWeb,
            message: l10n.syncProcessingData,
            progress: 0.45,
          );
          if (downloadResult.decks.isNotEmpty) {
            await ref
                .read(deckListProvider.notifier)
                .addDecks(downloadResult.decks);
          }
          if (downloadResult.cards.isNotEmpty) {
            await DatabaseService.instance.mergeCards(downloadResult.cards);
            ref.read(cardBrowserProvider.notifier).refresh();
          }
          if (downloadResult.reviewLogs.isNotEmpty) {
            await DatabaseService.instance
                .saveReviewLogs(downloadResult.reviewLogs);
            ref.read(statsNotifierProvider.notifier).refresh();
          }
          await ref.read(deckListProvider.notifier).refresh();

          // 3. Export merged collection and upload back to AnkiWeb
          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncAnkiWeb,
            message: l10n.syncCompressingUpload,
            progress: 0.65,
          );
          final dbBytes = await DatabaseService.instance.exportToAnki2Db();
          syncResult = await service.uploadCollection(
            hostKey: currentAuthState.hostKey!,
            dbBytes: dbBytes,
            syncMediaFiles: true,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: 0.65 + (0.35 * progress),
              );
            },
          );
        } else if (shouldUpload) {
          final dbBytes = await DatabaseService.instance.exportToAnki2Db();
          syncResult = await service.uploadCollection(
            hostKey: currentAuthState.hostKey!,
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
          syncResult = await service.syncCollection(
            hostKey: currentAuthState.hostKey!,
            onProgress: (stage, progress) {
              statusNotifier.value = SyncProgressStatus(
                title: l10n.syncAnkiWeb,
                message: stage,
                progress: progress,
              );
            },
          );
        }

        if (!context.mounted) return syncResult.success;

        if (syncResult.success) {
          ref.read(authNotifierProvider.notifier).recordSyncSuccess();

          if (!shouldMerge) {
            if (syncResult.decks.isNotEmpty) {
              await ref
                  .read(deckListProvider.notifier)
                  .addDecks(syncResult.decks);
            }
            if (syncResult.cards.isNotEmpty) {
              await ref
                  .read(cardBrowserProvider.notifier)
                  .addCards(syncResult.cards);
            }
            if (syncResult.reviewLogs.isNotEmpty) {
              await DatabaseService.instance
                  .saveReviewLogs(syncResult.reviewLogs);
              ref.read(statsNotifierProvider.notifier).refresh();
            }
            await ref.read(deckListProvider.notifier).refresh();
          }

          statusNotifier.value = SyncProgressStatus(
            title: l10n.syncCompleted,
            message: syncResult.message,
            progress: 1.0,
            isCompleted: true,
          );
          Future.delayed(const Duration(seconds: 4), () {
            toastOverlay?.close();
          });
          return true;
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
          return false;
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
        return false;
      }
    } finally {
      if (isSyncing != null) isSyncing.value = false;
    }
  }

  static bool _isAutoSyncRunning = false;

  /// Runs background silent sync without showing blocking modals.
  /// Automatically pulls changes or pushes non-conflicting local reviews.
  static Future<void> runAutoSync({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    AnkiWebSyncService? syncService,
  }) async {
    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated || authState.hostKey == null) return;
    if (_isAutoSyncRunning) return;

    _isAutoSyncRunning = true;
    try {
      final service = syncService ??
          AnkiWebSyncService(
            messages: SyncProgressMessages.fromL10n(l10n),
            l10n: l10n,
          );

      final lastSyncTime = authState.lastSyncedAt;
      final hasLocalChanges = DatabaseService.instance.hasLocalChangesSince(
        lastSyncTime,
      );

      final check = await service.checkSyncStatus(
        hostKey: authState.hostKey!,
        lastSyncTime: lastSyncTime,
        hasLocalChanges: hasLocalChanges,
      );

      if (check.action == SyncActionRequired.download) {
        final syncResult = await service.syncCollection(
          hostKey: authState.hostKey!,
        );
        if (syncResult.success) {
          ref.read(authNotifierProvider.notifier).recordSyncSuccess();
          if (syncResult.decks.isNotEmpty) {
            await ref
                .read(deckListProvider.notifier)
                .addDecks(syncResult.decks);
          }
          if (syncResult.cards.isNotEmpty) {
            await DatabaseService.instance.mergeCards(syncResult.cards);
            ref.read(cardBrowserProvider.notifier).refresh();
          }
          if (syncResult.reviewLogs.isNotEmpty) {
            await DatabaseService.instance
                .saveReviewLogs(syncResult.reviewLogs);
            ref.read(statsNotifierProvider.notifier).refresh();
          }
          await ref.read(deckListProvider.notifier).refresh();
        }
      } else if (check.action == SyncActionRequired.upload) {
        final dbBytes = await DatabaseService.instance.exportToAnki2Db();
        final syncResult = await service.uploadCollection(
          hostKey: authState.hostKey!,
          dbBytes: dbBytes,
        );
        if (syncResult.success) {
          ref.read(authNotifierProvider.notifier).recordSyncSuccess();
        }
      }
    } catch (_) {
      // Silent in background auto-sync
    } finally {
      _isAutoSyncRunning = false;
    }
  }
}
