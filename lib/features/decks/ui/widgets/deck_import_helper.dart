import 'package:file_picker/file_picker.dart';

import '../../../../core/logging/error_severity.dart';
import '../../../../core/logging/error_logger.dart';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/anki/apkg_importer_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/theme/app_tokens.dart';

import '../../providers/deck_notifier.dart';

class DeckImportHelper {
  static Future<void> executeApkgImport({
    required BuildContext context,
    required WidgetRef ref,
    required DeckNotifier deckNotifier,
    required AppLocalizations l10n,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      final selectedFile = result.files.first;
      final ext =
          (selectedFile.extension ??
                  (selectedFile.name.contains('.')
                      ? selectedFile.name.split('.').last
                      : ''))
              .toLowerCase();

      if (ext != 'apkg' && ext != 'zip' && ext != 'colpkg') {
        if (context.mounted) {
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: Text(l10n.importApkgError),
                  subtitle: Text(l10n.selectApkgOrZipPrompt),
                  leading: const Icon(
                    LucideIcons.circleAlert,
                    color: AppColors.error,
                  ),
                  trailing: IconButton.ghost(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => overlay.close(),
                  ),
                ),
              );
            },
          );
        }
        return;
      }

      ToastOverlay? loadingToast;
      if (context.mounted) {
        loadingToast = showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkg),
                subtitle: Text(selectedFile.name),
                leading: const SizedBox(
                  width: AppIconSize.md,
                  height: AppIconSize.md,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.spinnerStrokeWidth,
                  ),
                ),
              ),
            );
          },
        );
      }

      final importer = ApkgImporterService();
      final ApkgImportResult importResult;

      try {
        if (selectedFile.path != null && selectedFile.path!.isNotEmpty) {
          importResult = await importer.importApkgPath(
            selectedFile.path!,
            defaultDeckDescription: l10n.importedDeckDefaultDesc,
          );
        } else if (selectedFile.bytes != null) {
          importResult = importer.importApkgBytes(
            selectedFile.bytes!,
            defaultDeckDescription: l10n.importedDeckDefaultDesc,
          );
        } else {
          throw const FormatException(AppConfig.errFileDataUnreadable);
        }
      } finally {
        loadingToast?.close();
      }

      if (importResult.decks.isNotEmpty) {
        deckNotifier.addDecks(importResult.decks);
      }
      if (importResult.cards.isNotEmpty) {
        DatabaseService.instance.saveCards(importResult.cards);
      }

      if (context.mounted) {
        final hasFailedMedia = importResult.failedMediaFiles.isNotEmpty;
        final baseDesc = l10n.importApkgSuccessDesc(
          importResult.decks.length,
          importResult.cards.length,
          importResult.mediaCount,
        );
        final subtitleDesc = hasFailedMedia
            ? '$baseDesc (${importResult.failedMediaFiles.length} media skipped)'
            : baseDesc;

        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgSuccess),
                subtitle: Text(subtitleDesc),
                leading: Icon(
                  hasFailedMedia ? LucideIcons.alertTriangle : LucideIcons.circleCheck,
                  color: hasFailedMedia ? AppColors.warning : AppColors.success,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      }
    } catch (e, st) {
      ErrorLogger.instance.captureException(
        e,
        stackTrace: st,
        context: 'DeckImportHelper.pickAndImportApkg',
        severity: ErrorSeverity.error,
      );
      if (context.mounted) {
        final errorSubtitle = e is FormatException
            ? l10n.importApkgInvalidFormat
            : e.toString();
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgError),
                subtitle: Text(errorSubtitle),
                leading: const Icon(
                  LucideIcons.circleAlert,
                  color: AppColors.error,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      }
    }
  }
}
