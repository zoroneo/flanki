import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import 'breadcrumb_tracker.dart';
import 'error_sanitizer.dart';
import 'error_severity.dart';

/// In-memory representation of an error payload ready for transmission or local queueing.
class ErrorLogItem {
  final String id;
  final String? userId;
  final String fingerprint;
  final ErrorSeverity severity;
  final String errorType;
  final String errorMessage;
  final String? stackTrace;
  final String platform;
  final String appVersion;
  final Map<String, dynamic> deviceInfo;
  final List<Map<String, dynamic>> breadcrumbs;
  int occurrences;
  final DateTime createdAt;

  ErrorLogItem({
    required this.id,
    this.userId,
    required this.fingerprint,
    required this.severity,
    required this.errorType,
    required this.errorMessage,
    this.stackTrace,
    required this.platform,
    required this.appVersion,
    required this.deviceInfo,
    required this.breadcrumbs,
    this.occurrences = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'fingerprint': fingerprint,
      'severity': severity.toDbValue(),
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace,
      'platform': platform,
      'app_version': appVersion,
      'device_info': deviceInfo,
      'breadcrumbs': breadcrumbs,
      'occurrences': occurrences,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toSupabaseMap();

  factory ErrorLogItem.fromJson(Map<String, dynamic> json) {
    return ErrorLogItem(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      fingerprint: json['fingerprint'] as String,
      severity: ErrorSeverity.fromString(json['severity'] as String?),
      errorType: json['error_type'] as String? ?? 'UnknownError',
      errorMessage: json['error_message'] as String? ?? '',
      stackTrace: json['stack_trace'] as String?,
      platform: json['platform'] as String? ?? 'unknown',
      appVersion: json['app_version'] as String? ?? AppConfig.defaultVersion,
      deviceInfo: (json['device_info'] as Map?)?.cast<String, dynamic>() ?? {},
      breadcrumbs: (json['breadcrumbs'] as List?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [],
      occurrences: (json['occurrences'] as int?) ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)?.toLocal()
          : null,
    );
  }
}

/// Core production error logging, deduplication, and crash monitoring service.
class ErrorLogger {
  static final ErrorLogger instance = ErrorLogger._();

  static const String offlineCacheFileName = AppConfig.offlineErrorLogsFileName;
  static const Duration batchInterval = Duration(seconds: AppConfig.errorLogBatchIntervalSeconds);
  static const Duration deduplicationWindow = Duration(seconds: AppConfig.errorLogDeduplicationWindowSeconds);
  static const int maxBatchCapacity = AppConfig.errorLogMaxBatchCapacity;
  static const int maxOfflineQueueCapacity = AppConfig.errorLogMaxOfflineQueueCapacity;

  bool _isInitialized = false;
  bool _isFlushing = false;
  static int _idCounter = 0;
  File? _offlineFile;
  Timer? _batchTimer;

  final List<ErrorLogItem> _batchQueue = [];
  final Map<String, _DedupeEntry> _recentFingerprints = {};

  // For testing injection
  SupabaseClient? _injectedClient;

  ErrorLogger._();

  /// Visible for testing to instantiate isolated logger instances.
  factory ErrorLogger.forTesting({SupabaseClient? supabaseClient, File? offlineFile}) {
    final logger = ErrorLogger._();
    logger._injectedClient = supabaseClient;
    logger._offlineFile = offlineFile;
    logger._isInitialized = true;
    return logger;
  }

  /// Initializes offline storage path and batch timer.
  Future<void> init({File? customOfflineFile}) async {
    if (_isInitialized) return;

    try {
      if (customOfflineFile != null) {
        _offlineFile = customOfflineFile;
      } else if (!kIsWeb) {
        final supportDir = await getApplicationSupportDirectory();
        _offlineFile = File('${supportDir.path}/$offlineCacheFileName');
      }
    } catch (e) {
      debugPrint('[ErrorLogger] Failed to resolve offline cache directory: $e');
    }

    _isInitialized = true;

    // Start periodic batch dispatcher
    _batchTimer?.cancel();
    _batchTimer = Timer.periodic(batchInterval, (_) => flush());

    // Flush any pending logs from previous session
    await _loadPendingOfflineLogs();
    if (_batchQueue.isNotEmpty) {
      await flush();
    }
  }

  /// Captures an unhandled or handled exception.
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) async {
    final effectiveSeverity = fatal ? ErrorSeverity.fatal : severity;
    final rawMessage = exception.toString();
    final sanitizedMessage = ErrorSanitizer.sanitize(
      context != null ? '[$context] $rawMessage' : rawMessage,
    );

    final errorType = exception.runtimeType.toString();
    final rawStackTrace = (stackTrace ?? StackTrace.current).toString();
    final sanitizedStackTrace = ErrorSanitizer.sanitize(rawStackTrace);

    // Compute deterministic fingerprint for grouping
    final fingerprint = _computeFingerprint(errorType, sanitizedStackTrace);

    if (kDebugMode) {
      debugPrint(
        '🚨 [ErrorLogger] [${effectiveSeverity.toDbValue().toUpperCase()}] $sanitizedMessage\n'
        'Fingerprint: $fingerprint',
      );
    }

    // 1. Deduplication check: throttle repeated errors within deduplicationWindow
    final now = DateTime.now();
    _cleanupExpiredDedupeEntries(now);

    final existingDedupe = _recentFingerprints[fingerprint];
    if (existingDedupe != null && now.difference(existingDedupe.timestamp) < deduplicationWindow) {
      existingDedupe.occurrences += 1;
      // Increment count on already queued batch item if still in memory
      for (final item in _batchQueue) {
        if (item.fingerprint == fingerprint) {
          item.occurrences += 1;
          return;
        }
      }
      return;
    }

    _recentFingerprints[fingerprint] = _DedupeEntry(timestamp: now, occurrences: 1);

    // 2. Build error log item
    final breadcrumbsSnapshot = BreadcrumbTracker.instance.toJsonList();
    final deviceInfo = _collectDeviceInfo(extra);
    final userId = _resolveCurrentUserId();

    final truncatedMessage = sanitizedMessage.length > AppConfig.errorLogMaxErrorMessageLength
        ? sanitizedMessage.substring(0, AppConfig.errorLogMaxErrorMessageLength)
        : sanitizedMessage;
    final truncatedStackTrace = sanitizedStackTrace.length > AppConfig.errorLogMaxStackTraceLength
        ? sanitizedStackTrace.substring(0, AppConfig.errorLogMaxStackTraceLength)
        : sanitizedStackTrace;

    final logItem = ErrorLogItem(
      id: _generateLogId(),
      userId: userId,
      fingerprint: fingerprint,
      severity: effectiveSeverity,
      errorType: errorType,
      errorMessage: truncatedMessage,
      stackTrace: truncatedStackTrace.isNotEmpty ? truncatedStackTrace : null,
      platform: _resolvePlatformName(),
      appVersion: AppConfig.fullVersion,
      deviceInfo: deviceInfo,
      breadcrumbs: breadcrumbsSnapshot,
      occurrences: 1,
    );

    _batchQueue.add(logItem);

    // 3. If fatal or batch capacity exceeded, trigger immediate flush
    if (fatal || _batchQueue.length >= maxBatchCapacity) {
      await flush();
    }
  }

  /// Flushes current queued errors to Supabase, falling back to local offline cache on failure.
  Future<void> flush() async {
    if (_isFlushing || _batchQueue.isEmpty) return;
    _isFlushing = true;

    try {
      final itemsToFlush = List<ErrorLogItem>.from(_batchQueue);
      _batchQueue.clear();

      final client = _resolveSupabaseClient();
      final isSupabaseReady = client != null && SupabaseConfig.isConfigured;

      if (!isSupabaseReady) {
        // Store in offline cache
        await _savePendingOfflineLogs(itemsToFlush);
        return;
      }

      try {
        final payload = itemsToFlush.map((item) => item.toSupabaseMap()).toList();
        await client.from(SupabaseConfig.tableAppErrorLogs).insert(payload);
      } catch (e) {
        debugPrint('[ErrorLogger] Failed to push error logs to Supabase: $e');
        // Re-queue or save offline so logs are not lost
        await _savePendingOfflineLogs(itemsToFlush);
      }
    } finally {
      _isFlushing = false;
    }
  }

  /// Computes an MD5 fingerprint from the error type and top stack frame.
  String _computeFingerprint(String errorType, String stackTrace) {
    String topFrame = '';
    final lines = stackTrace.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      // Skip generic error header lines, find first frame
      if (trimmed.startsWith('#0') || trimmed.startsWith('#1')) {
        topFrame = trimmed;
        break;
      }
    }
    if (topFrame.isEmpty && lines.isNotEmpty) {
      topFrame = lines.first.trim();
    }

    final rawKey = '$errorType::$topFrame';
    return md5.convert(utf8.encode(rawKey)).toString();
  }

