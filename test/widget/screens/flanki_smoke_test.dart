import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/main.dart';
import 'package:flanki/core/database/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_widget_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_widget.db',
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

  testWidgets('FlankiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
    await tester.pumpAndSettle();
    expect(find.text('Flanki'), findsAtLeast(1));
  });
}
