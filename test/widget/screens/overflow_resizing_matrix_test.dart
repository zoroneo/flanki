import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';
import 'package:flanki/features/grammar/ui/widgets/choice_question_widget.dart';
import 'package:flanki/features/grammar/ui/widgets/cloze_question_widget.dart';
import 'package:flanki/features/settings/models/update_info.dart';
import 'package:flanki/features/settings/ui/settings_screen.dart';
import 'package:flanki/features/settings/ui/widgets/update_dialog.dart';
import 'package:flanki/features/stats/ui/stats_screen.dart';
import 'package:flanki/features/study/ui/widgets/study_rating_bar.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/features/sync/ui/anki_web_auth_sheet.dart';
import 'package:flanki/features/sync/ui/widgets/sync_conflict_dialog.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:flanki/main.dart';

import '../../helpers/overflow_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('flanki_overflow_test_');
    await DatabaseService.instance.init(
      customPath: '${tempDir.path}/test_overflow.db',
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

  Widget wrapWithTheme(Widget child, [Locale locale = const Locale('vi')]) {
    return ShadcnApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShadcnLocalizationsViDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(child: child),
    );
  }

  group('Pha 3: Viewport & Scale Matrix Tests (Zero Overflow Guarantee)', () {
    testWidgets(
      'FlankiApp renders without overflow on Small Mobile (320x568)',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          const ProviderScope(child: FlankiApp()),
          size: TestViewports.smallMobile,
          textScale: 1.0,
        );
        expect(find.text('Flanki'), findsAtLeast(1));
      },
    );

    testWidgets(
      'FlankiApp renders without overflow on Small Mobile with A11y Scale (1.5x)',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          const ProviderScope(child: FlankiApp()),
          size: TestViewports.smallMobile,
          textScale: 1.5,
        );
        expect(find.text('Flanki'), findsAtLeast(1));
      },
    );

    testWidgets(
      'FlankiApp renders without overflow on Standard Mobile (390x844)',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          const ProviderScope(child: FlankiApp()),
          size: TestViewports.standardMobile,
          textScale: 1.0,
        );
        expect(find.text('Flanki'), findsAtLeast(1));
      },
    );

    testWidgets('FlankiApp renders without overflow on Tablet (768x1024)', (
      WidgetTester tester,
    ) async {
      await pumpAndAssertNoOverflow(
        tester,
        const ProviderScope(child: FlankiApp()),
        size: TestViewports.tablet,
        textScale: 1.0,
      );
      expect(find.text('Flanki'), findsAtLeast(1));
    });

    testWidgets('FlankiApp renders without overflow on Desktop (1280x800)', (
      WidgetTester tester,
    ) async {
      await pumpAndAssertNoOverflow(
        tester,
        const ProviderScope(child: FlankiApp()),
        size: TestViewports.desktop,
        textScale: 1.0,
      );
      expect(find.text('Flanki'), findsAtLeast(1));
    });

    testWidgets(
      'SyncConflictDialog renders without overflow in Mobile BottomSheet at 320px',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          wrapWithTheme(
            SyncConflictDialog(
              localLastSync: DateTime(2026, 9, 12, 10, 30),
              serverMod: DateTime(2026, 9, 12, 11, 45),
              isBottomSheet: true,
            ),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );

    testWidgets(
      'SyncConflictDialog renders without overflow in Desktop Modal at 1280px',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          wrapWithTheme(
            SyncConflictDialog(
              localLastSync: DateTime(2026, 9, 12, 10, 30),
              serverMod: DateTime(2026, 9, 12, 11, 45),
              isBottomSheet: false,
            ),
          ),
          size: TestViewports.desktop,
          textScale: 1.0,
        );
      },
    );

    testWidgets(
      'UpdateDialog responsive layout switches to Column below 420px without overflow',
      (WidgetTester tester) async {
        const updateInfo = UpdateInfo(
          currentVersion: '1.0.0',
          latestVersion: '1.1.0',
          hasUpdate: true,
          releaseNotes: 'Fixed bug and improved dimension standardization.',
          releaseUrl: 'https://github.com/flanki/releases/v1.1.0',
          downloadUrl:
              'https://github.com/flanki/releases/download/v1.1.0/flanki.exe',
        );

        await pumpAndAssertNoOverflow(
          tester,
          ProviderScope(
            child: wrapWithTheme(const UpdateDialog(updateInfo: updateInfo)),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );

    testWidgets(
      'AnkiWebAuthSheet renders without overflow on narrow viewport (320px)',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          ProviderScope(
            child: wrapWithTheme(const AnkiWebAuthSheet(isDesktop: false)),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );

    testWidgets(
      'SettingsScreen renders without overflow on 320px with 1.3x text scale',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          ProviderScope(child: wrapWithTheme(const SettingsScreen())),
          size: TestViewports.smallMobile,
          textScale: 1.3,
        );
      },
    );

    testWidgets(
      'StatsScreen renders without overflow on 320px with 1.3x text scale',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          ProviderScope(child: wrapWithTheme(const StatsScreen())),
          size: TestViewports.smallMobile,
          textScale: 1.3,
        );
      },
    );

    testWidgets(
      'Grammar ChoiceQuestionWidget renders without overflow at 320px width',
      (WidgetTester tester) async {
        const exercise = GrammarExercise(
          id: 'ex_choice_overflow_test',
          type: GrammarExerciseType.choice,
          difficulty: GrammarDifficulty.recognition,
          prompt: 'This is a long sentence testing whether the widget handles long text prompts properly.',
          options: [
            'First option is slightly longer than usual',
            'Second option',
            'Third option with details',
            'Fourth option',
          ],
          correctAnswer: 'Second option',
          explanation: GrammarExplanation.empty,
        );

        await pumpAndAssertNoOverflow(
          tester,
          wrapWithTheme(
            ChoiceQuestionWidget(
              exercise: exercise,
              selectedAnswer: null,
              isSubmitted: false,
              onSelectAnswer: (_) {},
            ),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );

    testWidgets(
      'Grammar ClozeQuestionWidget renders without overflow at 320px width',
      (WidgetTester tester) async {
        const exercise = GrammarExercise(
          id: 'ex_cloze_overflow_test',
          type: GrammarExerciseType.cloze,
          difficulty: GrammarDifficulty.production,
          prompt: 'She {has lived} in Tokyo for five years.',
          options: [],
          correctAnswer: 'has lived',
          explanation: GrammarExplanation.empty,
        );

        await pumpAndAssertNoOverflow(
          tester,
          wrapWithTheme(
            ClozeQuestionWidget(
              exercise: exercise,
              selectedAnswer: '',
              isSubmitted: false,
              isCorrect: null,
              onAnswerChanged: (_) {},
              onSubmit: () {},
            ),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );

    testWidgets(
      'StudyRatingBar renders without overflow on 320px width with 1.2x text scale',
      (WidgetTester tester) async {
        await pumpAndAssertNoOverflow(
          tester,
          wrapWithTheme(
            StudyRatingBar(
              intervals: const {
                ReviewRating.again: '< 10m',
                ReviewRating.hard: '1d',
                ReviewRating.good: '4d',
                ReviewRating.easy: '7d',
              },
              isMobile: true,
              onRate: (_) {},
            ),
          ),
          size: TestViewports.smallMobile,
          textScale: 1.2,
        );
      },
    );
  });
}
