import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/main.dart';
import 'package:flanki/features/exam/models/exam_models.dart';
import 'package:flanki/features/exam/providers/exam_catalog_notifier.dart';
import 'package:flanki/core/localization/locale_notifier.dart';

class TestVietnameseLocaleNotifier extends LocaleNotifier {
  @override
  Locale? build() => const Locale('vi');
}

class FakeExamCatalogNotifier extends ExamCatalogNotifier {
  final List<ExamPaperModel> mockPapers;
  FakeExamCatalogNotifier(this.mockPapers);

  @override
  ExamCatalogState build() {
    return ExamCatalogState(papers: mockPapers);
  }

  @override
  Future<void> loadCatalog() async {
    state = state.copyWith(papers: mockPapers);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_exam_nav_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_exam_nav.db',
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

  final mockPaper = ExamPaperModel(
    id: 'test_exam_01',
    title: 'JLPT N3 Đề Thi Mẫu 01',
    description: 'Đề thi thử JLPT N3',
    category: ExamCategory.jlpt,
    level: 'N3',
    durationMinutes: 105,
    totalQuestions: 35,
    passingScore: 95,
    iconName: 'graduationCap',
    version: 1,
    isPublished: true,
    isDownloaded: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets('Desktop: Navigating to Exams tab renders catalog', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examCatalogProvider.overrideWith(
            () => FakeExamCatalogNotifier([mockPaper]),
          ),
          localeNotifierProvider.overrideWith(TestVietnameseLocaleNotifier.new),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Check that Exams item exists in sidebar
    expect(find.text('Đề thi'), findsWidgets);

    // Tap on Exams nav item
    await tester.tap(find.text('Đề thi').first);
    await tester.pumpAndSettle();

    // Verify catalog header & paper card are rendered
    expect(find.text('Ngân hàng đề thi'), findsOneWidget);
    expect(find.text('JLPT N3 Đề Thi Mẫu 01'), findsOneWidget);
  });

  testWidgets('Desktop: Ctrl+4 shortcut navigates to Exams', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examCatalogProvider.overrideWith(
            () => FakeExamCatalogNotifier([mockPaper]),
          ),
          localeNotifierProvider.overrideWith(TestVietnameseLocaleNotifier.new),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Trigger Ctrl+4 shortcut to switch to Exams tab
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Ngân hàng đề thi'), findsOneWidget);
    expect(find.text('JLPT N3 Đề Thi Mẫu 01'), findsOneWidget);
  });

  testWidgets('Mobile: Bottom bar navigation switches to Exams tab', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examCatalogProvider.overrideWith(
            () => FakeExamCatalogNotifier([mockPaper]),
          ),
          localeNotifierProvider.overrideWith(TestVietnameseLocaleNotifier.new),
        ],
        child: const FlankiApp(),
      ),
    );
    await tester.pumpAndSettle();

    // In bottom nav, find Exams tab and tap it
    expect(find.text('Đề thi'), findsWidgets);
    await tester.tap(find.text('Đề thi').first);
    await tester.pumpAndSettle();

    expect(find.text('Ngân hàng đề thi'), findsOneWidget);
    expect(find.text('JLPT N3 Đề Thi Mẫu 01'), findsOneWidget);
  });
}
