import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'theme_notifier.g.dart';

const String _kThemeModeStorageKey = 'user_selected_theme_mode';

@Riverpod(keepAlive: true, name: 'themeNotifierProvider')
class ThemeNotifier extends _$ThemeNotifier {
  final _storage = const FlutterSecureStorage();

  @override
  ThemeMode build() {
    _loadSavedThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadSavedThemeMode() async {
    try {
      final savedMode = await _storage.read(key: _kThemeModeStorageKey);
      if (savedMode != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // Keep system default on error
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      await _storage.write(key: _kThemeModeStorageKey, value: mode.name);
    } catch (_) {}
  }
}
