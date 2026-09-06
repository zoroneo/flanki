import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _kFsrsEnabledKey = 'settings_fsrs_enabled';

final fsrsEnabledProvider = NotifierProvider<FsrsEnabledNotifier, bool>(
  FsrsEnabledNotifier.new,
);

class FsrsEnabledNotifier extends Notifier<bool> {
  final _storage = const FlutterSecureStorage();

  @override
  bool build() {
    _loadPreference();
    return true; // Default to true (FSRS v5 enabled)
  }

  Future<void> _loadPreference() async {
    try {
      final val = await _storage.read(key: _kFsrsEnabledKey);
      if (val != null) {
        state = val == 'true';
      }
    } catch (_) {}
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    try {
      await _storage.write(key: _kFsrsEnabledKey, value: enabled ? 'true' : 'false');
    } catch (_) {}
  }
}
