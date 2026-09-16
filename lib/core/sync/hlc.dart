import 'dart:math' as math;

import '../config/app_config.dart';

class ClockDriftException implements Exception {
  final int driftMillis;
  final int maxDriftMillis;

  const ClockDriftException(this.driftMillis, this.maxDriftMillis);

  @override
  String toString() =>
      'ClockDriftException: Clock drift ($driftMillis ms) exceeds maximum allowed threshold ($maxDriftMillis ms)';
}

/// Hybrid Logical Clock (HLC) implementation for monotonic, causal time-ordering
/// in distributed local-first sync systems.
///
/// Serialized format:
/// `<ISO-8601-UTC>_<counter-4-hex>_<node-id>`
/// Example: `2026-09-16T12:00:00.000Z_0001_node1`
class Hlc implements Comparable<Hlc> {
  final int millis;
  final int counter;
  final String nodeId;

  /// Default maximum physical clock drift allowed (from AppConfig, 60 seconds).
  static const int defaultMaxDriftMillis = AppConfig.defaultMaxClockDriftMillis;

  const Hlc(this.millis, this.counter, this.nodeId)
    : assert(millis >= 0, 'millis must be non-negative'),
      assert(counter >= 0, 'counter must be non-negative'),
      assert(nodeId.length > 0, 'nodeId cannot be empty');

  /// Creates an HLC for the current system time with counter 0.
  factory Hlc.now(String nodeId, {int? wallTime}) {
    final now = wallTime ?? DateTime.now().toUtc().millisecondsSinceEpoch;
    return Hlc(now, 0, nodeId);
  }

  /// Generates the next HLC when sending a local mutation.
  ///
  /// Guarantees that the new HLC is strictly greater than [lastHlc] (monotonicity).
  factory Hlc.send(
    Hlc? lastHlc,
    String nodeId, {
    int maxDriftMillis = defaultMaxDriftMillis,
    int? wallTime,
  }) {
    final physicalNow =
        wallTime ?? DateTime.now().toUtc().millisecondsSinceEpoch;

    if (lastHlc == null) {
      return Hlc(physicalNow, 0, nodeId);
    }

    // Normal forward progress
    if (physicalNow > lastHlc.millis) {
      return Hlc(physicalNow, 0, nodeId);
    }

    // Same millisecond
    if (physicalNow == lastHlc.millis) {
      return Hlc(lastHlc.millis, lastHlc.counter + 1, nodeId);
    }

    // Physical clock rewound into the past (backward drift)
    // Maintain monotonicity by using lastHlc.millis and incrementing counter.
    return Hlc(lastHlc.millis, lastHlc.counter + 1, nodeId);
  }

  /// Updates local HLC when receiving a remote mutation from another node.
  ///
  /// Guarantees that the new local HLC is strictly greater than both [localHlc]
  /// and [remoteHlc], capturing the causal "happened-before" relationship.
  factory Hlc.recv(
    Hlc? localHlc,
    Hlc remoteHlc,
    String nodeId, {
    int maxDriftMillis = defaultMaxDriftMillis,
    int? wallTime,
  }) {
    final physicalNow =
        wallTime ?? DateTime.now().toUtc().millisecondsSinceEpoch;

    if (remoteHlc.millis - physicalNow > maxDriftMillis) {
      throw ClockDriftException(remoteHlc.millis - physicalNow, maxDriftMillis);
    }

    final localMillis = localHlc?.millis ?? 0;
    final maxMillis = math.max(
      physicalNow,
      math.max(localMillis, remoteHlc.millis),
    );

    final int nextCounter;
    if (maxMillis == physicalNow &&
        physicalNow > localMillis &&
        physicalNow > remoteHlc.millis) {
      nextCounter = 0;
    } else if (localHlc != null &&
        maxMillis == localHlc.millis &&
        maxMillis == remoteHlc.millis) {
      nextCounter = math.max(localHlc.counter, remoteHlc.counter) + 1;
    } else if (localHlc != null && maxMillis == localHlc.millis) {
      nextCounter = localHlc.counter + 1;
    } else {
      nextCounter = remoteHlc.counter + 1;
    }

    return Hlc(maxMillis, nextCounter, nodeId);
  }

  /// Parses a serialized HLC string into an [Hlc] instance.
  ///
  /// Throws [FormatException] if the string format is invalid.
  factory Hlc.parse(String value) {
    final parts = value.split(IdHelper.hlcSeparator);
    if (parts.length < 3) {
      throw FormatException('Invalid HLC string format: $value');
    }

    final isoTime = parts[0];
    final counterHex = parts[1];
    // In case nodeId contains underscores, rejoin remaining parts
    final nodeId = parts.sublist(2).join(IdHelper.hlcSeparator);

    final parsedDate = DateTime.parse(isoTime);
    final millis = parsedDate.toUtc().millisecondsSinceEpoch;
    final counter = int.parse(counterHex, radix: 16);

    return Hlc(millis, counter, nodeId);
  }

  /// Parses a serialized HLC string, or returns null if invalid.
  static Hlc? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return Hlc.parse(value);
    } catch (_) {
      return null;
    }
  }

  /// Formats this HLC into a standardized, lexicographically sortable string:
  /// `<ISO8601>_<counter4hex>_<nodeId>`
  String pack() {
    final iso = DateTime.fromMillisecondsSinceEpoch(
      millis,
      isUtc: true,
    ).toIso8601String();
    final hexCounter = counter
        .toRadixString(16)
        .padLeft(IdHelper.hlcCounterHexWidth, '0');
    return '$iso${IdHelper.hlcSeparator}$hexCounter${IdHelper.hlcSeparator}$nodeId';
  }

  @override
  String toString() => pack();

  @override
  int compareTo(Hlc other) {
    if (millis != other.millis) {
      return millis.compareTo(other.millis);
    }
    if (counter != other.counter) {
      return counter.compareTo(other.counter);
    }
    return nodeId.compareTo(other.nodeId);
  }

  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator <=(Hlc other) => compareTo(other) <= 0;
  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator >=(Hlc other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hlc &&
          runtimeType == other.runtimeType &&
          millis == other.millis &&
          counter == other.counter &&
          nodeId == other.nodeId;

  @override
  int get hashCode => millis.hashCode ^ counter.hashCode ^ nodeId.hashCode;
}
