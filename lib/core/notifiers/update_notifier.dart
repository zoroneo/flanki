import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/update_info.dart';
import '../services/desktop_update_service.dart';
import '../states/update_state.dart';

export '../states/update_state.dart';

part 'update_notifier.g.dart';

@Riverpod(keepAlive: true, name: 'updateProvider')
class UpdateNotifier extends _$UpdateNotifier {
  late final DesktopUpdateService _service;

  @override
  UpdateState build() {
    _service = DesktopUpdateService();
    return const UpdateState();
  }

  /// Check for application updates.
  Future<UpdateInfo?> checkForUpdates({bool silent = false}) async {
    if (!DesktopUpdateService.isSupported) return null;

    state = state.copyWith(
      status: UpdateStatus.checking,
      errorMessage: null,
      errorType: null,
      isBackgroundCheck: silent,
    );

    try {
      final info = await _service.checkForUpdates();
      if (info.hasUpdate) {
        state = state.copyWith(
          status: UpdateStatus.available,
          updateInfo: info,
          lastChecked: DateTime.now(),
          isBackgroundCheck: silent,
        );
        return info;
      } else {
        state = state.copyWith(
          status: UpdateStatus.upToDate,
          updateInfo: info,
          lastChecked: DateTime.now(),
          isBackgroundCheck: silent,
        );
        return info;
      }
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorType: UpdateErrorType.checkFailed,
        errorMessage: e.toString(),
        lastChecked: DateTime.now(),
        isBackgroundCheck: silent,
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
      errorType: null,
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
        errorType: UpdateErrorType.downloadFailed,
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
