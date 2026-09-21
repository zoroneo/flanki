import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/cloud_backup_service.dart';
import '../../../core/services/cloud_storage_stats_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../browser/providers/card_browser_notifier.dart';
import '../../decks/providers/deck_notifier.dart';
import '../../stats/providers/stats_notifier.dart';

/// Specific operation state for Cloud Backup workflows.
enum CloudBackupOp {
  none,
  creatingLocalSnapshot,
  uploadingToCloud,
  restoringFromCloud,
  exportingLocal,
  restoringLocal,
}

class CloudBackupState {
  final bool isLoading;
  final CloudBackupOp operation;
  final String? statusMessage;
  final double? progress;
  final List<CloudBackupMetadata> backups;
  final StorageStatsModel? stats;
  final String? error;

  const CloudBackupState({
    this.isLoading = false,
    this.operation = CloudBackupOp.none,
    this.statusMessage,
    this.progress,
    this.backups = const [],
    this.stats,
    this.error,
  });

  /// Resolves localized human-readable status text from current operation or fallback message.
  String? resolveStatusMessage(AppLocalizations l10n) {
    switch (operation) {
      case CloudBackupOp.none:
        return statusMessage;
      case CloudBackupOp.creatingLocalSnapshot:
        return l10n.backupCreating;
      case CloudBackupOp.uploadingToCloud:
        return l10n.backupUploading;
      case CloudBackupOp.restoringFromCloud:
      case CloudBackupOp.restoringLocal:
        return l10n.backupRestoring;
      case CloudBackupOp.exportingLocal:
        return l10n.backupExporting;
    }
  }

  CloudBackupState copyWith({
    bool? isLoading,
    CloudBackupOp? operation,
    String? statusMessage,
    double? progress,
    List<CloudBackupMetadata>? backups,
    StorageStatsModel? stats,
    String? error,
  }) {
    return CloudBackupState(
      isLoading: isLoading ?? this.isLoading,
      operation: operation ?? this.operation,
      statusMessage: statusMessage,
      progress: progress,
      backups: backups ?? this.backups,
      stats: stats ?? this.stats,
      error: error,
    );
  }
}

final cloudBackupServiceProvider = Provider<CloudBackupService>((ref) {
  return CloudBackupService();
});

final cloudStorageStatsServiceProvider = Provider<CloudStorageStatsService>((
  ref,
) {
  return CloudStorageStatsService();
});

class CloudBackupNotifier extends Notifier<CloudBackupState> {
  late final CloudBackupService _backupService;
  late final CloudStorageStatsService _statsService;

  @override
  CloudBackupState build() {
    _backupService = ref.watch(cloudBackupServiceProvider);
    _statsService = ref.watch(cloudStorageStatsServiceProvider);
    Future.microtask(() => refresh());
    return const CloudBackupState();
  }

  Future<void> refresh() async {
    try {
      final backups = await _backupService.listCloudSnapshots();
      final stats = await _statsService.getStats();
      state = state.copyWith(backups: backups, stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> createCloudBackup() async {
    state = state.copyWith(
      isLoading: true,
      operation: CloudBackupOp.creatingLocalSnapshot,
      progress: 0.1,
      error: null,
    );

    try {
      final snapshot = await _backupService.createLocalSnapshot(
        onProgress: (p) {
          state = state.copyWith(progress: p * 0.5);
        },
      );

      state = state.copyWith(operation: CloudBackupOp.uploadingToCloud);
      await _backupService.uploadSnapshotToCloud(
        snapshot,
        onProgress: (p) {
          state = state.copyWith(progress: 0.5 + p * 0.5);
        },
      );

      // Clean up local temp file
      if (snapshot.existsSync()) {
        try {
          snapshot.deleteSync();
        } catch (_) {}
      }

      await refresh();
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        progress: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        progress: null,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> restoreFromCloud(String cloudPath) async {
    state = state.copyWith(
      isLoading: true,
      operation: CloudBackupOp.restoringFromCloud,
      progress: 0.2,
      error: null,
    );

    try {
      await _backupService.restoreFromCloudSnapshot(
        cloudPath,
        onProgress: (p) {
          state = state.copyWith(progress: p);
        },
      );

      // Refresh UI stores
      ref.invalidate(deckListProvider);
      ref.invalidate(cardBrowserProvider);
      ref.invalidate(statsNotifierProvider);

      await refresh();
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        progress: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        progress: null,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> deleteCloudBackup(String cloudPath) async {
    try {
      await _backupService.deleteCloudSnapshot(cloudPath);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<File?> exportLocalBackup({String? targetPath}) async {
    state = state.copyWith(
      isLoading: true,
      operation: CloudBackupOp.exportingLocal,
      error: null,
    );
    try {
      final file = await _backupService.createLocalSnapshot(
        targetFilePath: targetPath,
      );
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> restoreLocalBackup(File backupFile) async {
    state = state.copyWith(
      isLoading: true,
      operation: CloudBackupOp.restoringLocal,
      error: null,
    );
    try {
      await _backupService.restoreFromSnapshot(backupFile);
      ref.invalidate(deckListProvider);
      ref.invalidate(cardBrowserProvider);
      ref.invalidate(statsNotifierProvider);

      await refresh();
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        operation: CloudBackupOp.none,
        statusMessage: null,
        error: e.toString(),
      );
      return false;
    }
  }
}

final cloudBackupNotifierProvider =
    NotifierProvider<CloudBackupNotifier, CloudBackupState>(() {
      return CloudBackupNotifier();
    });
