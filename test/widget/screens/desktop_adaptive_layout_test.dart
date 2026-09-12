import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/main.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show VerticalDivider;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'flanki_desktop_layout_test_',
    );
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_desktop.db',
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

  testWidgets('Desktop layout renders full sidebar when width >= 1024px', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
    await tester.pumpAndSettle();

    // Desktop view shows vertical divider between sidebar and content
    expect(find.byType(VerticalDivider), findsOneWidget);
    // Flanki brand and desktop subtitle are visible in sidebar
    expect(find.text('Flanki'), findsAtLeast(1));
    expect(find.text('Desktop • Zinc'), findsOneWidget);
    expect(find.text('Ctrl+1'), findsOneWidget);
  });

  testWidgets(
    'Tablet layout renders navigation rail when 600px <= width < 1024px',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
      await tester.pumpAndSettle();

      // Tablet view shows vertical divider between rail and content
      expect(find.byType(VerticalDivider), findsOneWidget);
      // Tablet rail has compact brand icon and does NOT show desktop subtitle
      expect(find.text('Desktop • Zinc'), findsNothing);
    },
  );

  testWidgets(
    'Mobile layout hides sidebar/rail and renders bottom nav when width < 600px',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
      await tester.pumpAndSettle();

      // In mobile layout, VerticalDivider is NOT present
      expect(find.byType(VerticalDivider), findsNothing);
      // Desktop subtitle is NOT present
      expect(find.text('Desktop • Zinc'), findsNothing);
    },
  );
}
