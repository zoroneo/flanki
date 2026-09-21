import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Secure session storage adapter for Supabase Flutter SDK.
/// Encrypts access and refresh tokens using platform hardware:
/// - Android: Android Keystore + EncryptedSharedPreferences
/// - iOS / macOS: Keychain Services
/// - Windows: Windows Data Protection API (DPAPI)
/// - Linux: libsecret
class SupabaseSecureStorage extends LocalStorage {
  static const String _logTag = '[SecureStorage]';

  final FlutterSecureStorage _storage;
  final String sessionKey;
  final Map<String, String> _memoryFallback = {};

  SupabaseSecureStorage({FlutterSecureStorage? storage, String? sessionKey})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          ),
      sessionKey = sessionKey ?? SupabaseConfig.sessionStorageKey;

  @override
  Future<void> initialize() async {
    // No-op for secure storage
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      final token = await _storage.read(key: sessionKey);
      return token != null && token.isNotEmpty;
    } catch (_) {
      return _memoryFallback.containsKey(sessionKey);
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      final token = await _storage.read(key: sessionKey);
      if (token != null) return token;
    } catch (e) {
      debugPrint('$_logTag Failed reading session: $e');
    }
    return _memoryFallback[sessionKey];
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _storage.write(key: sessionKey, value: persistSessionString);
    } catch (e) {
      debugPrint('$_logTag Failed writing session: $e');
      _memoryFallback[sessionKey] = persistSessionString;
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _storage.delete(key: sessionKey);
    } catch (e) {
      debugPrint('$_logTag Failed deleting session: $e');
    }
    _memoryFallback.remove(sessionKey);
  }
}
