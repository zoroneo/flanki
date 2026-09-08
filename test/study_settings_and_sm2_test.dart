import 'dart:convert';

import 'package:flanki/core/fsrs/sm2_engine_service.dart';
import 'package:flanki/core/models/card.dart';
import 'package:flanki/core/notifiers/settings_notifier.dart';
import 'package:flanki/core/sync/anki_web_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SM-2 Spaced Repetition Engine Tests', () {
    const sm2Service = Sm2EngineService();

    test('previewIntervals provides interval string for all 4 ratings', () {
      const newCard = CardModel(
        id: 'sm2_new_1',
        deckId: 'deck_1',
        front: 'Q',
        back: 'A',
        reps: 0,
        intervalDays: 0,
      );

      final previews = sm2Service.previewIntervals(newCard);
      expect(previews.containsKey(ReviewRating.again), isTrue);
      expect(previews.containsKey(ReviewRating.hard), isTrue);
      expect(previews.containsKey(ReviewRating.good), isTrue);
      expect(previews.containsKey(ReviewRating.easy), isTrue);

      expect(previews[ReviewRating.again], contains('10'));
      expect(previews[ReviewRating.good], contains('1'));
      expect(previews[ReviewRating.easy], contains('4'));
    });

    test('New card rating updates reps and sets initial intervals', () {
      const card = CardModel(
        id: 'sm2_new_2',
        deckId: 'deck_1',
        front: 'Q',
        back: 'A',
        reps: 0,
        intervalDays: 0,
      );

      // Again: stays interval 0, lapse + 1, reps + 1
      final againCard = sm2Service.scheduleReview(card, ReviewRating.again);
      expect(againCard.intervalDays, equals(0));
      expect(againCard.lapses, equals(1));
      expect(againCard.reps, equals(1));

      // Hard: interval 1d, reps 1
      final hardCard = sm2Service.scheduleReview(card, ReviewRating.hard);
      expect(hardCard.intervalDays, equals(1));
      expect(hardCard.reps, equals(1));

      // Good: interval 1d, reps 1
      final goodCard = sm2Service.scheduleReview(card, ReviewRating.good);
      expect(goodCard.intervalDays, equals(1));
      expect(goodCard.reps, equals(1));

      // Easy: interval 4d, reps 1
      final easyCard = sm2Service.scheduleReview(card, ReviewRating.easy);
      expect(easyCard.intervalDays, equals(4));
      expect(easyCard.reps, equals(1));
    });

    test('Review card progression scales interval by ease factor on Good', () {
      // Card with 1 rep and 1d interval, initial ease 2.5
      final cardRep1 = CardModel(
        id: 'sm2_rev_1',
        deckId: 'deck_1',
        front: 'Q',
        back: 'A',
        reps: 1,
        intervalDays: 1,
        difficulty: Sm2EngineService.factorToDifficulty(2.5),
      );

      final cardRep2 = sm2Service.scheduleReview(cardRep1, ReviewRating.good);
      expect(cardRep2.reps, equals(2));
      expect(cardRep2.intervalDays, equals(6)); // Rep 2 with Good gives 6 days

      final cardRep3 = sm2Service.scheduleReview(cardRep2, ReviewRating.good);
      expect(cardRep3.reps, equals(3));
      expect(cardRep3.intervalDays, equals((6 * 2.5).round())); // 15 days
    });

    test('Ease factor does not drop below 1.3 minimum floor', () {
      var card = CardModel(
        id: 'sm2_floor_1',
        deckId: 'deck_1',
        front: 'Hard question',
        back: 'Hard answer',
        reps: 3,
        intervalDays: 10,
        difficulty: Sm2EngineService.factorToDifficulty(1.35),
      );

      // Repeated Hard ratings reduce ease factor
      for (var i = 0; i < 5; i++) {
        card = sm2Service.scheduleReview(card, ReviewRating.hard);
      }

      final factor = Sm2EngineService.difficultyToFactor(card.difficulty);
      expect(factor, greaterThanOrEqualTo(1.3));
    });
  });

  group('StudySettings Tests', () {
    test('StudySettings default values comply with best practices', () {
      const settings = StudySettings();
      expect(settings.fsrsEnabled, isTrue);
      expect(settings.desiredRetention, equals(0.90));
      expect(settings.newCardsPerDay, equals(20));
      expect(settings.maxReviewsPerDay, equals(100));
      expect(settings.reminderEnabled, isTrue);
      expect(settings.reminderHour, equals(20));
      expect(settings.reminderMinute, equals(0));
      expect(settings.streakSaverEnabled, isTrue);
      expect(settings.minimizeToTrayOnClose, isTrue);
      expect(settings.launchAtStartup, isFalse);
    });

    test(
      'StudySettings toMap and fromMap serialization roundtrips correctly',
      () {
        const original = StudySettings(
          fsrsEnabled: false,
          desiredRetention: 0.85,
          newCardsPerDay: 30,
          maxReviewsPerDay: 200,
          reminderEnabled: false,
          reminderHour: 21,
          reminderMinute: 30,
          streakSaverEnabled: false,
          minimizeToTrayOnClose: false,
          launchAtStartup: true,
        );

        final map = original.toMap();
        final restored = StudySettings.fromMap(map);

        expect(restored.fsrsEnabled, isFalse);
        expect(restored.desiredRetention, equals(0.85));
        expect(restored.newCardsPerDay, equals(30));
        expect(restored.maxReviewsPerDay, equals(200));
        expect(restored.reminderEnabled, isFalse);
        expect(restored.reminderHour, equals(21));
        expect(restored.reminderMinute, equals(30));
        expect(restored.streakSaverEnabled, isFalse);
        expect(restored.minimizeToTrayOnClose, isFalse);
        expect(restored.launchAtStartup, isTrue);

        final jsonStr = jsonEncode(map);
        final decodedMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final fromDecoded = StudySettings.fromMap(decodedMap);
        expect(fromDecoded.newCardsPerDay, equals(30));
        expect(fromDecoded.reminderHour, equals(21));
        expect(fromDecoded.minimizeToTrayOnClose, isFalse);
        expect(fromDecoded.launchAtStartup, isTrue);
      },
    );
  });

  group('AnkiWebConfig Centralization Tests', () {
    test('AnkiWebConfig exposes valid endpoints, headers and timeouts', () {
      expect(
        AnkiWebConfig.defaultSyncHost,
        startsWith('https://sync.ankiweb.net'),
      );
      expect(AnkiWebConfig.userAgent, contains('Anki/'));
      expect(AnkiWebConfig.protocolVersion, equals(10));
      expect(AnkiWebConfig.clientVersion, contains('anki'));
      expect(AnkiWebConfig.authTimeout.inSeconds, equals(15));
      expect(AnkiWebConfig.downloadTimeout.inSeconds, equals(30));
    });
  });
}
