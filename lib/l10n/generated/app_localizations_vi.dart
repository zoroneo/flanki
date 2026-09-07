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
  String get navBrowser => 'Duyệt thẻ';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get searchDecks => 'Tìm kiếm bộ thẻ...';

  @override
  String get studyNow => 'Học ngay';

  @override
  String get customStudy => 'Ôn tập tùy chọn';

  @override
  String get addNewDeck => 'Tạo bộ thẻ mới';

  @override
  String get importApkg => 'Nạp file .apkg';

  @override
  String get syncAnkiWeb => 'Đồng bộ AnkiWeb';

  @override
  String get dueCards => 'Cần ôn';

  @override
  String get newCards => 'Mới';

  @override
  String get learningCards => 'Đang học';

  @override
  String get totalCards => 'Tổng số thẻ';

  @override
  String get noDecksFound =>
      'Không tìm thấy bộ thẻ nào. Hãy tạo mới hoặc import gói Anki!';

  @override
  String get syncing => 'Đang đồng bộ...';

  @override
  String get syncCompleted => 'Đồng bộ thành công';

  @override
  String get syncFailed => 'Đồng bộ thất bại';

  @override
  String get settingsTitle => 'Cài đặt & Cấu hình';

  @override
  String get accountAndSync => 'TÀI KHOẢN & ĐỒNG BỘ';

  @override
  String get linkedAnkiWeb => 'Đã liên kết AnkiWeb';

  @override
  String get notLinkedAnkiWeb => 'Chưa liên kết AnkiWeb';

  @override
  String get loginToSyncHint =>
      'Đăng nhập để đồng bộ thẻ và tiến độ học với đám mây.';

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
  String get logoutSubtitle => 'Đã xóa mã phiên bảo mật khỏi thiết bị.';

  @override
  String get connectAnkiWeb => 'Kết nối tài khoản AnkiWeb';

  @override
  String get connectAnkiWebSubtitle =>
      'Đồng bộ 2 chiều thẻ flashcard và tiến độ học tập với máy chủ Anki.';

  @override
  String get appPreferences => 'TÙY CHỌN ỨNG DỤNG';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSubtitle => 'Chọn ngôn ngữ hiển thị giao diện';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageSystem => 'Hệ thống';

  @override
  String get languageChanged => 'Đã đổi ngôn ngữ thành công';

  @override
  String get appearance => 'Giao diện';

  @override
  String get appearanceSubtitle => 'Tùy biến chủ đề hiển thị';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get spacedRepetitionAlgorithm => 'THUẬT TOÁN HỌC TẬP';

  @override
  String get enableFsrs => 'Kích hoạt FSRS v5';

  @override
  String get fsrsSubtitle =>
      'Thuật toán lặp lại ngắt quãng tối ưu dựa trên Độ khó, Độ ổn định và Khả năng nhớ.';

  @override
  String get aboutSection => 'THÔNG TIN HỆ THỐNG';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String get searchCardsPlaceholder => 'Tìm câu hỏi, câu trả lời hoặc tag...';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterDue => 'Cần ôn';

  @override
  String get filterNew => 'Thẻ mới';

  @override
  String get filterFlagged => 'Có cờ';

  @override
  String get filterSuspended => 'Tạm dừng';

  @override
  String get noCardsFound => 'Không có thẻ nào';

  @override
  String cardsCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString thẻ';
  }

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
      'Chúc mừng! Bạn đã hoàn thành phiên học hôm nay.';

  @override
  String get studyCompleteTitle => 'Tuyệt vời! Bạn đã hoàn thành';

  @override
  String studyCompleteDesc(int count) {
    return 'Đã hoàn thành $count thẻ trong phiên học này với thuật toán FSRS.';
  }

  @override
  String get backToDecks => 'Quay lại danh sách bộ thẻ';

  @override
  String get authTitle => 'Đăng nhập AnkiWeb';

  @override
  String get authEmail => 'Email';

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
      'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';

  @override
  String get statsTitle => 'Thống kê học tập';

  @override
  String get retentionRate => 'TỶ LỆ GHI NHỚ';

  @override
  String get targetReached => 'Đạt mục tiêu';

  @override
  String targetSuffix(String rate) {
    return '/ mục tiêu $rate';
  }

  @override
  String get reviewedToday => 'Đã ôn hôm nay';

  @override
  String get reviewedDiff => 'Thẻ đã ôn';

  @override
  String get studyTime => 'Thời gian học';

  @override
  String get studyTimePerCard => '~15s mỗi thẻ';

  @override
  String get studyHistory => 'Lịch sử học tập';

  @override
  String streakDays(int days) {
    return '$days ngày liên tục';
  }

  @override
  String get less => 'Ít';

  @override
  String get more => 'Nhiều';

  @override
  String get studyQuestion => 'CÂU HỎI';

  @override
  String get studyAnswer => 'ĐÁP ÁN';

  @override
  String get tapToFlip => 'Chạm vào màn hình để lật thẻ';

  @override
  String get swipeHint => 'Vuốt trái: Again • Vuốt phải: Good';

  @override
  String cardsRemaining(int count) {
    return 'Thẻ còn lại: $count';
  }

  @override
  String get studyAgain => 'Ôn lại lần nữa';

  @override
  String get cardActionTitle => 'Tùy Chọn Thẻ Học';

  @override
  String get flagSelector => 'CẮM CỜ ĐÁNH DẤU';

  @override
  String get buryCard => 'Hoãn thẻ';

  @override
  String get suspendCard => 'Tạm dừng';

  @override
  String get editCardContent => 'Chỉnh sửa nội dung thẻ';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get cancel => 'Hủy';

  @override
  String get frontSide => 'MẶT TRƯỚC';

  @override
  String get backSide => 'MẶT SAU';

  @override
  String get addCardTitle => 'Thêm Thẻ Mới';

  @override
  String get saveCard => 'Lưu thẻ';

  @override
  String get noteType => 'LOẠI THẺ';

  @override
  String get deckLabel => 'BỘ THẺ';

  @override
  String get extraNotes => 'CHÚ THÍCH';

  @override
  String get tagsLabel => 'THẺ PHÂN LOẠI';

  @override
  String get addTagPlaceholder => 'Thêm tag (ví dụ: toeic, grammar)...';

  @override
  String get cramModeTitle => 'Ôn Tập Đột Xuất';

  @override
  String get cramModeDesc =>
      'Tạo phiên học lọc theo nhu cầu cấp tốc trước kỳ thi. Không làm thay đổi lịch thuật toán FSRS gốc.';

  @override
  String get filterMode => 'CHẾ ĐỘ LỌC THẺ';

  @override
  String get byTag => 'Theo Tag';

  @override
  String get flaggedCards => 'Có Cờ';

  @override
  String get reviewAhead => 'Ôn Trước';

  @override
  String get cardLimit => 'GIỚI HẠN SỐ THẺ';

  @override
  String get startCram => 'Bắt đầu ôn tập cấp tốc';

  @override
  String get cramDeckCreated => 'Đã tạo Cram Deck';

  @override
  String cramDeckCreatedDesc(int count, String tag) {
    return 'Đã lọc $count thẻ ôn cấp tốc (#$tag).';
  }

  @override
  String streakDaysBadge(int count) {
    return '$count Ngày Streak';
  }

  @override
  String targetRetentionBadge(String rate) {
    return 'Mục tiêu $rate nhớ';
  }

  @override
  String get cramTagInputLabel => 'TÊN TAG CẦN ÔN';

  @override
  String cardsCountUnit(int count) {
    return '$count thẻ';
  }

  @override
  String get cramButton => 'Cram';

  @override
  String get linkedBadge => 'Đã liên kết';

  @override
  String get syncBadge => 'Sync';

  @override
  String get syncError => 'Lỗi đồng bộ';

  @override
  String get importApkgSuccess => 'Import .apkg thành công!';

  @override
  String importApkgSuccessDesc(int decks, int cards, int media) {
    return 'Đã nạp $decks bộ thẻ, $cards thẻ ($media files media).';
  }

  @override
  String get importApkgError => 'Lỗi import .apkg';

  @override
  String get undoSuccessTitle => 'Đã hoàn tác';

  @override
  String get undoSuccessDesc => 'Khôi phục thẻ vừa đánh giá.';

  @override
  String get addCard => 'Thêm thẻ';

  @override
  String get missingContent => 'Thiếu nội dung';

  @override
  String get missingContentDesc => 'Vui lòng nhập nội dung câu hỏi/mặt trước.';

  @override
  String get cardCreatedSuccess => 'Đã tạo thẻ mới';

  @override
  String get cardCreatedSuccessDesc => 'Đã thêm thẻ vào bộ thẻ.';

  @override
  String get basicNoteType => 'Basic';

  @override
  String get basicNoteSubtitle => 'Câu hỏi / Đáp án';

  @override
  String get clozeNoteType => 'Cloze';

  @override
  String get clozeNoteSubtitle => 'Điền khuyết';

  @override
  String get reversedNoteType => 'Reversed';

  @override
  String get reversedNoteSubtitle => 'Đảo 2 chiều';

  @override
  String get clozeTextLabel => 'VĂN BẢN';

  @override
  String get frontPlaceholder => 'Nhập câu hỏi, từ vựng hoặc khái niệm...';

  @override
  String get clozePlaceholder => 'The capital of France is {{c1::Paris}}.';

  @override
  String get backPlaceholder => 'Nhập giải nghĩa chi tiết, ví dụ minh họa...';

  @override
  String get authScreenTitle => 'Tài khoản AnkiWeb';

  @override
  String get authHeaderTitle => 'Đồng bộ AnkiWeb';

  @override
  String get authHeaderDesc =>
      'Đăng nhập tài khoản AnkiWeb để đồng bộ hai chiều toàn bộ bộ thẻ, lịch ôn FSRS và tiến độ học tập.';

  @override
  String get authEmailLabel => 'EMAIL ANKIWEB';

  @override
  String get authPasswordLabel => 'MẬT KHẨU';

  @override
  String get authPasswordPlaceholder => 'Nhập mật khẩu...';

  @override
  String get authSubmitButton => 'Đăng nhập & Bắt đầu Sync';

  @override
  String get authSubmitting => 'Đang xác thực...';

  @override
  String get authMissingInfoTitle => 'Thiếu thông tin';

  @override
  String get authMissingInfoDesc =>
      'Vui lòng nhập đầy đủ Email và Mật khẩu AnkiWeb.';

  @override
  String get authSuccessToastTitle => 'Đăng nhập thành công';

  @override
  String authSuccessToastDesc(String email) {
    return 'Đã liên kết tài khoản $email với Flanki.';
  }

  @override
  String get authGuestMode => 'Dùng thử ngoại tuyến';

  @override
  String get authSecurityNote =>
      'Bảo mật: Flanki chỉ lưu trữ mã phiên HostKey trong Secure Storage của thiết bị, không lưu lại mật khẩu thô của bạn.';

  @override
  String intervalMinutes(int count) {
    return '$count phút';
  }

  @override
  String intervalHours(int count) {
    return '$count giờ';
  }

  @override
  String intervalDays(int count) {
    return '$count ngày';
  }

  @override
  String intervalMonths(String count) {
    return '$count tháng';
  }

  @override
  String intervalYears(String count) {
    return '$count năm';
  }

  @override
  String deckPrefix(String deck) {
    return 'Bộ thẻ: $deck';
  }

  @override
  String intervalBadge(int days) {
    return 'Khoảng cách $days ngày';
  }

  @override
  String get newBadge => 'Mới';

  @override
  String studyMinutesUnit(int count) {
    return '${count}p';
  }

  @override
  String get targetNotReached => 'Đang tiến bộ';

  @override
  String targetRetentionRate(String rate) {
    return 'Mục tiêu $rate';
  }

  @override
  String get algorithmLabel => 'Thuật toán';

  @override
  String get themeZinc => 'Chủ đề Zinc';

  @override
  String get ankiRustCore => 'Nhân Anki Rust';

  @override
  String get createDeckTitle => 'Tạo bộ thẻ';

  @override
  String get createDeckDesc =>
      'Tạo bộ thẻ mới để phân loại và ôn tập flashcard.';

  @override
  String get deckNameLabel => 'TÊN BỘ THẺ';

  @override
  String get deckNamePlaceholder => 'Ví dụ: Tiếng Anh::Từ vựng';

  @override
  String get deckDescLabel => 'MÔ TẢ (TÙY CHỌN)';

  @override
  String get deckDescPlaceholder => 'Mô tả ngắn về bộ thẻ này...';

  @override
  String get deckCreatedSuccess => 'Đã tạo bộ thẻ';

  @override
  String deckCreatedSuccessDesc(String name) {
    return 'Bộ thẻ \"$name\" đã được tạo thành công.';
  }

  @override
  String get deckNameRequired => 'Vui lòng nhập tên bộ thẻ.';

  @override
  String get deckAlreadyExists => 'Bộ thẻ với tên này đã tồn tại.';

  @override
  String get deleteCard => 'Xóa thẻ';

  @override
  String get deleteCardTitle => 'Xóa thẻ';

  @override
  String get deleteCardConfirm =>
      'Bạn có chắc chắn muốn xóa thẻ này? Thao tác này sẽ xóa thẻ khỏi bộ sưu tập.';

  @override
  String get cardDeleted => 'Đã xóa thẻ';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get delete => 'Xóa';

  @override
  String get sm2Subtitle => 'Thuật toán SM-2 truyền thống';

  @override
  String get selectApkgOrZipPrompt => 'Vui lòng chọn file .apkg hoặc .zip';

  @override
  String subdecksCount(int count) {
    return '$count bộ thẻ con';
  }

  @override
  String get importedFromApkg => 'Được import từ gói Anki .apkg';

  @override
  String badgeDue(int count) {
    return '$count ôn';
  }

  @override
  String badgeNew(int count) {
    return '$count mới';
  }

  @override
  String badgeTotalCards(int count) {
    return '$count thẻ';
  }

  @override
  String get createDeckAction => 'Tạo bộ thẻ mới';

  @override
  String get importApkgAction => 'Nạp file Anki (.apkg)';

  @override
  String get cramAction => 'Học cấp tốc (Cram)';

  @override
  String get deckHierarchyTip =>
      'Mẹo: Dùng dấu :: để tạo phân cấp (VD: Tiếng Anh::Unit 01)';

  @override
  String get typeAnswerPlaceholder => 'Nhập câu trả lời...';

  @override
  String get correctAnswerLabel => 'Chính xác!';

  @override
  String get yourAnswerLabel => 'Đã nhập: ';

  @override
  String get expectedAnswerLabel => 'Đáp án đúng: ';

  @override
  String get answerLabel => 'Đáp án: ';

  @override
  String get stabilityLabel => 'Độ bền nhớ (Stability)';

  @override
  String get difficultyLabel => 'Độ khó (Difficulty)';

  @override
  String get repsLabel => 'Số lần ôn (Reps)';

  @override
  String get lapsesLabel => 'Số lần quên (Lapses)';

  @override
  String get newCardsPerDay => 'Thẻ mới mỗi ngày';

  @override
  String get maxReviewsPerDay => 'Ôn tập tối đa mỗi ngày';

  @override
  String get selectCardToViewDetails =>
      'Chọn thẻ bên trái để xem và sửa chi tiết';

  @override
  String get unsuspendCard => 'Bỏ tạm dừng';

  @override
  String get fsrsScheduleTitle => 'FSRS THUẬT TOÁN & LỊCH ÔN TẬP';

  @override
  String get intervalLabel => 'Khoảng cách (Interval)';

  @override
  String get repsAndLapsesLabel => 'Lặp / Quên';

  @override
  String get dartCoreEngine => 'Nhân Dart (Drift SQLite)';

  @override
  String get submitAnswer => 'Kiểm tra';

  @override
  String get showAnswer => 'Hiện đáp án';

  @override
  String get hideAnswer => 'Ẩn đáp án';

  @override
  String get syncMediaOnly => 'Đồng bộ Media (Ảnh & Âm thanh)';

  @override
  String get syncingMedia => 'Đang tải tệp media...';
}
