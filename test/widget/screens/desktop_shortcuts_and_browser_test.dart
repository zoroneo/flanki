import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/main.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/models/deck.dart';
import 'package:flanki/core/database/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_desktop_nav_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_browser.db',
    );
    await DatabaseService.instance.saveDeck(
      const DeckModel(
        id: 'deck_desktop_1',
        title: 'Desktop Deck',
        description: 'Deck description',
        dueCount: 1,
        newCount: 0,
        totalCount: 1,
      ),
    );
    await DatabaseService.instance.saveCard(
      CardModel(
        id: 'card_desktop_1',
        deckId: 'deck_desktop_1',
        front: 'Desktop Test Question',
        back: 'Desktop Test Answer',
        createdAt: DateTime.now(),
      ),
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

  testWidgets(
    'Desktop: Ctrl+2 navigates to Browser and renders 2-pane master-detail',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
      await tester.pumpAndSettle();

      // Trigger Ctrl+2 shortcut to switch to Browser tab
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // We are now on Browser screen: card front should be displayed
      expect(find.text('Desktop Test Question'), findsWidgets);
      // Detail pane on right shows Front preview, and reveals Back on Show Answer
      expect(find.text('FRONT'), findsOneWidget);
      await tester.tap(find.text('Show Answer').first);
      await tester.pumpAndSettle();
      expect(find.text('BACK'), findsOneWidget);
      expect(find.text('Desktop Test Answer'), findsWidgets);

      // Trigger Ctrl+1 shortcut to switch back to Decks tab
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();

      // Verify back on Decks screen
      expect(find.text('Desktop Deck'), findsWidgets);
    },
  );

  testWidgets('Mobile: Single column layout without desktop detail pane', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: FlankiApp()));
    await tester.pumpAndSettle();

    // Switch to Browser tab
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    // On mobile (< 900px), 2-pane preview pane should NOT be present
    expect(find.text('MẶT TRƯỚC / CÂU HỎI'), findsNothing);
    // But the card itself is in the single column list
    expect(find.text('Desktop Test Question'), findsOneWidget);
  });
}
