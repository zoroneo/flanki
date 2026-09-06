import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/core/localization/locale_notifier.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    test('AppLocalizations supports en and vi', () {
      expect(AppLocalizations.supportedLocales, containsAll([
        const Locale('en'),
        const Locale('vi'),
      ]));
    });

    test('English translations load correctly', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10nEn.navDecks, 'Decks');
      expect(l10nEn.navBrowser, 'Browser');
      expect(l10nEn.navStats, 'Stats');
      expect(l10nEn.navSettings, 'Settings');
      expect(l10nEn.studyNow, 'Study Now');
      expect(l10nEn.cardsCount(5), '5 cards');
    });

    test('Vietnamese translations load correctly', () async {
      final l10nVi = await AppLocalizations.delegate.load(const Locale('vi'));
      expect(l10nVi.navDecks, 'Bộ thẻ');
      expect(l10nVi.navBrowser, 'Tìm thẻ');
      expect(l10nVi.navStats, 'Thống kê');
      expect(l10nVi.navSettings, 'Cài đặt');
      expect(l10nVi.studyNow, 'Học ngay');
      expect(l10nVi.cardsCount(5), '5 thẻ');
    });

    test('LocaleNotifier can update and reset state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeNotifierProvider), isNull);

      await container.read(localeNotifierProvider.notifier).setLocale(const Locale('vi'));
      expect(container.read(localeNotifierProvider), const Locale('vi'));

      await container.read(localeNotifierProvider.notifier).setLocale(const Locale('en'));
      expect(container.read(localeNotifierProvider), const Locale('en'));

      await container.read(localeNotifierProvider.notifier).setLocale(null);
      expect(container.read(localeNotifierProvider), isNull);
    });
  });
}
