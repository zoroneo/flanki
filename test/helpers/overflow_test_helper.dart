import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Standard viewport sizes for multi-form-factor testing.
class TestViewports {
  /// Smallest supported mobile width (iPhone SE 1st gen).
  static const Size smallMobile = Size(320, 568);

  /// Modern standard mobile viewport (iPhone 13/14/15, modern Android).
  static const Size standardMobile = Size(390, 844);

  /// Medium tablet / foldable screen (iPad Mini, tablet portrait).
  static const Size tablet = Size(768, 1024);

  /// Standard desktop / laptop workspace.
  static const Size desktop = Size(1280, 800);

  /// Ultra-wide desktop workstation.
  static const Size wideDesktop = Size(1440, 900);
}

/// Sets the tester's viewport and text scaling, registering cleanup via addTearDown.
void setTestViewport(
  WidgetTester tester, {
  required Size size,
  double textScale = 1.0,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Pumps a widget within a specific viewport and text scale, verifying zero overflow exceptions.
Future<void> pumpAndAssertNoOverflow(
  WidgetTester tester,
  Widget widget, {
  required Size size,
  double textScale = 1.0,
  Duration? duration,
}) async {
  setTestViewport(tester, size: size, textScale: textScale);
  await tester.pumpWidget(widget);
  if (duration != null) {
    await tester.pump(duration);
  } else {
    await tester.pumpAndSettle();
  }

  // Ensure no RenderFlex or layout exceptions occurred
  expect(
    tester.takeException(),
    isNull,
    reason: 'Layout overflowed on $size with scale $textScale',
  );
}
