import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flanki/core/config/supabase_config.dart';
import 'package:flanki/core/sync/supabase_realtime_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseRealtimeService Unit Tests', () {
    test(
      'notifyRemoteEvent debounces rapid triggers into a single invocation',
      () async {
        final realtimeService = SupabaseRealtimeService(
          client: null,
          debounceDuration: const Duration(milliseconds: 50),
        );

        int callbackCount = 0;
        realtimeService.onRemoteChangeDetected = () {
          callbackCount++;
        };

        // Rapidly fire multiple remote events
        realtimeService.notifyRemoteEvent();
        realtimeService.notifyRemoteEvent();
        realtimeService.notifyRemoteEvent();
        realtimeService.notifyRemoteEvent();

        // Immediately, callback has not fired yet due to debounce
        expect(callbackCount, equals(0));

        // Wait for debounce period to expire
        await Future.delayed(const Duration(milliseconds: 80));

        expect(callbackCount, equals(1));

        realtimeService.dispose();
      },
    );

    test('unsubscribe clears timers and resets state', () async {
      final realtimeService = SupabaseRealtimeService(
        client: null,
        debounceDuration: const Duration(milliseconds: 50),
      );

      int callbackCount = 0;
      realtimeService.onRemoteChangeDetected = () {
        callbackCount++;
      };

      realtimeService.notifyRemoteEvent();
      realtimeService.unsubscribe();

      // Wait past debounce duration
      await Future.delayed(const Duration(milliseconds: 80));

      // Should not have fired because timer was cancelled in unsubscribe
      expect(callbackCount, equals(0));
      expect(realtimeService.isSubscribed, isFalse);
      expect(realtimeService.subscribedUserId, isNull);

      realtimeService.dispose();
    });

    test('subscribe ignores empty userId safely', () {
      final realtimeService = SupabaseRealtimeService(client: null);

      realtimeService.subscribe('');
      expect(realtimeService.isSubscribed, isFalse);
      expect(realtimeService.subscribedUserId, isNull);

      realtimeService.dispose();
    });

    test('realtimeSubscribedTables contains all expected business tables', () {
      expect(
        SupabaseConfig.realtimeSubscribedTables,
        containsAll([
          'decks',
          'cards',
          'review_logs',
          'grammar_progress',
          'user_media',
        ]),
      );
      expect(SupabaseConfig.schemaPublic, equals('public'));
      expect(SupabaseConfig.columnUserId, equals('user_id'));
    });

    test('onStatusChanged callback is stored and nullable', () {
      RealtimeSubscribeStatus? reportedStatus;
      final service = SupabaseRealtimeService(
        client: null,
        onStatusChanged: (status) {
          reportedStatus = status;
        },
      );

      expect(service.status, isNull);
      expect(reportedStatus, isNull);
      service.dispose();
    });
  });
}
