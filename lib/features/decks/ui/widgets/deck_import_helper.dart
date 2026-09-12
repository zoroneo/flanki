import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/anki/apkg_importer_service.dart';
import 'package:flanki/features/browser/providers/card_browser_notifier.dart';
import '../../providers/deck_notifier.dart';

class DeckImportHelper {
  static Future<void> executeApkgImport({
    required BuildContext context,
    required WidgetRef ref,
    required DeckNotifier deckNotifier,
    required dynamic l10n,
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
                    color: m.Colors.red,
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
          throw const FormatException('File data unreadable');
        }
      } finally {
        loadingToast?.close();
      }

      if (importResult.decks.isNotEmpty) {
        deckNotifier.addDecks(importResult.decks);
      }
      if (importResult.cards.isNotEmpty) {
        ref.read(cardBrowserProvider.notifier).addCards(importResult.cards);
      }

      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgSuccess),
                subtitle: Text(
                  l10n.importApkgSuccessDesc(
                    importResult.decks.length,
                    importResult.cards.length,
                    importResult.mediaCount,
                  ),
                ),
                leading: const Icon(
                  LucideIcons.circleCheck,
                  color: m.Colors.green,
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
    } catch (e) {
      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.importApkgError),
                subtitle: Text(e.toString()),
                leading: const Icon(
                  LucideIcons.circleAlert,
                  color: m.Colors.red,
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
