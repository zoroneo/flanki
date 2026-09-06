import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:sqlite3/sqlite3.dart';
import '../models/card.dart';
import '../models/deck.dart';

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
  ApkgImportResult importApkgBytes(Uint8List apkgBytes) {
    final archive = ZipDecoder().decodeBytes(apkgBytes);

    ArchiveFile? colFile;
    ArchiveFile? mediaFile;
    int mediaCount = 0;

    for (final file in archive) {
      if (file.name == 'collection.anki2' || file.name == 'collection.anki21') {
        colFile = file;
      } else if (file.name == 'media') {
        mediaFile = file;
      }
    }

    if (mediaFile != null) {
      try {
        final content = utf8.decode(mediaFile.content as List<int>);
        final mediaMap = jsonDecode(content) as Map<String, dynamic>;
        mediaCount = mediaMap.length;
      } catch (_) {}
    }

    if (colFile == null) {
      throw const FormatException('Tệp .apkg không hợp lệ: Không tìm thấy collection.anki2');
    }

    final dbBytes = Uint8List.fromList(colFile.content as List<int>);
    return _parseWithTempDb(dbBytes, mediaCount);
  }

  ApkgImportResult _parseWithTempDb(Uint8List dbBytes, int mediaCount) {
    final tempDir = Directory.systemTemp.createTempSync('flanki_apkg_');
    final tempDbFile = File('${tempDir.path}/collection.anki2');
    tempDbFile.writeAsBytesSync(dbBytes);

    final db = sqlite3.open(tempDbFile.path);

    try {
      final decks = <DeckModel>[];
      final cards = <CardModel>[];

      // 1. Parse decks from col table
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
              description: desc.isNotEmpty ? desc : 'Được import từ gói Anki .apkg',
              dueCount: 0,
              newCount: 0,
              totalCount: 0,
              lastStudied: DateTime.now(),
            ),
          );
        }
      }

      // 2. Parse cards and notes
      final notesResult = db.select('SELECT id, mid, flds, tags FROM notes');
      final notesMap = <int, ({String flds, String tags})>{};
      for (final n in notesResult) {
        notesMap[n['id'] as int] = (
          flds: n['flds'] as String,
          tags: (n['tags'] as String? ?? '').trim(),
        );
      }

      final cardsResult = db.select('SELECT id, nid, did, type, queue, due, ivl, factor, reps, lapses FROM cards');
      
      final deckCardCount = <String, int>{};
      final deckDueCount = <String, int>{};
      final deckNewCount = <String, int>{};

      for (final c in cardsResult) {
        final cid = c['id'] as int;
        final nid = c['nid'] as int;
        final did = c['did'] as int;
        final reps = c['reps'] as int? ?? 0;
        final lapses = c['lapses'] as int? ?? 0;
        final ivl = c['ivl'] as int? ?? 0;

        final noteData = notesMap[nid];
        if (noteData == null) continue;

        // Split fields by 0x1f
        final fields = noteData.flds.split('');
        final front = fields.isNotEmpty ? _cleanHtml(fields[0]) : '';
        final back = fields.length > 1 ? _cleanHtml(fields[1]) : '';
        final hint = fields.length > 2 ? _cleanHtml(fields[2]) : null;

        // Tags separated by space
        final tags = noteData.tags.split(' ').where((t) => t.isNotEmpty).toList();

        final deckId = 'deck-$did';

        // Anki note type detection (Cloze contains {{c1::...}})
        final isCloze = front.contains('{{c') && front.contains('}}');
        final noteType = isCloze ? 'cloze' : 'basic';

        cards.add(
          CardModel(
            id: 'c_$cid',
            deckId: deckId,
            front: front,
            back: back,
            hint: hint,
            noteType: noteType,
            intervalDays: ivl > 0 ? ivl : 0,
            stability: ivl > 0 ? ivl * 1.5 : 0.0,
            difficulty: 3.0,
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

  static String _cleanHtml(String raw) {
    var text = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), r'\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), r'\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return text.trim();
  }
}
