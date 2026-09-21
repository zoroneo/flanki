import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/storage/supabase_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseSecureStorage Unit Tests', () {
    test('persistSession, accessToken, hasAccessToken, and removePersistedSession lifecycle', () async {
      final storage = SupabaseSecureStorage();

      await storage.initialize();

      // Initially empty
      final initialHas = await storage.hasAccessToken();
      expect(initialHas, isFalse);

      final initialToken = await storage.accessToken();
      expect(initialToken, isNull);

      // Persist session string
      const sampleSession =
          '{"access_token":"mock_jwt_token","refresh_token":"mock_refresh_token"}';
      await storage.persistSession(sampleSession);

      final hasAfter = await storage.hasAccessToken();
      expect(hasAfter, isTrue);

      final tokenAfter = await storage.accessToken();
      expect(tokenAfter, equals(sampleSession));

      // Remove session
      await storage.removePersistedSession();

      final hasRemoved = await storage.hasAccessToken();
      expect(hasRemoved, isFalse);

      final tokenRemoved = await storage.accessToken();
      expect(tokenRemoved, isNull);
    });

    test('respects custom sessionKey and defaults to SupabaseConfig.sessionStorageKey', () async {
      final defaultStorage = SupabaseSecureStorage();
      expect(defaultStorage.sessionKey, equals('supabase_session'));

      final customStorage = SupabaseSecureStorage(sessionKey: 'custom_key_123');
      expect(customStorage.sessionKey, equals('custom_key_123'));

      await customStorage.persistSession('custom_val');
      expect(await customStorage.accessToken(), equals('custom_val'));
      expect(await customStorage.hasAccessToken(), isTrue);

      await customStorage.removePersistedSession();
      expect(await customStorage.hasAccessToken(), isFalse);
    });
  });
}
