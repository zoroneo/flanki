import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flanki/core/storage/database_service.dart';
import 'package:flanki/main.dart';

import 'package:flanki/core/models/grammar/grammar_models.dart';
import 'package:flanki/core/services/grammar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_grammar_nav_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_grammar_nav.db',
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

  testWidgets('Desktop: Navigating to Grammar tab renders catalog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const mockUnit = GrammarUnit(
      unitId: 'unit_01',
      title: 'Thì Hiện Tại & Quá Khứ Cơ Bản',
      category: GrammarCategory.tenses,
      level: GrammarLevel.foundation,
      coreConcept: 'Khái niệm thì',
      formulas: {},
      commonTraps: [],
      exercises: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarUnitsProvider.overrideWith((ref) async => [mockUnit]),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Check that Grammar item exists in sidebar
    expect(find.text('Grammar'), findsWidgets);

    // Tap on Grammar nav item
    await tester.tap(find.text('Grammar').first);
    await tester.pumpAndSettle();

    // Verify catalog header & unit card are rendered
    expect(find.text('Ngữ Pháp Học Thuật'), findsOneWidget);
    expect(find.text('Tất Cả (36)'), findsOneWidget);
    expect(find.text('Thì Hiện Tại & Quá Khứ Cơ Bản'), findsOneWidget);
  });

  testWidgets('Desktop: Ctrl+3 shortcut navigates to Grammar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const mockUnit = GrammarUnit(
      unitId: 'unit_01',
      title: 'Thì Hiện Tại & Quá Khứ Cơ Bản',
      category: GrammarCategory.tenses,
      level: GrammarLevel.foundation,
      coreConcept: 'Khái niệm thì',
      formulas: {},
      commonTraps: [],
      exercises: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarUnitsProvider.overrideWith((ref) async => [mockUnit]),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Trigger Ctrl+3 shortcut to switch to Grammar tab
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Ngữ Pháp Học Thuật'), findsOneWidget);
    expect(find.text('Thì Hiện Tại & Quá Khứ Cơ Bản'), findsOneWidget);
  });

  testWidgets('Mobile: Bottom bar navigation switches to Grammar tab', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const mockUnit = GrammarUnit(
      unitId: 'unit_01',
      title: 'Thì Hiện Tại & Quá Khứ Cơ Bản',
      category: GrammarCategory.tenses,
      level: GrammarLevel.foundation,
      coreConcept: 'Khái niệm thì',
      formulas: {},
      commonTraps: [],
      exercises: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          grammarUnitsProvider.overrideWith((ref) async => [mockUnit]),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // In bottom nav, find Grammar tab and tap it
    expect(find.text('Grammar'), findsWidgets);
    await tester.tap(find.text('Grammar').first);
    await tester.pumpAndSettle();

    expect(find.text('Ngữ Pháp Học Thuật'), findsOneWidget);
    expect(find.text('Tất Cả (36)'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Thì Hiện Tại & Quá Khứ Cơ Bản'), findsOneWidget);
  });
}
