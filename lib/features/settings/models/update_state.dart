import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../l10n/generated/app_localizations.dart';
import 'update_info.dart';

part 'update_state.freezed.dart';

enum UpdateStatus {
  idle,
  checking,
  available,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

enum UpdateErrorType { checkFailed, downloadFailed, installFailed }

@freezed
abstract class UpdateState with _$UpdateState {
  const factory UpdateState({
    @Default(UpdateStatus.idle) UpdateStatus status,
    UpdateInfo? updateInfo,
    @Default(0.0) double downloadProgress,
    String? downloadedFilePath,
    String? errorMessage,
    UpdateErrorType? errorType,
    DateTime? lastChecked,
    @Default(false) bool isBackgroundCheck,
  }) = _UpdateState;
}

extension UpdateStateX on UpdateState {
  String? getLocalizedError(AppLocalizations l10n) {
    if (status != UpdateStatus.error) return null;
    switch (errorType) {
      case UpdateErrorType.checkFailed:
        return l10n.updateCheckFailed;
      case UpdateErrorType.downloadFailed:
        return l10n.updateDownloadFailed;
      case UpdateErrorType.installFailed:
        return l10n.updateInstallFailed;
      case null:
        return errorMessage ?? l10n.updateDownloadFailed;
    }
  }
}
