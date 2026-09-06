import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/generated/app_localizations.dart';

const String _kLocaleStorageKey = 'user_selected_locale';

final localeNotifierProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  final _storage = const FlutterSecureStorage();

  @override
  Locale? build() {
    _loadSavedLocale();
    return null; // Defaults to system locale until loaded
  }

  Future<void> _loadSavedLocale() async {
    try {
      final savedCode = await _storage.read(key: _kLocaleStorageKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        state = Locale(savedCode);
      }
    } catch (_) {
      // Keep null (system locale) on read error
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      if (locale == null) {
        await _storage.delete(key: _kLocaleStorageKey);
      } else {
        await _storage.write(key: _kLocaleStorageKey, value: locale.languageCode);
      }
    } catch (_) {}
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
