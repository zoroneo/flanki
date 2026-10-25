import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/localization/locale_notifier.dart';
import 'package:flanki/core/localization/shadcn_localizations_vi.dart';
import 'package:flanki/core/theme/theme_notifier.dart';
import 'package:flanki/features/settings/ui/widgets/app_preferences_card.dart';
import 'package:flanki/features/settings/ui/widgets/settings_info_rows.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TestLocaleNotifier extends LocaleNotifier {
  final Locale? _initial;
  TestLocaleNotifier(this._initial);

  @override
  Locale? build() => _initial;
}

class TestThemeNotifier extends ThemeNotifier {
  final ThemeMode _initial;
  TestThemeNotifier(this._initial);

  @override
  ThemeMode build() => _initial;
}

Widget createPreferencesTestWidget({
  required Widget child,
  Locale? locale,
  ThemeMode? themeMode,
}) {
  return ProviderScope(
    overrides: [
      if (locale != null)
        localeNotifierProvider.overrideWith(() => TestLocaleNotifier(locale)),
      if (themeMode != null)
        themeNotifierProvider.overrideWith(() => TestThemeNotifier(themeMode)),
    ],
    child: ShadcnApp(
      locale: locale ?? const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShadcnLocalizationsViDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 320, // Constrained width simulating responsive narrow column
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesCard responsive button height tests', () {
    testWidgets('all theme buttons have identical height in narrow column', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createPreferencesTestWidget(child: const AppPreferencesCard()),
      );
      await tester.pumpAndSettle();

      final buttons = tester
          .widgetList<LanguageOptionButton>(find.byType(LanguageOptionButton))
          .toList();

      expect(buttons.length, 6); // 3 language buttons + 3 theme buttons

      // Check Appearance / Theme buttons (last 3 buttons)
      final themeButtonFinders = find
          .byType(LanguageOptionButton)
          .evaluate()
          .skip(3)
          .map((element) => find.byWidget(element.widget))
          .toList();

      expect(themeButtonFinders.length, 3);

      final height1 = tester.getSize(themeButtonFinders[0]).height;
      final height2 = tester.getSize(themeButtonFinders[1]).height;
      final height3 = tester.getSize(themeButtonFinders[2]).height;

      expect(height1, equals(height2));
      expect(height2, equals(height3));
    });

    testWidgets('all language buttons have identical height in narrow column', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createPreferencesTestWidget(
          locale: const Locale('vi'),
          child: const AppPreferencesCard(),
        ),
      );
      await tester.pumpAndSettle();

      final languageButtonFinders = find
          .byType(LanguageOptionButton)
          .evaluate()
          .take(3)
          .map((element) => find.byWidget(element.widget))
          .toList();

      expect(languageButtonFinders.length, 3);

      final height1 = tester.getSize(languageButtonFinders[0]).height;
      final height2 = tester.getSize(languageButtonFinders[1]).height;
      final height3 = tester.getSize(languageButtonFinders[2]).height;

      expect(height1, equals(height2));
      expect(height2, equals(height3));
    });

    testWidgets('LanguageOptionButton has minHeight >= 38.0', (tester) async {
      await tester.pumpWidget(
        ShadcnApp(
          home: Scaffold(
            child: LanguageOptionButton(
              label: 'Test',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(LanguageOptionButton));
      expect(size.height, greaterThanOrEqualTo(38.0));
    });
  });
}
