import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/features/grammar/data/grammar_service.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';
import 'package:flanki/features/grammar/ui/grammar_theory_screen.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Capture desktop screenshots of all 36 grammar units', (
    tester,
  ) async {
    final grammarDir = Directory('assets/data/grammar');
    final files =
        grammarDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final outDir = Directory(
      '/Users/tuthanhnguyen/.gemini/antigravity/brain/afb657a4-91e7-4095-ae43-77798025d6cb/screenshots',
    );
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    tester.view.physicalSize = const ui.Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final file in files) {
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final unit = GrammarUnit.fromJson(jsonMap);
      final filename = file.uri.pathSegments.last.replaceAll('.json', '');

      final repaintKey = GlobalKey();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            grammarUnitsProvider.overrideWith((ref) async => [unit]),
          ],
          child: ShadcnApp(
            locale: const Locale('vi'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ShadcnLocalizationsViDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: RepaintBoundary(
              key: repaintKey,
              child: GrammarTheoryScreen(unitId: unit.unitId),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final boundary =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final outFile = File('${outDir.path}/$filename.png');
        outFile.writeAsBytesSync(byteData.buffer.asUint8List());
        // ignore: avoid_print
        print('Saved: ${outFile.path}');
      }
    }
  });
}
