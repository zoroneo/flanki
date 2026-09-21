import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/payload_optimizer.dart';

void main() {
  group('SparsePayloadOptimizer', () {
    test('cleanMap removes null keys recursively', () {
      final input = {
        'id': '123',
        'title': 'Test Deck',
        'nullField': null,
        'nested': {
          'keep': 1,
          'remove': null,
          'deep': {'a': null, 'b': 'ok'},
        },
        'list': [
          {'id': 'item1', 'empty': null},
          'string_item',
        ],
      };

      final cleaned = SparsePayloadOptimizer.cleanMap(input);

      expect(cleaned.containsKey('nullField'), isFalse);
      expect(cleaned['id'], '123');
      expect((cleaned['nested'] as Map).containsKey('remove'), isFalse);
      expect((cleaned['nested'] as Map)['keep'], 1);
      expect(
        ((cleaned['nested'] as Map)['deep'] as Map).containsKey('a'),
        isFalse,
      );
      expect(((cleaned['nested'] as Map)['deep'] as Map)['b'], 'ok');
      expect(
        ((cleaned['list'] as List).first as Map).containsKey('empty'),
        isFalse,
      );
    });

    test('cleanMutations cleans payload in each mutation entry', () {
      final mutations = [
        {
          'id': 'm1',
          'entity_type': 'card',
          'payload': {
            'id': 'c1',
            'front': 'Hello',
            'back': 'World',
            'deleted_at': null,
          },
        },
      ];

      final cleaned = SparsePayloadOptimizer.cleanMutations(mutations);

      final payload = cleaned.first['payload'] as Map<String, dynamic>;
      expect(payload['front'], 'Hello');
      expect(payload.containsKey('deleted_at'), isFalse);
    });
  });

  group('PayloadCompressor', () {
    test('compressJson and decompressJson roundtrip correctly', () {
      final data = {
        'cards': List.generate(
          50,
          (i) => {
            'id': 'card_$i',
            'front': 'Front side question for card $i with some detailed text',
            'back': 'Back side answer for card $i with explanation',
          },
        ),
      };

      final rawJson = jsonEncode(data);
      final rawBytes = utf8.encode(rawJson).length;

      final compressed = PayloadCompressor.compressJson(data);
      expect(compressed.length, lessThan(rawBytes));

      final decompressed = PayloadCompressor.decompressJson(compressed);
      expect(decompressed['cards'].length, 50);
      expect(decompressed['cards'][0]['id'], 'card_0');

      final savings = PayloadCompressor.calculateSavingsPercent(
        rawBytes,
        compressed.length,
      );
      expect(savings, greaterThan(30.0));
    });
  });

  group('SyncBandwidthTracker', () {
    test('accumulates sent and received bytes and formats accurately', () {
      final tracker = SyncBandwidthTracker.instance;
      tracker.reset();

      expect(tracker.bytesSent, 0);
      expect(tracker.bytesReceived, 0);

      tracker.recordTransfer(sent: 1024, received: 2048, saved: 500);

      expect(tracker.bytesSent, 1024);
      expect(tracker.bytesReceived, 2048);
      expect(tracker.bytesSaved, 500);
      expect(tracker.totalTransferred, 3072);

      expect(SyncBandwidthTracker.formatBytes(500), '500 B');
      expect(SyncBandwidthTracker.formatBytes(2048), '2.0 KB');
      expect(SyncBandwidthTracker.formatBytes(5 * 1024 * 1024), '5.0 MB');
    });
  });
}
