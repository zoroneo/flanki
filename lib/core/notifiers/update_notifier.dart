import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update_info.dart';
import '../services/desktop_update_service.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

class UpdateState {
  final UpdateStatus status;
  final UpdateInfo? updateInfo;
  final double downloadProgress;
  final String? downloadedFilePath;
  final String? errorMessage;
  final DateTime? lastChecked;

  const UpdateState({
    this.status = UpdateStatus.idle,
    this.updateInfo,
    this.downloadProgress = 0.0,
    this.downloadedFilePath,
    this.errorMessage,
    this.lastChecked,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    UpdateInfo? updateInfo,
    double? downloadProgress,
    String? downloadedFilePath,
    String? errorMessage,
    DateTime? lastChecked,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadedFilePath: downloadedFilePath ?? this.downloadedFilePath,
      errorMessage: errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class UpdateNotifier extends Notifier<UpdateState> {
  late final DesktopUpdateService _service;

  @override
  UpdateState build() {
    _service = DesktopUpdateService();
    return const UpdateState();
  }

  /// Check for application updates.
  Future<UpdateInfo?> checkForUpdates({bool silent = false}) async {
    if (!DesktopUpdateService.isSupported) return null;

    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final info = await _service.checkForUpdates();
      if (info.hasUpdate) {
        state = state.copyWith(
          status: UpdateStatus.available,
          updateInfo: info,
          lastChecked: DateTime.now(),
        );
        return info;
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          updateInfo: info,
          lastChecked: DateTime.now(),
        );
        return info;
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
        lastChecked: DateTime.now(),
      );
      return null;
    }
  }

  /// Download the update asset.
  Future<void> downloadUpdate() async {
    final info = state.updateInfo;
    if (info == null || info.downloadUrl == null) {
      if (info?.releaseUrl != null) {
        await DesktopUpdateService.openUrl(info!.releaseUrl);
      }
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0.0,
      errorMessage: null,
    );

    final path = await _service.downloadUpdate(
      info.downloadUrl!,
      fileName: info.assetName,
      onProgress: (progress) {
        state = state.copyWith(downloadProgress: progress);
      },
    );

    if (path != null) {
      state = state.copyWith(
        status: UpdateStatus.readyToInstall,
        downloadedFilePath: path,
        downloadProgress: 1.0,
      );
    } else {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Failed to download installer',
      );
    }
  }

  /// Install downloaded update and restart/exit app.
  Future<void> installAndRestart() async {
    final filePath = state.downloadedFilePath;
    if (filePath != null) {
      await _service.installAndRestart(filePath);
    } else if (state.updateInfo?.releaseUrl != null) {
      await DesktopUpdateService.openUrl(state.updateInfo!.releaseUrl);
    }
  }

  /// Reset update dialog status.
  void dismiss() {
    state = state.copyWith(status: UpdateStatus.idle);
  }
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(UpdateNotifier.new);
