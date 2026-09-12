import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/ui/widgets/animations/shake_animation.dart';

void main() {
  testWidgets('ShakeAnimation renders child without offset when not triggered', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ShakeAnimation(
          trigger: false,
          child: Text('Test Option'),
        ),
      ),
    );

    expect(find.text('Test Option'), findsOneWidget);
    final transformFinder = find.byType(Transform);
    expect(transformFinder, findsOneWidget);
    final transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform.getTranslation().x, equals(0.0));
  });

  testWidgets('ShakeAnimation triggers shake and calls onComplete', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ShakeAnimation(
          trigger: true,
          duration: const Duration(milliseconds: 200),
          onComplete: () => completed = true,
          child: const Text('Wrong Option'),
        ),
      ),
    );

    // Initial pump starts animation
    await tester.pump(const Duration(milliseconds: 50));
    final transformFinder = find.byType(Transform);
    final transform = tester.widget<Transform>(transformFinder);
    // At mid-animation, offset is non-zero
    expect(transform.transform.getTranslation().x, isNot(equals(0.0)));

    // Settle to end of animation
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });
}
