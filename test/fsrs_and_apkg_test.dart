import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui' show Locale;
import 'package:archive/archive.dart';
import 'package:flanki/core/fsrs/fsrs_engine_service.dart';
import 'package:flanki/core/importer/anki_template_engine.dart';
import 'package:flanki/core/importer/apkg_importer_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
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
      expect(intervals.containsKey(ReviewRating.again), isTrue); // Again
      expect(intervals.containsKey(ReviewRating.hard), isTrue); // Hard
      expect(intervals.containsKey(ReviewRating.good), isTrue); // Good
      expect(intervals.containsKey(ReviewRating.easy), isTrue); // Easy

      expect(intervals[ReviewRating.again], isNotEmpty);
      expect(intervals[ReviewRating.easy], isNotEmpty);
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

      final reviewedCard = fsrsService.scheduleReview(card, ReviewRating.good); // Good

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

      final tempDir = io.Directory.systemTemp.createTempSync('flanki_test_apkg_');
      final tempDbPath = '${tempDir.path}${io.Platform.pathSeparator}test_col_${DateTime.now().microsecondsSinceEpoch}.anki2';
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
        tempDir.deleteSync(recursive: true);
      } catch (_) {}

      // 2. Package into .apkg ZIP archive
      final archive = Archive();
      archive.addFile(ArchiveFile('collection.anki2', dbBytes.length, dbBytes));
      final mediaJson = utf8.encode('{"0": "sample_audio.mp3"}');
      archive.addFile(ArchiveFile('media', mediaJson.length, mediaJson));
      final audioBytes = utf8.encode('mock_audio_data');
      archive.addFile(ArchiveFile('0', audioBytes.length, audioBytes));

      final apkgBytes = Uint8List.fromList(ZipEncoder().encode(archive));

      // 3. Test importer
      final importer = ApkgImporterService();
      final result = importer.importApkgBytes(apkgBytes);

      expect(result.decks.length, equals(1));
      expect(result.decks.first.title, equals('English::IELTS Prep'));
      expect(result.cards.length, equals(2));
      expect(result.cards.first.front, contains('Ephemeral'));
      expect(result.cards.first.stability, equals(4.0));
      expect(result.cards.first.difficulty, inInclusiveRange(1.0, 10.0));
      expect(result.cards.last.stability, equals(0.0));
      expect(result.cards.last.noteType, equals(NoteType.cloze));
      expect(result.mediaCount, equals(1));
    });

    test('formatInterval formats minutes, hours, days without l10n', () {
      expect(FsrsEngineService.formatInterval(const Duration(minutes: 10)), anyOf('10 phút', '10m'));
      expect(FsrsEngineService.formatInterval(const Duration(hours: 3)), anyOf('3 giờ', '3h'));
      expect(FsrsEngineService.formatInterval(const Duration(days: 4)), anyOf('4 ngày', '4d'));
    });

    test('formatInterval formats correctly with explicit English and Vietnamese l10n', () {
      final l10nVi = lookupAppLocalizations(const Locale('vi'));
      final l10nEn = lookupAppLocalizations(const Locale('en'));

      expect(FsrsEngineService.formatInterval(const Duration(minutes: 10), l10n: l10nVi), '10 phút');
      expect(FsrsEngineService.formatInterval(const Duration(hours: 3), l10n: l10nVi), '3 giờ');
      expect(FsrsEngineService.formatInterval(const Duration(days: 4), l10n: l10nVi), '4 ngày');

      expect(FsrsEngineService.formatInterval(const Duration(minutes: 10), l10n: l10nEn), '10m');
      expect(FsrsEngineService.formatInterval(const Duration(hours: 3), l10n: l10nEn), '3h');
      expect(FsrsEngineService.formatInterval(const Duration(days: 4), l10n: l10nEn), '4d');
    });
  });

  group('AnkiTemplateEngine Tests', () {
    test('renders Mustache fields, conditionals, and FrontSide', () {
      const model = AnkiModel(
        id: 1,
        name: '4000 Essential English Words',
        fieldNames: ['Word', 'Phonetic', 'Meaning', 'Example', 'Audio', 'Image'],
        templates: [
          AnkiTemplate(
            ord: 0,
            name: 'Card 1',
            qfmt: '{{Word}}<br>{{#Phonetic}}[{{Phonetic}}]{{/Phonetic}}<br>{{Audio}}',
            afmt: '{{FrontSide}}\n<hr id=answer>\n{{Meaning}}<br><i>{{Example}}</i><br>{{Image}}',
          ),
        ],
      );

      final rendered = AnkiTemplateEngine.renderCard(
        model: model,
        cardOrd: 0,
        fieldValues: [
          'abandon',
          '/əˈbændən/',
          'to leave someone or something',
          'He had to abandon his car.',
          '[sound:abandon.mp3]',
          '<img src="abandon.jpg">',
        ],
      );

      expect(rendered.front, contains('abandon'));
      expect(rendered.front, contains('[/əˈbændən/]'));
      expect(rendered.front, contains('[sound:abandon.mp3]'));

      expect(rendered.back, contains('abandon'));
      expect(rendered.back, contains('to leave someone or something'));
      expect(rendered.back, contains('He had to abandon his car.'));
      expect(rendered.back, contains('<img src="abandon.jpg">'));
      // FrontSide in back should not repeat [sound:abandon.mp3]
      expect(rendered.back, isNot(contains('[sound:abandon.mp3]')));
    });

    test('renders Cloze deletion on front and back', () {
      const model = AnkiModel(
        id: 2,
        name: 'Cloze Model',
        fieldNames: ['Text', 'Extra'],
        templates: [
          AnkiTemplate(
            ord: 0,
            name: 'Cloze 1',
            qfmt: '{{cloze:Text}}',
            afmt: '{{cloze:Text}}<br>{{Extra}}',
          ),
        ],
      );

      final rendered = AnkiTemplateEngine.renderCard(
        model: model,
        cardOrd: 0,
        fieldValues: [
          'Canberra was founded in {{c1::1913::year}} as a planned city.',
          'Capital of Australia',
        ],
      );

      expect(rendered.front, contains('[year]'));
      expect(rendered.front, isNot(contains('1913')));

      expect(rendered.back, contains('1913'));
      expect(rendered.back, contains('Capital of Australia'));
    });

    test('fallback combines all multi-fields without losing images or audio', () {
      final rendered = AnkiTemplateEngine.renderCard(
        model: null,
        cardOrd: 0,
        fieldValues: [
          'Word',
          'Phonetic',
          'Meaning',
          '<img src="sample.png">',
          '[sound:sample.mp3]',
        ],
      );

      expect(rendered.front, equals('Word'));
      expect(rendered.back, contains('Phonetic'));
      expect(rendered.back, contains('Meaning'));
      expect(rendered.back, contains('<img src="sample.png">'));
      expect(rendered.back, contains('[sound:sample.mp3]'));
    });
  });
}
