import 'dart:io';

import 'package:flanki/core/storage/database_service.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:flanki/features/editor/ui/note_editor_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_editor_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_editor.db',
    );
  });

  tearDown(() async {
    await DatabaseService.instance.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  Widget createTestWidget() {
    return const ProviderScope(
      child: ShadcnApp(
        localizationsDelegates: [AppLocalizations.delegate],
        home: NoteEditorScreen(),
      ),
    );
  }

  testWidgets(
    'NoteEditorScreen desktop layout renders two columns when width >= 800',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Title and Save button
      expect(find.text('Add New Card'), findsOneWidget);
      expect(find.text('Save card'), findsOneWidget);
      expect(find.text('Ctrl/⌘ + ↵'), findsOneWidget);

      // Verify desktop note type options
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Basic'), findsOneWidget);
      expect(find.text('Cloze'), findsOneWidget);
      expect(find.text('Reversed'), findsOneWidget);
    },
  );

  testWidgets('NoteEditorScreen mobile layout renders when width < 800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify components still render on mobile
    expect(find.text('Add New Card'), findsOneWidget);
    expect(find.text('Save card'), findsOneWidget);
    expect(find.text('Basic'), findsOneWidget);
  });
}
