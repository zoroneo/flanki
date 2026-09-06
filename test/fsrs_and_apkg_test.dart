import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flanki/core/fsrs/fsrs_engine_service.dart';
import 'package:flanki/core/importer/apkg_importer_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('FSRS Spaced Repetition Engine Tests', () {
    final fsrsService = FsrsEngineService();

    test('previewIntervals returns formatted intervals for all 4 ratings', () {
      const card = CardModel(
        id: 'c_test_1',
        deckId: 'deck_1',
        front: 'Front',
        back: 'Back',
        reps: 0,
        intervalDays: 0,
      );

      final intervals = fsrsService.previewIntervals(card);
      expect(intervals.containsKey(1), isTrue); // Again
      expect(intervals.containsKey(2), isTrue); // Hard
      expect(intervals.containsKey(3), isTrue); // Good
      expect(intervals.containsKey(4), isTrue); // Easy

      expect(intervals[1], isNotEmpty);
      expect(intervals[4], isNotEmpty);
    });

    test('scheduleReview calculates increased stability and intervals on Good/Easy', () {
      const card = CardModel(
        id: 'c_test_2',
        deckId: 'deck_1',
        front: 'Question',
        back: 'Answer',
        reps: 1,
        stability: 2.0,
        difficulty: 4.0,
        intervalDays: 2,
      );

      final reviewedCard = fsrsService.scheduleReview(card, 3); // Good

      expect(reviewedCard.reps, equals(2));
      expect(reviewedCard.stability, greaterThan(0));
      expect(reviewedCard.intervalDays, greaterThanOrEqualTo(1));
      expect(reviewedCard.due, isNotNull);
    });
  });

  group('APKG Importer Service Tests', () {
    test('Correctly decodes synthetic .apkg archive and extracts decks & cards', () {
      final sampleDecksJson = jsonEncode({
        "1": {"id": 1, "name": "Default", "desc": ""},
        "1600000000000": {"id": 1600000000000, "name": "English::IELTS Prep", "desc": "Gói từ vựng IELTS"}
      });

      const flds1 = 'Ephemeral (adj)\x1fPhù du, sớm nở tối tàn\x1fTồn tại trong thời gian ngắn';
      const flds2 = '{{c1::Concurrency}} is not parallelism\x1fRob Pike quote';

      final tempDbPath = '/tmp/test_col_${DateTime.now().microsecondsSinceEpoch}.anki2';
      final tempDbFile = sqlite3.open(tempDbPath);
      tempDbFile.execute('''
        CREATE TABLE col (id integer primary key, decks text, models text);
        CREATE TABLE notes (id integer primary key, mid integer, tags text, flds text);
        CREATE TABLE cards (id integer primary key, nid integer, did integer, type integer, queue integer, due integer, ivl integer, factor integer, reps integer, lapses integer);
      ''');
      tempDbFile.execute(
        'INSERT INTO col (id, decks, models) VALUES (1, ?, ?)',
        [sampleDecksJson, '{}'],
      );
      tempDbFile.execute(
        'INSERT INTO notes (id, mid, tags, flds) VALUES (101, 1, ?, ?)',
        ['ielts c1', flds1],
      );
      tempDbFile.execute(
        'INSERT INTO cards (id, nid, did, reps, lapses, ivl) VALUES (201, 101, 1600000000000, 3, 0, 4)',
      );
      tempDbFile.execute(
        'INSERT INTO notes (id, mid, tags, flds) VALUES (102, 1, ?, ?)',
        ['go programming', flds2],
      );
      tempDbFile.execute(
        'INSERT INTO cards (id, nid, did, reps, lapses, ivl) VALUES (202, 102, 1600000000000, 0, 0, 0)',
      );
      tempDbFile.close();

      final dbBytes = Uint8List.fromList(io.File(tempDbPath).readAsBytesSync());
      try {
        io.File(tempDbPath).deleteSync();
      } catch (_) {}

      // 2. Package into .apkg ZIP archive
      final archive = Archive();
      archive.addFile(ArchiveFile('collection.anki2', dbBytes.length, dbBytes));
      final mediaJson = utf8.encode('{"0": "sample_audio.mp3"}');
      archive.addFile(ArchiveFile('media', mediaJson.length, mediaJson));

      final apkgBytes = Uint8List.fromList(ZipEncoder().encode(archive));

      // 3. Test importer
      final importer = ApkgImporterService();
      final result = importer.importApkgBytes(apkgBytes);

      expect(result.decks.length, equals(1));
      expect(result.decks.first.title, equals('English::IELTS Prep'));
      expect(result.cards.length, equals(2));
      expect(result.cards.first.front, contains('Ephemeral'));
      expect(result.cards.last.noteType, equals('cloze'));
      expect(result.mediaCount, equals(1));
    });
  });
}
