import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/sync/supabase_sync_engine.dart';

part 'sync_ui_state.freezed.dart';

@freezed
abstract class SyncUiState with _$SyncUiState {
  const SyncUiState._();

  const factory SyncUiState({
    @Default(SyncStatus.idle) SyncStatus status,
    DateTime? lastSyncedAt,
    @Default(0) int pendingCount,
    String? errorMessage,
  }) = _SyncUiState;

  bool get isSyncing => status == SyncStatus.syncing;
  bool get isOffline => status == SyncStatus.offline;
}
