import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:flanki/core/widgets/audio_play_button.dart';
import 'package:flanki/core/widgets/rich_card_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(Widget child, {ThemeData? theme}) {
    return ShadcnApp(
      theme: theme ?? const ThemeData(colorScheme: ColorSchemes.lightZinc),
      locale: const Locale('vi'),
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

  group('RichCardContent Enhanced Formatting Tests', () {
    testWidgets('renders default centered crossAxisAlignment', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(const RichCardContent(content: '<b>Hello</b> World')),
      );
      await tester.pumpAndSettle();

      final richCard = find.byType(RichCardContent);
      expect(richCard, findsOneWidget);

      final columnFinder = find.descendant(
        of: richCard,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);

      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.center));
      expect(find.byType(HtmlWidget), findsOneWidget);
    });

    testWidgets('renders custom start crossAxisAlignment and left textAlign', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const RichCardContent(
            content: 'Line 1\nLine 2\nLine 3',
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final richCard = find.byType(RichCardContent);
      expect(richCard, findsOneWidget);

      final columnFinder = find.descendant(
        of: richCard,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);

      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));

      final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
      expect(htmlWidget.html, contains('text-align: left'));
      expect(htmlWidget.html, contains('<br/>'));
    });

    testWidgets(
      'preserves existing html without inserting extra breaks on block tags',
      (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const RichCardContent(
              content: '<p>Paragraph 1</p><p>Paragraph 2</p>',
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
        expect(
          htmlWidget.html,
          contains('<p>Paragraph 1</p><p>Paragraph 2</p>'),
        );
      },
    );

    testWidgets(
      'backward compatibility: plain text without tags renders cleanly',
      (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const RichCardContent(
              content: 'Plain unformatted text with no tags at all.',
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
        expect(
          htmlWidget.html,
          contains('Plain unformatted text with no tags at all.'),
        );
      },
    );

    testWidgets(
      'rich HTML formatting tags (b, u, mark, span, code) render without issues',
      (tester) async {
        const richSample =
            '<b>Bold</b> <u>Underline</u> <mark>Highlight</mark> <span style="color: #22c55e;">Green</span> <code>code</code>';
        await tester.pumpWidget(
          wrapWithTheme(
            const RichCardContent(
              content: richSample,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
        expect(htmlWidget.html, contains('<b>Bold</b>'));
        expect(htmlWidget.html, contains('<u>Underline</u>'));
        expect(htmlWidget.html, contains('<mark>Highlight</mark>'));
        expect(htmlWidget.html, contains('<code>code</code>'));
      },
    );

    testWidgets(
      'renders audio button inline next to vocabulary label without trailing Wrap',
      (tester) async {
        await tester.pumpWidget(
          wrapWithTheme(
            const RichCardContent(
              content: 'Vocabulary [sound:test.mp3]',
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // No separate bottom Wrap
        expect(find.byType(Wrap), findsNothing);

        // Audio play button is rendered inline inside HtmlWidget without raw filename text
        expect(find.byType(AudioPlayButton), findsOneWidget);
        expect(find.text('test.mp3'), findsNothing);
        expect(find.byIcon(LucideIcons.volume2), findsOneWidget);
      },
    );

    testWidgets(
      'renders audio buttons directly inline with Keyword, Meaning, Example labels',
      (tester) async {
        const cardContent = '''
<div>Keyword [sound:4000B1_agree.mp3]</div>
<div>Meaning [sound:4000B1_agree_meaning.mp3]</div>
<div>Example [sound:4000B1_agree_example.mp3]</div>
''';
        await tester.pumpWidget(
          wrapWithTheme(
            const RichCardContent(
              content: cardContent,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // All audio buttons rendered inline with their respective labels without raw filenames
        expect(find.byType(AudioPlayButton), findsNWidgets(3));
        expect(find.text('4000B1_agree.mp3'), findsNothing);
        expect(find.text('4000B1_agree_meaning.mp3'), findsNothing);
        expect(find.text('4000B1_agree_example.mp3'), findsNothing);
        expect(find.byIcon(LucideIcons.volume2), findsNWidgets(3));
        expect(find.byType(Wrap), findsNothing);
      },
    );

    testWidgets('renders type result box in place within HtmlWidget', (
      tester,
    ) async {
      const cardContent = '''
<div>Book 1 - Card No.: 2</div>
<div>[[TYPE_RESULT:agree]]</div>
<div>[ə'griː]</div>
''';
      await tester.pumpWidget(
        wrapWithTheme(
          const RichCardContent(content: cardContent, typedAnswer: 'agree'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('agree'), findsOneWidget);
      expect(find.byIcon(LucideIcons.circleCheck), findsOneWidget);
    });

    testWidgets('adapts hardcoded dark colors and audio labels for dark mode', (
      tester,
    ) async {
      const cardContent = '''
<div style='font-family: Arial; font-size: 22px;color:black;text-align:center;'>experiment</div>
<div style='font-family: Arial; font-size: 20px;color:black;text-align:center;'>[ɪk'spɛrɪmənt]</div>
<div style='font-family: Arial; font-size: 22px;color:blue;text-align:center;'>thí nghiệm</div>
<div style='font-family: Arial; font-size: 18px;color:black;text-align:left;'>Keyword [sound:experiment.mp3]</div>
<div style='font-family: Arial; font-size: 18px;color:black;text-align:left;'>Meaning [sound:meaning.mp3]</div>
''';
      await tester.pumpWidget(
        wrapWithTheme(
          const RichCardContent(content: cardContent),
          theme: const ThemeData(colorScheme: ColorSchemes.darkZinc),
        ),
      );
      await tester.pumpAndSettle();

      // HtmlWidget renders formatted content
      final htmlWidget = tester.widget<HtmlWidget>(find.byType(HtmlWidget));
      // Hardcoded color:black should be adapted to color: inherit in dark mode
      expect(htmlWidget.html, isNot(contains('color:black')));
      expect(htmlWidget.html, contains('color: inherit'));
      // Non-dark color (blue) is preserved
      expect(htmlWidget.html, contains('color:blue'));

      // Audio buttons are properly rendered inline
      expect(find.byType(AudioPlayButton), findsNWidgets(2));
    });
  });
}
