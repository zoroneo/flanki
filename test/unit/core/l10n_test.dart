import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flanki/core/localization/locale_notifier.dart';
import 'package:flanki/features/exam/models/exam_models.dart';
import 'package:flanki/features/grammar/models/grammar_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    test('AppLocalizations supports en and vi', () {
      expect(
        AppLocalizations.supportedLocales,
        containsAll([const Locale('en'), const Locale('vi')]),
      );
    });

    test('English translations load correctly', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      expect(l10nEn.navDecks, 'Decks');
      expect(l10nEn.navBrowser, 'Browser');
      expect(l10nEn.navExams, 'Exams');
      expect(l10nEn.navStats, 'Stats');
      expect(l10nEn.navSettings, 'Settings');
      expect(l10nEn.studyNow, 'Study Now');
      expect(l10nEn.cardsCount(5), '5 cards');
      expect(l10nEn.deckPrefix('Default'), 'Deck: Default');
      expect(l10nEn.intervalBadge(5), '5d interval');
      expect(l10nEn.newBadge, 'New');
      expect(l10nEn.studyMinutesUnit(10), '10m');
      expect(l10nEn.targetRetentionRate('85%'), 'Target 85%');
      expect(l10nEn.targetRetentionBadge('90%'), 'Target 90% retention');
      expect(l10nEn.targetSuffix('90%'), '/ 90% target');
      expect(l10nEn.algorithmLabel, 'Algorithm');
      expect(l10nEn.themeZinc, 'Zinc Theme');
      expect(l10nEn.ankiRustCore, 'Anki Rust Core');
      expect(l10nEn.createDeckTitle, 'Create Deck');
      expect(l10nEn.deckCreatedSuccess, 'Deck Created');
      expect(
        l10nEn.deckCreatedSuccessDesc('Test'),
        'Deck "Test" has been created.',
      );
      expect(l10nEn.trayOpenFlanki, 'Open Flanki');
      expect(l10nEn.trayStudyNow, 'Study Now');
      expect(l10nEn.trayExit, 'Quit Flanki');
      expect(
        l10nEn.privacyPolicyTagline,
        'Local-First • Zero Tracking • Open Source',
      );
      expect(l10nEn.privacySection1Title, '1. Local-First Storage');
      expect(l10nEn.grammarTableOfContents, 'Table of Contents');
      expect(l10nEn.grammarShortcutsTitle, 'Shortcuts & Guide');
      expect(l10nEn.grammarGhostsCount(3), '3 Ghost');
      expect(l10nEn.grammarUnitsCount(36), '36 Units');
      expect(l10nEn.updateDownloadFailed, 'Failed to download installer');
      expect(l10nEn.desktopSubtitle, 'Desktop • Zinc');
      expect(l10nEn.rslibLinked, 'rslib (Linked)');
      expect(l10nEn.unknown, 'Unknown');
      expect(l10nEn.examBank, 'Exam Bank');
      expect(l10nEn.wrongNotebook, 'Mistake Notebook');
      expect(l10nEn.allFilter, 'All');
      expect(l10nEn.allCountFilter(5), 'All (5)');
      expect(l10nEn.examDurationAndQuestions(30, 10), '30 mins • 10 questions');
      expect(l10nEn.examPassed, 'PASSED');
      expect(l10nEn.examFailed, 'FAILED');
      expect(l10nEn.examScorePoints(80), '80 Pts');
      expect(l10nEn.ankiWebLegacy, 'AnkiWeb (Legacy)');
    });

    test('Vietnamese translations load correctly', () async {
      final l10nVi = await AppLocalizations.delegate.load(const Locale('vi'));
      expect(l10nVi.navDecks, 'Bộ thẻ');
      expect(l10nVi.navBrowser, 'Duyệt thẻ');
      expect(l10nVi.navExams, 'Đề thi');
      expect(l10nVi.navStats, 'Thống kê');
      expect(l10nVi.navSettings, 'Cài đặt');
      expect(l10nVi.studyNow, 'Học ngay');
      expect(l10nVi.cardsCount(5), '5 thẻ');
      expect(l10nVi.deckPrefix('Default'), 'Bộ thẻ: Default');
      expect(l10nVi.intervalBadge(5), 'Khoảng cách 5 ngày');
      expect(l10nVi.newBadge, 'Mới');
      expect(l10nVi.studyMinutesUnit(10), '10p');
      expect(l10nVi.targetRetentionRate('85%'), 'Mục tiêu 85%');
      expect(l10nVi.targetRetentionBadge('90%'), 'Mục tiêu 90% nhớ');
      expect(l10nVi.targetSuffix('90%'), '/ mục tiêu 90%');
      expect(l10nVi.algorithmLabel, 'Thuật toán');
      expect(l10nVi.themeZinc, 'Chủ đề Zinc');
      expect(l10nVi.ankiRustCore, 'Nhân Anki Rust');
      expect(l10nVi.createDeckTitle, 'Tạo bộ thẻ');
      expect(l10nVi.deckCreatedSuccess, 'Đã tạo bộ thẻ');
      expect(
        l10nVi.deckCreatedSuccessDesc('Test'),
        'Bộ thẻ "Test" đã được tạo thành công.',
      );
      expect(l10nVi.trayOpenFlanki, 'Mở Flanki');
      expect(l10nVi.trayStudyNow, 'Ôn tập ngay');
      expect(l10nVi.trayExit, 'Thoát hoàn toàn');
      expect(
        l10nVi.privacyPolicyTagline,
        'Ưu tiên cục bộ • Không theo dõi • Mã nguồn mở',
      );
      expect(l10nVi.privacySection1Title, '1. Lưu trữ ưu tiên cục bộ');
      expect(l10nVi.grammarTableOfContents, 'Mục Lục Chuyên Đề');
      expect(l10nVi.grammarShortcutsTitle, 'Phím tắt & Hướng dẫn');
      expect(l10nVi.grammarGhostsCount(3), '3 Ghost');
      expect(l10nVi.grammarUnitsCount(36), '36 Chuyên đề');
      expect(l10nVi.updateDownloadFailed, 'Tải tệp cài đặt thất bại');
      expect(l10nVi.desktopSubtitle, 'Máy tính • Zinc');
      expect(l10nVi.rslibLinked, 'rslib (Đã liên kết)');
      expect(l10nVi.unknown, 'Không xác định');
      expect(l10nVi.examBank, 'Ngân hàng đề thi');
      expect(l10nVi.wrongNotebook, 'Sổ tay câu sai');
      expect(l10nVi.allFilter, 'Tất cả');
      expect(l10nVi.allCountFilter(5), 'Tất cả (5)');
      expect(l10nVi.examDurationAndQuestions(30, 10), '30 phút • 10 câu');
      expect(l10nVi.examPassed, 'ĐẠT');
      expect(l10nVi.examFailed, 'CHƯA ĐẠT');
      expect(l10nVi.examScorePoints(80), '80 Điểm');
      expect(l10nVi.ankiWebLegacy, 'AnkiWeb (Cũ)');
    });

    test(
      'Enum localized labels work properly for English and Vietnamese',
      () async {
        final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
        final l10nVi = await AppLocalizations.delegate.load(const Locale('vi'));

        // GrammarDifficulty
        expect(
          GrammarDifficulty.recognition.getLocalizedLabel(l10nEn),
          'Recognition',
        );
        expect(
          GrammarDifficulty.recognition.getLocalizedLabel(l10nVi),
          'Nhận biết',
        );
        expect(
          GrammarDifficulty.analysis.getLocalizedLabel(l10nEn),
          'Analysis & Traps',
        );
        expect(
          GrammarDifficulty.analysis.getLocalizedLabel(l10nVi),
          'Phân tích & Bẫy',
        );
        expect(
          GrammarDifficulty.production.getLocalizedLabel(l10nEn),
          'Production',
        );
        expect(
          GrammarDifficulty.production.getLocalizedLabel(l10nVi),
          'Vận dụng thực hành',
        );

        // GrammarCategory
        expect(
          GrammarCategory.tenses.getLocalizedName(l10nEn),
          'Tenses & Aspects',
        );
        expect(
          GrammarCategory.tenses.getLocalizedName(l10nVi),
          'Thì & Khía Cạnh',
        );
        expect(
          GrammarCategory.capstone.getLocalizedName(l10nEn),
          'Capstone Exam Mastery',
        );
        expect(
          GrammarCategory.capstone.getLocalizedName(l10nVi),
          'Tổng Ôn Toàn Diện',
        );

        // ExamCategory
        expect(ExamCategory.jlpt.getLocalizedLabel(l10nEn), 'JLPT');
        expect(
          ExamCategory.jlpt.getLocalizedLabel(l10nVi),
          'Kỳ thi Năng lực Nhật ngữ (JLPT)',
        );

        // WrongQuestionStatus
        expect(
          WrongQuestionStatus.newQuestion.getLocalizedLabel(l10nEn),
          'New Mistake',
        );
        expect(
          WrongQuestionStatus.newQuestion.getLocalizedLabel(l10nVi),
          'Mới sai',
        );

        // Exam & Wrong Notebook Error messages
        expect(l10nEn.examNotFound, 'Exam paper not found or deleted.');
        expect(l10nVi.examNotFound, 'Đề thi không tồn tại hoặc đã bị xóa.');
        expect(l10nEn.examLoadFailed('404'), 'Failed to load exam paper: 404');
        expect(l10nVi.examLoadFailed('404'), 'Lỗi tải đề thi: 404');
        expect(
          l10nEn.examSubmitFailed('Timeout'),
          'Failed to submit exam: Timeout',
        );
        expect(l10nVi.examSubmitFailed('Timeout'), 'Lỗi nộp bài: Timeout');
        expect(
          l10nEn.examDownloadFailed('Network'),
          'Failed to download exam paper: Network',
        );
        expect(
          l10nVi.examDownloadFailed('Network'),
          'Tải đề thi thất bại: Network',
        );
        expect(
          l10nEn.wrongStatusUpdateFailed('Fail'),
          'Failed to update question status: Fail',
        );
        expect(
          l10nVi.wrongStatusUpdateFailed('Fail'),
          'Cập nhật trạng thái thất bại: Fail',
        );
      },
    );

    test('LocaleNotifier can update and reset state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeNotifierProvider), isNull);

      await container
          .read(localeNotifierProvider.notifier)
          .setLocale(const Locale('vi'));
      expect(container.read(localeNotifierProvider), const Locale('vi'));

      await container
          .read(localeNotifierProvider.notifier)
          .setLocale(const Locale('en'));
      expect(container.read(localeNotifierProvider), const Locale('en'));

      await container.read(localeNotifierProvider.notifier).setLocale(null);
      expect(container.read(localeNotifierProvider), isNull);
    });
  });
}