  /// Removes expired entries from the deduplication memory cache.
  void _cleanupExpiredDedupeEntries(DateTime now) {
    _recentFingerprints.removeWhere(
      (_, entry) => now.difference(entry.timestamp) > deduplicationWindow,
    );
  }

  /// Resolves current authenticated user UUID if available.
  String? _resolveCurrentUserId() {
    try {
      final client = _resolveSupabaseClient();
      return client?.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  /// Resolves active SupabaseClient.
  SupabaseClient? _resolveSupabaseClient() {
    if (_injectedClient != null) return _injectedClient;
    try {
      if (SupabaseConfig.isConfigured) {
        return Supabase.instance.client;
      }
    } catch (_) {}
    return null;
  }

  /// Collects standardized device and runtime telemetry.
  Map<String, dynamic> _collectDeviceInfo(Map<String, dynamic>? extra) {
    final info = <String, dynamic>{
      'locale': Platform.localeName,
      'os_version': Platform.operatingSystemVersion,
      'is_debug': kDebugMode,
      'is_release': kReleaseMode,
    };
    if (extra != null && extra.isNotEmpty) {
      info['extra'] = ErrorSanitizer.sanitizeData(extra);
    }
    return info;
  }

  /// Resolves canonical platform string.
  String _resolvePlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  /// Generates pseudo-UUID for local log identification.
  String _generateLogId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final randomKey = '${Platform.operatingSystem}_${now}_${++_idCounter}';
    final hash = md5.convert(utf8.encode(randomKey)).toString();
    return '${hash.substring(0, 8)}-${hash.substring(8, 12)}-4${hash.substring(13, 16)}-a${hash.substring(17, 20)}-${hash.substring(20, 32)}';
  }

  /// Persists unsent error logs to local file.
  Future<void> _savePendingOfflineLogs(List<ErrorLogItem> items) async {
    final file = _offlineFile;
    if (file == null) return;

    try {
      final existing = <ErrorLogItem>[];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content) as List;
          existing.addAll(decoded.map((e) => ErrorLogItem.fromJson(e as Map<String, dynamic>)));
        }
      }

