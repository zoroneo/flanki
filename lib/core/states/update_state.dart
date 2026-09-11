import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/update_info.dart';

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
