import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:sqlite3/sqlite3.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../storage/database_service.dart';
import '../storage/media_storage_service.dart';
import 'anki_template_engine.dart';

class ApkgImportResult {
  final List<DeckModel> decks;
  final List<CardModel> cards;
  final int mediaCount;

  const ApkgImportResult({
    required this.decks,
    required this.cards,
    required this.mediaCount,
  });
}

/// Service to parse Anki .apkg export packages (ZIP archive containing collection.anki2 + media).
class ApkgImporterService {
  /// Parses .apkg binary bytes into Flanki DeckModels and CardModels.
  ApkgImportResult importApkgBytes(
    Uint8List apkgBytes, {
    String? defaultDeckDescription,
  }) {
    // If the data is raw SQLite database directly (e.g. from AnkiWeb full sync download)
    if (apkgBytes.length >= 16 &&
        utf8.decode(apkgBytes.sublist(0, 15), allowMalformed: true) == 'SQLite format 3') {
      DatabaseService.instance.saveSyncTemplateBytes(apkgBytes);
      return _parseWithTempDb(
        apkgBytes,
        0,
        defaultDeckDescription: defaultDeckDescription,
      );
    }

    final archive = ZipDecoder().decodeBytes(apkgBytes);

    ArchiveFile? colFile;
    ArchiveFile? mediaFile;
    final archiveFilesMap = <String, ArchiveFile>{};

    for (final file in archive) {
      archiveFilesMap[file.name] = file;
      if (file.name == 'collection.anki2' || file.name == 'collection.anki21') {
        colFile = file;
      } else if (file.name == 'media') {
        mediaFile = file;
      }
    }

    int mediaCount = 0;
    if (mediaFile != null) {
      try {
        final content = utf8.decode(mediaFile.content as List<int>);
        final mediaMap = jsonDecode(content) as Map<String, dynamic>;
        mediaCount = mediaMap.length;

        // Extract and persist all media assets (images, audio)
        for (final entry in mediaMap.entries) {
          final archiveIndex = entry.key;
          final targetFilename = entry.value as String;
          final af = archiveFilesMap[archiveIndex];
          if (af != null) {
            MediaStorageService.instance.saveMediaFileSync(
              targetFilename,
              af.content as List<int>,
            );
          }
        }
      } catch (_) {}
    }

    if (colFile == null) {
      throw const FormatException('Invalid .apkg package: collection.anki2 not found');
    }

    final dbBytes = Uint8List.fromList(colFile.content as List<int>);
    DatabaseService.instance.saveSyncTemplateBytes(dbBytes);
    return _parseWithTempDb(
      dbBytes,
      mediaCount,
      defaultDeckDescription: defaultDeckDescription,
    );
  }

