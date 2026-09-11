import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/services/notification_service.dart';

void main() {
  group('NotificationService Multi-language Tests', () {
    final service = NotificationService.instance;

    test(
      'Daily reminder strings localized correctly for Vietnamese and English',
      () {
        final vi = service.getL10n('vi');
        final en = service.getL10n('en');

        expect(vi.notificationDailyTitle, 'Đến giờ học Flanki! 🦉');
        expect(en.notificationDailyTitle, 'Time to study with Flanki! 🦉');

        // With due cards
        expect(
          vi.notificationDailyBodyDue(15),
          contains('15 thẻ đang chờ ôn tập'),
        );
        expect(
          en.notificationDailyBodyDue(15),
          contains('15 cards waiting for review'),
        );

        // Generic (no due cards)
        expect(
          vi.notificationDailyBodyGeneric,
          contains('Dành 5 phút mỗi ngày'),
        );
        expect(
          en.notificationDailyBodyGeneric,
          contains('Spend 5 minutes a day'),
        );

        // Channel name and description
        expect(vi.notificationDailyChannelName, 'Nhắc nhở học tập');
        expect(en.notificationDailyChannelName, 'Study Reminder');
        expect(vi.notificationDailyChannelDesc, contains('flashcard'));
        expect(en.notificationDailyChannelDesc, contains('reminders'));
      },
    );

    test(
        'Streak saver strings localized correctly for active and inactive streaks',
        () {
      final vi = service.getL10n('vi');
      final en = service.getL10n('en');

      // Active streak
      expect(
        vi.notificationStreakTitleActive(7),
        'Cứu chuỗi 7 ngày của bạn! 🔥',
      );
      expect(en.notificationStreakTitleActive(7), 'Save your 7-day streak! 🔥');
      expect(vi.notificationStreakBodyActive, contains('nửa đêm'));
      expect(en.notificationStreakBodyActive, contains('midnight'));

      // Inactive streak
      expect(vi.notificationStreakTitleInactive, 'Hôm nay bạn chưa học! ⏳');
      expect(
        en.notificationStreakTitleInactive,
        "You haven't studied today! ⏳",
      );

      // Channel name and description
      expect(vi.notificationStreakChannelName, 'Cứu chuỗi Streak');
      expect(en.notificationStreakChannelName, 'Streak Saver');
    });

    test(
        'NotificationService updateLocale changes currentLocaleCode appropriately',
        () {
      final service = NotificationService.instance;

      service.updateLocale('en');
      expect(service.currentLocaleCode, equals('en'));

      service.updateLocale('en-US');
      expect(service.currentLocaleCode, equals('en'));

      service.updateLocale('vi');
      expect(service.currentLocaleCode, equals('vi'));

      service.updateLocale('vi-VN');
      expect(service.currentLocaleCode, equals('vi'));
    });
  });
}
