import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../states/auth_state.dart';
import '../auth/anki_web_auth_service.dart';

export '../states/auth_state.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
AnkiWebAuthService authService(Ref ref) {
  return AnkiWebAuthService();
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

@Riverpod(keepAlive: true, name: 'authNotifierProvider')
class AuthNotifier extends _$AuthNotifier {
  static const _keyHostKey = 'flanki_ankiweb_hostkey';
  static const _keyEmail = 'flanki_ankiweb_email';
  static const _keyLastSync = 'flanki_ankiweb_last_sync';

  late final FlutterSecureStorage _storage;
  late final AnkiWebAuthService _authService;

  @override
  AuthState build() {
    _storage = ref.read(secureStorageProvider);
    _authService = ref.read(authServiceProvider);

    // Asynchronously restore persisted credentials on startup
    _restoreSession();

    return const AuthState();
  }

  Future<void> _restoreSession() async {
    try {
      final hostKey = await _storage.read(key: _keyHostKey);
      final email = await _storage.read(key: _keyEmail);
      final lastSyncStr = await _storage.read(key: _keyLastSync);

      if (hostKey != null && hostKey.isNotEmpty && email != null) {
        DateTime? lastSync;
        if (lastSyncStr != null) {
          lastSync = DateTime.tryParse(lastSyncStr);
        }
        state = AuthState.authenticated(
          email: email,
          hostKey: hostKey,
          lastSyncedAt: lastSync,
        );
      }
    } catch (_) {
      // Storage read failure, stay unauthenticated
    }
  }

  Future<bool> login(String email, String password) async {
    state = AuthState.authenticating(email: email);

    final result = await _authService.login(
      username: email,
      password: password,
    );

    if (result.success && result.hostKey != null) {
      final now = DateTime.now();
      try {
        await _storage.write(key: _keyHostKey, value: result.hostKey!);
        await _storage.write(key: _keyEmail, value: email);
        await _storage.write(key: _keyLastSync, value: now.toIso8601String());
      } catch (_) {}

      state = AuthState.authenticated(
        email: email,
        hostKey: result.hostKey!,
        lastSyncedAt: now,
      );
      return true;
    } else {
      state = AuthState.error(
        result.error ?? _authService.l10n.authFailed,
        errorCode: result.errorCode,
        email: email,
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: _keyHostKey);
      await _storage.delete(key: _keyEmail);
      await _storage.delete(key: _keyLastSync);
    } catch (_) {}
    state = const AuthState();
  }

  void recordSyncSuccess() {
    if (state.isAuthenticated) {
      final now = DateTime.now();
      _storage.write(key: _keyLastSync, value: now.toIso8601String());
      state = state.copyWith(lastSyncedAt: now);
    }
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.isAuthenticated
          ? AuthState.authenticated(
              email: state.email ?? '',
              hostKey: state.hostKey ?? '',
              lastSyncedAt: state.lastSyncedAt,
            )
          : const AuthState();
    }
  }
}
