import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ToastOverlay;

import '../../core/auth/auth_notifier.dart';
import '../../core/notifiers/card_browser_notifier.dart';
import '../../core/notifiers/deck_notifier.dart';
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

    final service =
        syncService ??
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

      final shouldUpload =
          choice == SyncConflictChoice.upload ||
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
          await ref.read(deckListProvider.notifier).refresh();

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
}
