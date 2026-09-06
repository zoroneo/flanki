import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/main.dart';

void main() {
  testWidgets('FlankiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Flanki'), findsOneWidget);
  });
}