  ApkgImportResult _parseWithTempDb(
    Uint8List dbBytes,
    int mediaCount, {
    String? defaultDeckDescription,
  }) {
    final tempDir = Directory.systemTemp.createTempSync('flanki_apkg_');
    final tempDbFile = File('${tempDir.path}/collection.anki2');
    tempDbFile.writeAsBytesSync(dbBytes);

    final db = sqlite3.open(tempDbFile.path);

    try {
      final decks = <DeckModel>[];
      final cards = <CardModel>[];
      final ankiModels = <int, AnkiModel>{};

      // 1. Parse decks and models from col table
      final colResult = db.select('SELECT decks, models FROM col LIMIT 1');
      if (colResult.isNotEmpty) {
        final row = colResult.first;
        final decksJson = row['decks'] as String;
        final decksMap = jsonDecode(decksJson) as Map<String, dynamic>;

        for (final entry in decksMap.entries) {
          final d = entry.value as Map<String, dynamic>;
          final id = entry.key;
          final name = (d['name'] ?? 'Deck $id') as String;
          final desc = (d['desc'] ?? '') as String;

          // Ignore default empty deck if there are others
          if (id == '1' && decksMap.length > 1 && name == 'Default') {
            continue;
          }

          decks.add(
            DeckModel(
              id: 'deck-$id',
              title: name,
              description: desc.isNotEmpty
                  ? desc
                  : (defaultDeckDescription ?? 'Imported from Anki package .apkg'),
              dueCount: 0,
              newCount: 0,
              totalCount: 0,
              lastStudied: DateTime.now(),
            ),
          );
        }

        // Parse Anki note models (field names and card templates)
        final modelsJson = row['models'] as String? ?? '{}';
        try {
          final modelsMap = jsonDecode(modelsJson) as Map<String, dynamic>;
          for (final entry in modelsMap.entries) {
            final m = AnkiModel.fromJson(entry.key, entry.value as Map<String, dynamic>);
            ankiModels[m.id] = m;
          }
        } catch (_) {}
      }

      // 2. Parse notes
      final notesResult = db.select('SELECT id, mid, flds, tags FROM notes');
      final notesMap = <int, ({int mid, List<String> flds, String tags})>{};
      for (final n in notesResult) {
        final fldsRaw = n['flds'] as String;
        notesMap[n['id'] as int] = (
          mid: n['mid'] as int,
          flds: fldsRaw.split('\x1f'),
          tags: (n['tags'] as String? ?? '').trim(),
        );
      }

      // 3. Parse cards
      final columnsResult = db.select('PRAGMA table_info(cards)');
      final columnNames = columnsResult.map((r) => (r['name'] as String).toLowerCase()).toSet();
      final ordExpr = columnNames.contains('ord') ? 'ord' : '0 as ord';
      final cardsResult = db.select('SELECT id, nid, did, $ordExpr, reps, lapses, ivl, factor FROM cards');

      final deckCardCount = <String, int>{};
      final deckDueCount = <String, int>{};
      final deckNewCount = <String, int>{};

      for (final c in cardsResult) {
        final cid = c['id'] as int;
        final nid = c['nid'] as int;
        final did = c['did'] as int;
        final ord = c['ord'] as int? ?? 0;
        final reps = c['reps'] as int? ?? 0;
        final lapses = c['lapses'] as int? ?? 0;
        final ivl = c['ivl'] as int? ?? 0;
        final factor = c['factor'] as int? ?? 2500;

        // FSRS parameter derivation from Anki Ease Factor & Interval
        final double difficulty;
        final double stability;
        if (reps == 0) {
          difficulty = 0.0;
          stability = 0.0;
        } else {
          final ease = factor > 0 ? factor / 1000.0 : 2.5;
          // Linear mapping: Ease [1.3, 3.0] -> Difficulty [10.0, 1.0]
          difficulty = ((3.0 - ease) / 1.7 * 9.0 + 1.0).clamp(1.0, 10.0);
          stability = math.max(0.1, ivl.toDouble());
        }

        final noteData = notesMap[nid];
        if (noteData == null) continue;

        // Render front and back using AnkiTemplateEngine
        final model = ankiModels[noteData.mid];
        final rendered = AnkiTemplateEngine.renderCard(
          model: model,
          cardOrd: ord,
          fieldValues: noteData.flds,
        );

        // Resolve local media paths
        final front = MediaStorageService.instance.resolveHtmlMedia(rendered.front);
        final back = MediaStorageService.instance.resolveHtmlMedia(rendered.back);

        // Hint: take third field if non-empty, or null
        final hint = noteData.flds.length > 2 && noteData.flds[2].trim().isNotEmpty
            ? noteData.flds[2].trim()
            : null;

        // Tags separated by space
        final tags = noteData.tags.split(' ').where((t) => t.isNotEmpty).toList();

        final deckId = 'deck-$did';

        // Anki note type detection (Cloze contains {{c1::...}})
        final isCloze = front.contains('cloze') || noteData.flds.any((f) => f.contains('{{c'));
        final noteType = isCloze ? NoteType.cloze : NoteType.basic;

        cards.add(
          CardModel(
            id: 'c_$cid',
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            noteType: noteType,
            intervalDays: ivl > 0 ? ivl : 0,
            stability: stability,
            difficulty: difficulty,
            reps: reps,
            lapses: lapses,
            tags: tags,
            due: DateTime.now().add(Duration(days: ivl)),
            createdAt: DateTime.now(),
          ),
        );

        deckCardCount[deckId] = (deckCardCount[deckId] ?? 0) + 1;
        if (reps == 0) {
          deckNewCount[deckId] = (deckNewCount[deckId] ?? 0) + 1;
        } else {
          deckDueCount[deckId] = (deckDueCount[deckId] ?? 0) + 1;
        }
      }

      // Update counts for parsed decks
      final updatedDecks = decks.map((d) {
        final count = deckCardCount[d.id] ?? 0;
        final due = deckDueCount[d.id] ?? 0;
        final newC = deckNewCount[d.id] ?? 0;
        return d.copyWith(
          totalCount: count,
          dueCount: due,
          newCount: newC,
        );
      }).where((d) => d.totalCount > 0).toList();

      return ApkgImportResult(
        decks: updatedDecks.isNotEmpty ? updatedDecks : decks,
        cards: cards,
        mediaCount: mediaCount,
      );
    } finally {
      db.close();
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }
}
