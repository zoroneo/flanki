// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Flanki';

  @override
  String get navDecks => 'Bộ thẻ';

  @override
  String get navBrowser => 'Tìm thẻ';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get searchDecks => 'Tìm kiếm bộ thẻ...';

  @override
  String get studyNow => 'Học ngay';

  @override
  String get customStudy => 'Tùy chỉnh buổi học';

  @override
  String get addNewDeck => 'Tạo bộ thẻ mới';

  @override
  String get importApkg => 'Nhập file .apkg';

  @override
  String get syncAnkiWeb => 'Đồng bộ AnkiWeb';

  @override
  String get dueCards => 'Cần ôn';

  @override
  String get newCards => 'Thẻ mới';

  @override
  String get learningCards => 'Đang học';

  @override
  String get totalCards => 'Tổng số thẻ';

  @override
  String get noDecksFound =>
      'Chưa có bộ thẻ nào. Hãy tạo mới hoặc nhập từ AnkiWeb!';

  @override
  String get syncing => 'Đang đồng bộ...';

  @override
  String get syncCompleted => 'Đồng bộ hoàn tất thành công';

  @override
  String get syncFailed => 'Đồng bộ thất bại';

  @override
  String get settingsTitle => 'Cài Đặt & Cấu Hình';

  @override
  String get accountAndSync => 'TÀI KHOẢN & ĐỒNG BỘ';

  @override
  String get linkedAnkiWeb => 'Đã liên kết AnkiWeb';

  @override
  String get notLinkedAnkiWeb => 'Chưa liên kết AnkiWeb';

  @override
  String get loginToSyncHint => 'Đăng nhập để đồng bộ thẻ và tiến độ đám mây.';

  @override
  String get readyToSync => 'Sẵn sàng đồng bộ';

  @override
  String syncedAt(String time) {
    return 'Đồng bộ lúc: $time';
  }

  @override
  String get logout => 'Đăng xuất';

  @override
  String get loggedOut => 'Đã đăng xuất';

  @override
  String get logoutSubtitle => 'Đã xóa session token an toàn khỏi thiết bị.';

  @override
  String get connectAnkiWeb => 'Kết nối tài khoản AnkiWeb';

  @override
  String get connectAnkiWebSubtitle =>
      'Đồng bộ 2 chiều tiến độ học tập, thẻ ghi nhớ với máy chủ Anki.';

  @override
  String get appPreferences => 'TÙY CHỈNH HỆ THỐNG';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSubtitle => 'Chọn ngôn ngữ hiển thị giao diện';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageChanged => 'Đã đổi ngôn ngữ thành công';

  @override
  String get appearance => 'Giao diện';

  @override
  String get appearanceSubtitle => 'Tùy chỉnh theme và màu sắc';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get spacedRepetitionAlgorithm => 'THUẬT TOÁN GHI NHỚ (SRS)';

  @override
  String get enableFsrs => 'Kích hoạt FSRS v4.5';

  @override
  String get fsrsSubtitle =>
      'Thuật toán lặp lại ngắt quãng hiện đại tối ưu hơn SM-2 cổ điển của Anki.';

  @override
  String get aboutSection => 'THÔNG TIN ỨNG DỤNG';

  @override
  String get appVersion => 'Phiên bản';

  @override
  String get cardBrowserTitle => 'Tìm kiếm & Quản lý Thẻ';

  @override
  String get searchCardsPlaceholder => 'Tìm theo từ khóa, tag...';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterDue => 'Cần ôn';

  @override
  String get filterNew => 'Thẻ mới';

  @override
  String cardsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count thẻ',
      one: '1 thẻ',
      zero: '0 thẻ',
    );
    return '$_temp0';
  }

  @override
  String get showAnswer => 'Hiện đáp án';

  @override
  String get ratingAgain => 'Học lại';

  @override
  String get ratingHard => 'Khó';

  @override
  String get ratingGood => 'Tốt';

  @override
  String get ratingEasy => 'Dễ';

  @override
  String get studySessionComplete =>
      'Chúc mừng! Bạn đã hoàn thành bài học hôm nay.';

  @override
  String get backToDecks => 'Về danh sách bộ thẻ';

  @override
  String get authTitle => 'Đăng nhập AnkiWeb';

  @override
  String get authEmail => 'Email AnkiWeb';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authLoginButton => 'Đăng nhập';

  @override
  String get authLoggingIn => 'Đang đăng nhập...';

  @override
  String get authSuccess => 'Đăng nhập thành công!';

  @override
  String get authFailed =>
      'Đăng nhập thất bại. Vui lòng kiểm tra lại tài khoản.';
}
