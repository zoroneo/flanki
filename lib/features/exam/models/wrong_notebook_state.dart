import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'exam_models.dart';

part 'wrong_notebook_state.freezed.dart';

@freezed
abstract class WrongNotebookState with _$WrongNotebookState {
  const WrongNotebookState._();

  const factory WrongNotebookState({
    @Default(false) bool isLoading,
    @Default([]) List<WrongQuestionModel> questions,
    WrongQuestionStatus? filterStatus,
    String? error,
  }) = _WrongNotebookState;

  String? getLocalizedError(AppLocalizations l10n) {
    final err = error;
    if (err == null) return null;
    return switch (err) {
      _ when err.startsWith('ERR_WRONG_STATUS_UPDATE:') =>
        l10n.wrongStatusUpdateFailed(
          err.substring('ERR_WRONG_STATUS_UPDATE:'.length),
        ),
      _ => err,
    };
  }
}
