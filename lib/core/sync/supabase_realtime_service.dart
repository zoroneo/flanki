import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Service that subscribes to Supabase Realtime WebSocket changes on business tables
/// filtered by `user_id`. When remote changes occur (e.g. studied on another device),
/// it triggers a debounced callback to pull the latest deltas immediately.
class SupabaseRealtimeService {
  static const String _logTag = '[RealtimeSync]';

  final SupabaseClient? _client;
  final Duration debounceDuration;

  RealtimeChannel? _channel;
  Timer? _debounceTimer;
  String? _subscribedUserId;
  bool _isSubscribed = false;
  RealtimeSubscribeStatus? _lastStatus;

  void Function()? onRemoteChangeDetected;
  void Function(RealtimeSubscribeStatus status)? onStatusChanged;

  SupabaseRealtimeService({
    SupabaseClient? client,
    this.debounceDuration = SupabaseConfig.defaultRealtimeDebounce,
    this.onStatusChanged,
  }) : _client = client ?? _getSupabaseClientSafe();

  static SupabaseClient? _getSupabaseClientSafe() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isSubscribed => _isSubscribed;
  String? get subscribedUserId => _subscribedUserId;
  RealtimeSubscribeStatus? get status => _lastStatus;

  /// Subscribes to Postgres CDC events on public tables for [userId].
  void subscribe(String userId, {void Function()? onRemoteChange}) {
    if (userId.isEmpty) return;

    if (onRemoteChange != null) {
      onRemoteChangeDetected = onRemoteChange;
    }

    // Already subscribed to this user
    if (_isSubscribed && _subscribedUserId == userId && _channel != null) {
      return;
    }

    unsubscribe();

    final client = _client;
    if (client == null) {
      debugPrint(
        '$_logTag SupabaseClient not available. Skipping subscription.',
      );
      return;
    }

    _subscribedUserId = userId;

    try {
      final channelName = '${SupabaseConfig.realtimeSyncChannel}_$userId';
      _channel = client.channel(channelName);

      // Listen on public schema tables filtered by user_id
      for (final table in SupabaseConfig.realtimeSubscribedTables) {
        _channel = _channel!.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: SupabaseConfig.schemaPublic,
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: SupabaseConfig.columnUserId,
            value: userId,
          ),
          callback: (payload) {
            _handlePostgresChange(payload);
          },
        );
      }

      _channel!.subscribe((status, error) {
        _lastStatus = status;
        onStatusChanged?.call(status);

        if (status == RealtimeSubscribeStatus.subscribed) {
          _isSubscribed = true;
          debugPrint('$_logTag Connected to channel: $channelName');
        } else if (status == RealtimeSubscribeStatus.channelError) {
          debugPrint('$_logTag Channel error: $error');
        } else if (status == RealtimeSubscribeStatus.timedOut) {
          debugPrint('$_logTag Subscription timed out');
        }
      });
    } catch (e) {
      debugPrint('$_logTag Failed to subscribe: $e');
      _isSubscribed = false;
    }
  }

  /// Handles incoming Postgres CDC event and debounces sync trigger.
  void _handlePostgresChange(PostgresChangePayload payload) {
    debugPrint(
      '$_logTag Received change on table ${payload.table} (${payload.eventType})',
    );
    notifyRemoteEvent();
  }

  /// Notifies with debounce to prevent flood during batch inserts/updates.
  void notifyRemoteEvent() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      onRemoteChangeDetected?.call();
    });
  }

  /// Unsubscribes from current Realtime channel and clears timers.
  void unsubscribe() {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (_channel != null) {
      try {
        _client?.removeChannel(_channel!);
      } catch (e) {
        debugPrint('$_logTag Error removing channel: $e');
      }
      _channel = null;
    }

    _isSubscribed = false;
    _subscribedUserId = null;
    _lastStatus = null;
  }

  void dispose() {
    unsubscribe();
    onRemoteChangeDetected = null;
    onStatusChanged = null;
  }
}
