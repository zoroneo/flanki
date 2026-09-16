import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/hlc.dart';

void main() {
  group('Hybrid Logical Clock (HLC) Tests', () {
    test('Hlc.now() initializes with current time and zero counter', () {
      final hlc = Hlc.now('node_1');
      expect(hlc.nodeId, equals('node_1'));
      expect(hlc.counter, equals(0));
      expect(hlc.millis, isPositive);
    });

    test('pack and parse symmetry', () {
      final original = Hlc(
        DateTime.utc(2026, 9, 16, 12, 0, 0).millisecondsSinceEpoch,
        42,
        'device_a',
      );

      final packed = original.pack();
      expect(packed, startsWith('2026-09-16T12:00:00.000Z_002a_device_a'));

      final parsed = Hlc.parse(packed);
      expect(parsed, equals(original));
      expect(parsed.millis, equals(original.millis));
      expect(parsed.counter, equals(42));
      expect(parsed.nodeId, equals('device_a'));
    });

    test('parse throws FormatException on malformed strings', () {
      expect(() => Hlc.parse(''), throwsFormatException);
      expect(() => Hlc.parse('invalid-hlc'), throwsFormatException);
      expect(
        () => Hlc.parse('2026-01-01T00:00:00.000Z'),
        throwsFormatException,
      );
    });

    test('Hlc.send() generates monotonically increasing HLC', () {
      final hlc0 = Hlc.now('node_a');
      final hlc1 = Hlc.send(hlc0, 'node_a');
      final hlc2 = Hlc.send(hlc1, 'node_a');

      expect(hlc1 > hlc0, isTrue);
      expect(hlc2 > hlc1, isTrue);
      expect(hlc0 < hlc1, isTrue);
      expect(hlc1 <= hlc2, isTrue);
      expect(hlc0 != hlc1, isTrue);
    });

    test('Hlc.send() increments counter if physical time does not change', () {
      const fixedTime = 1700000000000;
      const hlc0 = Hlc(fixedTime, 0, 'node_a');
      final hlc1 = Hlc.send(hlc0, 'node_a', wallTime: fixedTime);
      final hlc2 = Hlc.send(hlc1, 'node_a', wallTime: fixedTime);

      expect(hlc1.millis, equals(fixedTime));
      expect(hlc1.counter, equals(1));
      expect(hlc2.millis, equals(fixedTime));
      expect(hlc2.counter, equals(2));
      expect(hlc2 > hlc1, isTrue);
    });

    test('Hlc.send() resets counter to 0 when physical time moves forward', () {
      const time1 = 1700000000000;
      const time2 = 1700000005000;
      const hlc0 = Hlc(time1, 5, 'node_a');
      final hlc1 = Hlc.send(hlc0, 'node_a', wallTime: time2);

      expect(hlc1.millis, equals(time2));
      expect(hlc1.counter, equals(0));
      expect(hlc1 > hlc0, isTrue);
    });

    test('clock rewind / backwards drift keeps monotonic ordering', () {
      const futureTime = 1700000010000;
      const pastTime = 1700000000000; // local clock jumps back 10s

      const hlc0 = Hlc(futureTime, 3, 'node_a');
      final hlc1 = Hlc.send(hlc0, 'node_a', wallTime: pastTime);

      expect(hlc1.millis, equals(futureTime)); // retains highest seen timestamp
      expect(hlc1.counter, equals(4)); // increments counter
      expect(hlc1 > hlc0, isTrue);
    });

    test('Hlc.recv() merges remote HLC correctly', () {
      const time1 = 1700000000000;
      const local = Hlc(time1, 2, 'local');
      const remote = Hlc(time1 + 100, 1, 'remote');

      final merged = Hlc.recv(local, remote, 'local', wallTime: time1);
      expect(merged.millis, equals(remote.millis));
      expect(merged.counter, equals(2)); // remote.counter + 1
      expect(merged.nodeId, equals('local'));
      expect(merged > local, isTrue);
      expect(merged > remote, isTrue);
    });

    test('Hlc.recv() rejects remote HLC exceeding max drift tolerance', () {
      const wallTime = 1700000000000;
      const local = Hlc(wallTime, 0, 'local');
      // 61 seconds ahead (exceeds default maxDriftMillis = 60,000)
      const farRemote = Hlc(wallTime + 61000, 0, 'future_node');

      expect(
        () => Hlc.recv(local, farRemote, 'local', wallTime: wallTime),
        throwsA(isA<ClockDriftException>()),
      );
    });

    test('comparison operators test', () {
      const a = Hlc(100, 1, 'a');
      const b = Hlc(100, 1, 'b');
      const c = Hlc(100, 2, 'a');
      const d = Hlc(200, 0, 'a');

      expect(
        a < b,
        isTrue,
      ); // same ts and counter, tie-break by nodeId ('a' < 'b')
      expect(b < c, isTrue); // same ts, counter 1 < 2
      expect(c < d, isTrue); // ts 100 < 200
      expect(a == const Hlc(100, 1, 'a'), isTrue);
    });
  });
}
