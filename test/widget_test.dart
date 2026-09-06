import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/main.dart';

void main() {
  testWidgets('FlankiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlankiApp());
    expect(find.text('Flanki'), findsOneWidget);
  });
}
