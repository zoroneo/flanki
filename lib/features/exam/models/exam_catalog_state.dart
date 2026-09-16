import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'exam_models.dart';

part 'exam_catalog_state.freezed.dart';

@freezed
abstract class ExamCatalogState with _$ExamCatalogState {
  const ExamCatalogState._();

  const factory ExamCatalogState({
    @Default(false) bool isLoading,
    @Default([]) List<ExamPaperModel> papers,
    ExamCategory? selectedCategory,
    String? selectedLevel,
    String? error,
  }) = _ExamCatalogState;

  String? getLocalizedError(AppLocalizations l10n) {
    final err = error;
    if (err == null) return null;
    return switch (err) {
      _ when err.startsWith('ERR_EXAM_DOWNLOAD:') => l10n.examDownloadFailed(
        err.substring('ERR_EXAM_DOWNLOAD:'.length),
      ),
      _ => err,
    };
  }
}