      existing.addAll(items);
      // Cap maximum offline records to prevent unbounded disk growth
      if (existing.length > maxOfflineQueueCapacity) {
        existing.removeRange(0, existing.length - maxOfflineQueueCapacity);
      }

      final jsonPayload = jsonEncode(existing.map((e) => e.toJson()).toList());
      await file.writeAsString(jsonPayload, flush: true);
    } catch (e) {
      debugPrint('[ErrorLogger] Failed to write offline logs: $e');
    }
  }

  /// Reads and restores pending logs from offline file.
  Future<void> _loadPendingOfflineLogs() async {
    final file = _offlineFile;
    if (file == null) return;

    try {
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final decoded = jsonDecode(content) as List;
          final loadedItems = decoded
              .map((e) => ErrorLogItem.fromJson(e as Map<String, dynamic>))
              .toList();
          _batchQueue.insertAll(0, loadedItems);
        }
        await file.delete();
      }
    } catch (e) {
      debugPrint('[ErrorLogger] Failed to load offline logs: $e');
    }
  }

  /// Disposes timers.
  void dispose() {
    _batchTimer?.cancel();
    _batchTimer = null;
  }
}

class _DedupeEntry {
  DateTime timestamp;
  int occurrences;

  _DedupeEntry({required this.timestamp, required this.occurrences});
}

