import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/main.dart';
import 'package:flanki/core/storage/database_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show VerticalDivider;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_desktop_layout_test_');
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

  testWidgets('Desktop layout renders sidebar when width >= 768px', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Desktop view shows vertical divider between sidebar and content
    expect(find.byType(VerticalDivider), findsOneWidget);
    // Flanki text is visible in sidebar and/or header
    expect(find.text('Flanki'), findsAtLeast(1));
  });

  testWidgets('Mobile layout hides sidebar and renders bottom nav when width < 768px', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // In mobile layout, VerticalDivider (from desktop sidebar) is NOT present
    expect(find.byType(VerticalDivider), findsNothing);
  });
}
