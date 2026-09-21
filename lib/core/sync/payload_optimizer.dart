import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../config/app_config.dart';

/// Utility to remove null and redundant keys from mutation payloads,
/// reducing JSON wire size before transmission.
class SparsePayloadOptimizer {
  const SparsePayloadOptimizer._();

  /// Recursively strips all entries with `null` values from a Map.
  static Map<String, dynamic> cleanMap(Map<String, dynamic> source) {
    final result = <String, dynamic>{};

    for (final entry in source.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      } else if (value is Map<String, dynamic>) {
        result[entry.key] = cleanMap(value);
      } else if (value is List) {
        result[entry.key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return cleanMap(item);
          }
          return item;
        }).toList();
      } else {
        result[entry.key] = value;
      }
    }

    return result;
  }

  /// Cleans the inner `payload` of each mutation dictionary.
  static List<Map<String, dynamic>> cleanMutations(
    List<Map<String, dynamic>> mutations,
  ) {
    return mutations.map((m) {
      final payload = m['payload'];
      if (payload is Map<String, dynamic>) {
        return {...m, 'payload': cleanMap(payload)};
      }
      return m;
    }).toList();
  }
}

/// Helper to compress and decompress data payloads with GZip.
class PayloadCompressor {
  const PayloadCompressor._();

  /// Compresses a JSON-serializable object to GZip binary bytes.
  static Uint8List compressJson(dynamic jsonObject) {
    final jsonStr = jsonEncode(jsonObject);
    final utf8Bytes = utf8.encode(jsonStr);
    final compressed = gzip.encode(utf8Bytes);
    return Uint8List.fromList(compressed);
  }

  /// Decompresses GZip binary bytes back to a decoded JSON structure.
  static dynamic decompressJson(Uint8List compressedBytes) {
    final decompressed = gzip.decode(compressedBytes);
    final jsonStr = utf8.decode(decompressed);
    return jsonDecode(jsonStr);
  }

  /// Calculates the percentage of bandwidth saved: `(1 - compressed / raw) * 100`.
  static double calculateSavingsPercent(int rawBytes, int compressedBytes) {
    if (rawBytes <= 0) return 0.0;
    if (compressedBytes >= rawBytes) return 0.0;
    return ((rawBytes - compressedBytes) / rawBytes) * 100.0;
  }
}

/// Global tracker for network data transferred during sync operations.
class SyncBandwidthTracker {
  static final SyncBandwidthTracker instance = SyncBandwidthTracker._();

  int _bytesSent = 0;
  int _bytesReceived = 0;
  int _bytesSaved = 0;

  SyncBandwidthTracker._();

  int get bytesSent => _bytesSent;
  int get bytesReceived => _bytesReceived;
  int get bytesSaved => _bytesSaved;
  int get totalTransferred => _bytesSent + _bytesReceived;

  /// Records bytes transferred in a sync cycle.
  void recordTransfer({int sent = 0, int received = 0, int saved = 0}) {
    _bytesSent += sent;
    _bytesReceived += received;
    _bytesSaved += saved;
  }

  /// Resets all accumulated counters (used in testing or explicit user reset).
  void reset() {
    _bytesSent = 0;
    _bytesReceived = 0;
    _bytesSaved = 0;
  }

  /// Formats byte counts into human-readable strings (B, KB, MB, GB).
  static String formatBytes(int bytes) {
    if (bytes < AppConfig.bytesPerKb) return '$bytes B';
    if (bytes < AppConfig.bytesPerMb) {
      return '${(bytes / AppConfig.bytesPerKb).toStringAsFixed(1)} KB';
    }
    if (bytes < AppConfig.bytesPerGb) {
      return '${(bytes / AppConfig.bytesPerMb).toStringAsFixed(1)} MB';
    }
    return '${(bytes / AppConfig.bytesPerGb).toStringAsFixed(2)} GB';
  }
}
