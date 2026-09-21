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
  String get navGrammar => 'Ngữ pháp';

  @override
  String get navExams => 'Đề thi';

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
  String get sync => 'Đồng bộ';

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
  String get settingsTitle => 'Cài đặt & cấu hình';

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
  String get openSourceLicenses => 'Giấy phép mã nguồn mở';

  @override
  String get privacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get searchLicensesPlaceholder => 'Tìm kiếm gói thư viện...';

  @override
  String thirdPartyLicenses(int count) {
    return 'Thư viện bên thứ ba ($count)';
  }

  @override
  String get noLicensesFound => 'Không tìm thấy thư viện phù hợp';

  @override
  String get licenseCopied => 'Đã sao chép nội dung giấy phép';

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
  String get loadMoreCards => 'Tải thêm thẻ';

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
  String get tapToFlip => 'Hiển thị đáp án';

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
  String get noCardSelected => 'Chưa chọn thẻ nào';

  @override
  String get unsuspendCard => 'Bỏ tạm dừng';

  @override
  String get fsrsScheduleTitle => 'FSRS THUẬT TOÁN & LỊCH ÔN TẬP';

  @override
  String get intervalLabel => 'Khoảng cách (Interval)';

  @override
  String get repsAndLapsesLabel => 'Lặp / Quên';

  @override
  String get dartCoreEngine => 'Dart (Drift SQLite)';

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

  @override
  String get addCardButton => 'Thêm thẻ';

  @override
  String get clozeDeletion => 'Thẻ điền khuyết (Cloze)';

  @override
  String get connected => 'Đã kết nối';

  @override
  String get offlineMode => 'Chế độ Ngoại tuyến';

  @override
  String get syncConflictTitle => 'Xung đột đồng bộ AnkiWeb';

  @override
  String get syncConflictDesc =>
      'Cả thiết bị này và AnkiWeb đều có dữ liệu học tập hoặc thay đổi thẻ mới kể từ lần đồng bộ trước. Hệ thống không thể gộp tự động hai phiên làm việc độc lập.';

  @override
  String get previousSyncLabel => 'Lần đồng bộ trước:';

  @override
  String get ankiWebUpdateLabel => 'Cập nhật trên AnkiWeb:';

  @override
  String get selectVersionToKeep =>
      'Vui lòng chọn bản dữ liệu bạn muốn giữ lại:';

  @override
  String get mergeCollectionsTitle => 'Hợp nhất thông minh (Khuyên dùng)';

  @override
  String get mergeCollectionsDesc =>
      'Giữ lại toàn bộ lượt học từ cả hai thiết bị và lấy tiến độ mới nhất cho từng thẻ.';

  @override
  String get recommendedBadge => 'Khuyên dùng';

  @override
  String get uploadToCloudTitle => 'Đẩy lên AnkiWeb (Ghi đè đám mây)';

  @override
  String get uploadToCloudDesc =>
      'Giữ toàn bộ tiến độ và lịch sử học của máy này để ghi đè lên AnkiWeb Cloud.';

  @override
  String get downloadFromCloudTitle => 'Tải về từ AnkiWeb (Ghi đè thiết bị)';

  @override
  String get downloadFromCloudDesc =>
      'Lấy toàn bộ dữ liệu từ AnkiWeb Cloud về và thay thế dữ liệu trên máy này.';

  @override
  String get unknownTime => 'Chưa rõ';

  @override
  String get preparingUpload => 'Đang chuẩn bị tải lên AnkiWeb...';

  @override
  String get connectingToAnkiWeb => 'Đang kết nối tới AnkiWeb...';

  @override
  String get updateAvailable => 'Có bản cập nhật mới';

  @override
  String get updateChangelog => 'Nội dung cập nhật:';

  @override
  String get downloadingUpdate => 'Đang tải bản cài đặt...';

  @override
  String get later => 'Để sau';

  @override
  String get openDownloadPage => 'Mở trang tải về';

  @override
  String get restartAndInstall => 'Khởi động lại & Cập nhật';

  @override
  String get downloadAndInstall => 'Tải & Cập nhật';

  @override
  String get downloadInBackground => 'Tải trong nền';

  @override
  String get cancelDownload => 'Hủy tải';

  @override
  String get updateReadyTitle => 'Bản cập nhật đã sẵn sàng';

  @override
  String updateReadySubtitle(String version) {
    return 'Bản cập nhật v$version đã được tải về sẵn sàng cài đặt';
  }

  @override
  String get updateReadyAction => 'Cài đặt ngay';

  @override
  String updateBannerTitle(String version) {
    return 'Có bản cập nhật mới (v$version)';
  }

  @override
  String get updateBannerSubtitle => 'Nhấn để xem chi tiết và cập nhật';

  @override
  String get updateAction => 'Cập nhật';

  @override
  String get checkingForUpdates => 'Đang kiểm tra...';

  @override
  String newVersionBadge(String version) {
    return 'Bản mới v$version';
  }

  @override
  String get latestVersionStatus => 'Mới nhất';

  @override
  String get checkForUpdates => 'Kiểm tra';

  @override
  String get cramDeckDefaultDesc =>
      'Bộ thẻ ôn tập đột xuất (Custom Study) không ảnh hưởng lịch FSRS chính.';

  @override
  String get importedDeckDefaultDesc => 'Được import từ gói Anki .apkg';

  @override
  String get authEmailPasswordEmpty => 'Email và mật khẩu không được để trống.';

  @override
  String get authInvalidCredentials =>
      'Email hoặc mật khẩu AnkiWeb không chính xác.';

  @override
  String get authTooManyAttempts =>
      'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau ít phút.';

  @override
  String get authServerResponseInvalid =>
      'Phản hồi không hợp lệ từ máy chủ AnkiWeb.';

  @override
  String authNetworkError(String error) {
    return 'Không thể kết nối máy chủ AnkiWeb. Vui lòng kiểm tra mạng: $error';
  }

  @override
  String authUnknownError(String error) {
    return 'Lỗi kết nối AnkiWeb: $error';
  }

  @override
  String get syncConnecting => 'Đang kết nối AnkiWeb...';

  @override
  String get syncDownloadingCollection =>
      'Đang tải dữ liệu bộ thẻ từ AnkiWeb...';

  @override
  String get syncProcessingData => 'Đang xử lý thẻ & lưu cơ sở dữ liệu...';

  @override
  String get syncCheckingMedia => 'Đang kiểm tra tệp media (ảnh & âm thanh)...';

  @override
  String syncDownloadingMediaProgress(int downloaded, int total) {
    return 'Đang tải media ($downloaded/$total)...';
  }

  @override
  String get syncCompressingUpload => 'Đang nén và chuẩn bị tải lên AnkiWeb...';

  @override
  String get syncUploadingCloud => 'Đang tải dữ liệu lên AnkiWeb Cloud...';

  @override
  String get syncUploadComplete => 'Tải lên hoàn tất!';

  @override
  String get syncSessionExpired =>
      'Phiên đăng nhập AnkiWeb đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get syncNoInternet => 'Không có kết nối mạng internet.';

  @override
  String get syncConflictDetected =>
      'Phát hiện xung đột: Cả AnkiWeb và thiết bị này đều có dữ liệu học tập mới.';

  @override
  String get trayOpenFlanki => 'Mở Flanki';

  @override
  String get trayStudyNow => 'Ôn tập ngay';

  @override
  String get trayExit => 'Thoát hoàn toàn';

  @override
  String get notificationDailyChannelName => 'Nhắc nhở học tập';

  @override
  String get notificationDailyChannelDesc =>
      'Thông báo nhắc nhở lịch học flashcard hàng ngày';

  @override
  String get notificationDailyTitle => 'Đến giờ học Flanki! 🦉';

  @override
  String notificationDailyBodyDue(int count) {
    return 'Bạn có $count thẻ đang chờ ôn tập hôm nay. Ôn ngay để nhớ lâu!';
  }

  @override
  String get notificationDailyBodyGeneric =>
      'Dành 5 phút mỗi ngày cùng Flanki để duy trì phản xạ từ vựng nào!';

  @override
  String get notificationStreakChannelName => 'Cứu chuỗi Streak';

  @override
  String get notificationStreakChannelDesc =>
      'Cảnh báo khẩn cấp trước nửa đêm để bảo vệ chuỗi học tập';

  @override
  String notificationStreakTitleActive(int count) {
    return 'Cứu chuỗi $count ngày của bạn! 🔥';
  }

  @override
  String get notificationStreakTitleInactive => 'Hôm nay bạn chưa học! ⏳';

  @override
  String get notificationStreakBodyActive =>
      'Chỉ còn ít giờ trước nửa đêm! Ôn 3 phút để giữ chuỗi học liên tiếp.';

  @override
  String get notificationStreakBodyInactive =>
      'Dành chút thời gian trước khi kết thúc ngày để tạo chuỗi học mới.';

  @override
  String get notificationTestTitle => 'Flanki: Kiểm tra thông báo 🚀';

  @override
  String get notificationTestBody =>
      'Hệ thống thông báo hoạt động chính xác theo chuẩn Duolingo!';

  @override
  String get settingsStudyReminders => 'NHẮC NHỞ HỌC TẬP';

  @override
  String get settingsDailyReminder => 'Nhắc nhở học hàng ngày';

  @override
  String get settingsDailyReminderSubtitle =>
      'Thông báo đúng giờ để duy trì thói quen học flashcard';

  @override
  String get settingsReminderTime => 'Thời gian nhắc nhở';

  @override
  String get settingsStreakSaver => 'Cứu chuỗi Streak 🔥';

  @override
  String get settingsStreakSaverSubtitle =>
      'Cảnh báo khẩn cấp trước nửa đêm nếu chưa học. Tự động hủy nếu đã ôn tập hôm nay.';

  @override
  String get settingsMinimizeToTray => 'Thu nhỏ xuống khay hệ thống (Tray)';

  @override
  String get settingsMinimizeToTraySubtitle =>
      'Bấm nút đóng (X) sẽ ẩn app xuống khay hệ thống để duy trì bộ đếm nhắc nhở.';

  @override
  String get settingsLaunchAtStartup => 'Khởi động cùng máy tính';

  @override
  String get settingsLaunchAtStartupSubtitle =>
      'Tự động chạy ngầm Flanki khi đăng nhập máy tính.';

  @override
  String get settingsTestNotificationSent => 'Đã gửi thông báo thử nghiệm!';

  @override
  String get settingsTestNotificationCheck =>
      'Kiểm tra thanh thông báo hệ thống.';

  @override
  String get settingsTestNotificationButton => 'Thử nghiệm thông báo ngay';

  @override
  String syncSuccessWithMedia(int deckCount, int cardCount, String media) {
    return 'Đã tải thành công $deckCount bộ thẻ, $cardCount thẻ$media từ AnkiWeb.';
  }

  @override
  String syncMediaCountPart(int count) {
    return ' và $count tệp media';
  }

  @override
  String syncMediaSyncedSuccess(int count) {
    return 'Đã đồng bộ thành công $count tệp media từ AnkiWeb.';
  }

  @override
  String get syncCollectionAndMediaUpToDate =>
      'Dữ liệu bộ thẻ và media đã khớp với AnkiWeb Cloud.';

  @override
  String get syncFirstTime => 'Lần đồng bộ đầu tiên.';

  @override
  String get syncLocalChangesToPush =>
      'Thiết bị này có tiến độ học mới cần đẩy lên AnkiWeb.';

  @override
  String get syncRemoteChangesToPull =>
      'AnkiWeb có tiến độ học mới từ thiết bị khác cần kéo về.';

  @override
  String get syncAlreadyFullySynced =>
      'Dữ liệu giữa thiết bị và AnkiWeb đã đồng bộ hoàn toàn.';

  @override
  String get syncUploadSuccess =>
      'Đã tải thành công toàn bộ dữ liệu & lịch sử học lên AnkiWeb Cloud.';

  @override
  String get syncNoMediaChanges => 'Không có thay đổi media mới.';

  @override
  String get syncAllMediaUpToDate => 'Tất cả media đã được cập nhật.';

  @override
  String syncMediaDownloadedSuccess(int count) {
    return 'Đã tải thành công $count tệp media từ AnkiWeb.';
  }

  @override
  String syncServerError(int statusCode, String message) {
    return 'Lỗi máy chủ AnkiWeb ($statusCode): $message';
  }

  @override
  String syncCheckStatusServerError(int statusCode) {
    return 'Lỗi kiểm tra trạng thái máy chủ ($statusCode).';
  }

  @override
  String syncCheckError(String error) {
    return 'Lỗi kiểm tra đồng bộ: $error';
  }

  @override
  String syncUploadError(String error) {
    return 'Lỗi tải lên AnkiWeb: $error';
  }

  @override
  String syncMediaError(String error) {
    return 'Lỗi đồng bộ media AnkiWeb: $error';
  }

  @override
  String syncMediaBatchError(String range, int statusCode, String message) {
    return 'Lỗi tải media batch ($range): $statusCode $message';
  }

  @override
  String syncCollectionError(String error) {
    return 'Lỗi đồng bộ AnkiWeb: $error';
  }

  @override
  String cramDeckTitlePrefix(String name) {
    return '⚡ Ôn cấp tốc: $name';
  }

  @override
  String cramDeckTitleWithTag(String name, String tag) {
    return '⚡ Ôn cấp tốc: $name (#$tag)';
  }

  @override
  String get grammarAcademicTitle => 'Ngữ pháp học thuật';

  @override
  String get grammarAcademicSubtitle =>
      '36 Chuyên Đề C1/C2 Chuẩn Mực SAT • GRE • GMAT • THPTQG Chuyên';

  @override
  String grammarClearGhostsButton(int count) {
    return 'Xóa $count Câu Sai (Ghost)';
  }

  @override
  String get grammarMetricTotalUnits => 'Tổng chuyên đề';

  @override
  String get grammarMetricCompletedExercises => 'Bài tập đã làm';

  @override
  String get grammarMetricDueGhosts => 'Đến hạn / Ghost';

  @override
  String get grammarSearchPlaceholder => 'Tìm chuyên đề, thì, cấu trúc...';

  @override
  String grammarFilterAll(int count) {
    return 'Tất Cả ($count)';
  }

  @override
  String get grammarTheoryButton => 'Lý Thuyết';

  @override
  String get grammarPracticeButton => 'Luyện Tập';

  @override
  String grammarMasteryPercentage(String percentage) {
    return '$percentage% Thành thạo';
  }

  @override
  String grammarCompletedProgress(int completed, int total) {
    return 'Đã làm: $completed / $total';
  }

  @override
  String grammarErrorLoadCatalog(String error) {
    return 'Lỗi tải danh mục: $error';
  }

  @override
  String get grammarTheoryScreenTitle => 'Lý Thuyết Chuyên Đề';

  @override
  String grammarPracticeCountButton(int count) {
    return 'Luyện Tập ($count câu)';
  }

  @override
  String grammarStartPracticeNowButton(int count) {
    return 'Bắt Đầu Luyện Tập $count Câu Ngay';
  }

  @override
  String get grammarCoreConceptTitle => 'Tư Duy Bản Xứ Cốt Lõi';

  @override
  String get grammarFormulasTitle => 'Công Thức Cú Pháp (Formulas)';

  @override
  String get grammarCommonTrapsTitle => 'Bẫy Thi Cử Kinh Điển (Common Traps)';

  @override
  String get grammarExtraGuidesTitle => 'Chuyên Đề Nâng Cao Mở Rộng';

  @override
  String get grammarUnitNotFound => 'Không tìm thấy chuyên đề ngữ pháp này.';

  @override
  String grammarErrorLoadUnit(String error) {
    return 'Lỗi nạp bài học: $error';
  }

  @override
  String get grammarPracticeScreenTitle => 'Luyện Tập Ngữ Pháp';

  @override
  String get grammarGhostReviewScreenTitle => 'Thử Thách Ghost Review';

  @override
  String grammarQuestionCounter(int current, int total) {
    return 'Câu $current / $total';
  }

  @override
  String get grammarSubmitAnswer => 'Kiểm Tra Đáp Án';

  @override
  String get grammarExitDialogTitle => 'Thoát Phiên Luyện Tập?';

  @override
  String get grammarExitDialogContent =>
      'Tiến độ của các câu đã làm vẫn được lưu vào hệ thống FSRS. Bạn có chắc muốn dừng bài học lúc này?';

  @override
  String get grammarContinueStudying => 'Tiếp tục làm';

  @override
  String get grammarExitConfirm => 'Thoát';

  @override
  String get grammarPracticeSummaryTitle => 'Tổng Kết Phiên Luyện Tập';

  @override
  String get grammarGhostChallengeCompleted => 'Hoàn Thành Thử Thách Ghost!';

  @override
  String get grammarPerfectScoreTitle => 'Xuất Sắc! Hoàn Hảo 100%!';

  @override
  String get grammarUnitSessionCompleted => 'Hoàn Thành Bài Học!';

  @override
  String get grammarGhostChallengeCompletedSubtitle =>
      'Bạn đã ôn tập lại các câu hỏi từng làm sai.';

  @override
  String get grammarUnitSessionCompletedSubtitle =>
      'Hệ thống đã cập nhật chu kỳ ghi nhớ FSRS v4.5 vào bộ não của bạn.';

  @override
  String get grammarStatCorrectCount => 'Số câu đúng';

  @override
  String get grammarStatAccuracy => 'Độ chính xác';

  @override
  String get grammarStatGhostsToFix => 'Cần sửa lỗi';

  @override
  String grammarFixGhostsNow(int count) {
    return 'Xóa Điểm Yếu Ngay ($count câu sai)';
  }

  @override
  String get grammarBackToCatalog => 'Về Danh Mục Chuyên Đề';

  @override
  String get grammarRestartSession => 'Luyện Tập Lại Bài Này';

  @override
  String get grammarAnswerCorrect => 'Chính xác! Rất tốt!';

  @override
  String get grammarAnswerIncorrect => 'Chưa chính xác — Ghi nhớ bẫy này!';

  @override
  String get grammarSectionTranslation => 'Dịch nghĩa câu';

  @override
  String get grammarSectionKeySignal => 'Dấu hiệu nhận diện (Key Signal)';

  @override
  String get grammarSectionRule => 'Quy tắc bản xứ';

  @override
  String get grammarSectionWhyCorrect => 'Lý giải cặn kẽ';

  @override
  String get grammarSectionDistractors => 'Phân tích bẫy (Distractors)';

  @override
  String get grammarNextQuestion => 'Câu Tiếp Theo';

  @override
  String get grammarViewResults => 'Xem Tổng Kết Bài Học';

  @override
  String get grammarErrorIdInstruction =>
      'Tìm 1 lỗi sai ngữ pháp trong 4 vị trí [A], [B], [C], [D]';

  @override
  String get grammarClozeInstruction => 'Điền dạng đúng của từ vào chỗ trống';

  @override
  String get grammarClozePlaceholder => 'Nhập từ/cụm từ đúng...';

  @override
  String get grammarClozeSubmittedCorrect => 'Chính xác!';

  @override
  String get grammarClozeSubmittedIncorrect => 'Chưa chính xác!';

  @override
  String grammarClozeYourAnswer(String answer) {
    return 'Bạn đã trả lời: \"$answer\"';
  }

  @override
  String get grammarClozeStandardAnswer => 'Đáp án chuẩn: ';

  @override
  String get grammarClozeBlank => '(Bỏ trống)';

  @override
  String get grammarTypeChoice => 'TRẮC NGHIỆM';

  @override
  String get grammarTypeErrorId => 'TÌM LỖI SAI';

  @override
  String get grammarTypeCloze => 'ĐIỀN TỪ';

  @override
  String get grammarLevelFoundation => 'Level 1: Foundation';

  @override
  String get grammarLevelIntermediate => 'Level 2: Intermediate';

  @override
  String get grammarLevelAdvanced => 'Level 3: Advanced C1/C2';

  @override
  String get grammarTabConcept => 'Cốt lõi';

  @override
  String get grammarTabFormulas => 'Công thức';

  @override
  String get grammarTabTraps => 'Bẫy thi';

  @override
  String get grammarTabGuides => 'Mở rộng';

  @override
  String get audioPlay => 'Phát âm thanh';

  @override
  String get audioStop => 'Dừng âm thanh';

  @override
  String get privacyPolicyTagline =>
      'Ưu tiên cục bộ • Không theo dõi • Mã nguồn mở';

  @override
  String get privacySection1Title => '1. Lưu trữ ưu tiên cục bộ';

  @override
  String get privacySection1Content =>
      'Tất cả bộ thẻ, thẻ ghi nhớ, lịch học và lịch sử ôn tập đều được lưu trữ cục bộ trên thiết bị của bạn qua SQLite. Flanki không truyền nội dung thẻ cá nhân của bạn lên bất kỳ máy chủ nào của nhà phát triển.';

  @override
  String get privacySection2Title => '2. Không theo dõi & Không quảng cáo';

  @override
  String get privacySection2Content =>
      'Chúng tôi không tích hợp bất kỳ framework theo dõi bên thứ ba, SDK phân tích hành vi (như Google Analytics, Firebase, Sentry) hay mạng quảng cáo nào. Chúng tôi không bán hoặc thương mại hóa dữ liệu cá nhân của bạn.';

  @override
  String get privacySection3Title => '3. Đồng bộ hóa AnkiWeb tùy chọn';

  @override
  String get privacySection3Content =>
      'Nếu bạn chọn đăng nhập và đồng bộ với AnkiWeb, thông tin đăng nhập và dữ liệu bộ sưu tập được truyền trực tiếp giữa thiết bị của bạn và máy chủ AnkiWeb chính thức qua HTTPS mã hóa. Mã phiên xác thực được lưu trong kho bảo mật gốc của nền tảng (Android Keystore, iOS Keychain, Windows DPAPI). Chúng tôi không bao giờ lưu trữ hay truy cập mật khẩu của bạn.';

  @override
  String get privacySection4Title => '4. Kiểm tra cập nhật ứng dụng';

  @override
  String get privacySection4Content =>
      'Flanki định kỳ kiểm tra qua API GitHub Releases công khai để thông báo khi có phiên bản mới. Không có thông tin định danh người dùng hay dấu vân tay thiết bị nào được gửi đi trong quá trình kiểm tra.';

  @override
  String get privacySection5Title => '5. Thông báo cục bộ';

  @override
  String get privacySection5Content =>
      'Nhắc nhở học tập hàng ngày và thông báo chuỗi ngày học được lên lịch hoàn toàn cục bộ trên thiết bị của bạn. Không sử dụng máy chủ push notification từ xa.';

  @override
  String get privacySection6Title => '6. Kiểm soát & Xóa dữ liệu';

  @override
  String get privacySection6Content =>
      'Bạn nắm quyền kiểm soát 100% dữ liệu của mình. Bạn có thể xóa bộ thẻ, xóa dữ liệu ứng dụng hoặc gỡ cài đặt ứng dụng bất cứ lúc nào để xóa bỏ ngay lập tức toàn bộ nội dung đã lưu.';

  @override
  String get privacySection7Title => '7. Toàn văn chính sách & Mã nguồn';

  @override
  String get privacySection7Content =>
      'Flanki là một dự án mã nguồn mở. Bạn có thể kiểm tra toàn bộ mã nguồn và đọc toàn văn Chính sách quyền riêng tư tại: https://github.com/zoroneo/flanki';

  @override
  String get grammarTableOfContents => 'Mục Lục Chuyên Đề';

  @override
  String get grammarShortcutsTitle => 'Phím tắt & Hướng dẫn';

  @override
  String get grammarShortcutSelectCheck => 'Chọn & kiểm tra đáp án';

  @override
  String get grammarShortcutNextQuestion => 'Chuyển câu kế tiếp';

  @override
  String get grammarPracticeTipTitle => 'Gợi ý làm bài';

  @override
  String get grammarTipChoice =>
      'Đọc kỹ câu hỏi, tìm từ khóa hoặc thì của câu trước khi chọn đáp án.';

  @override
  String get grammarTipErrorId =>
      'Xác định thành phần bị sai ngữ pháp giữa các phần được gạch chân A, B, C, D.';

  @override
  String get grammarTipCloze =>
      'Điền từ hoặc cụm từ thích hợp vào ô trống để hoàn thiện câu đúng ngữ pháp.';

  @override
  String grammarGhostsCount(int count) {
    return '$count Ghost';
  }

  @override
  String grammarUnitsCount(int count) {
    return '$count Chuyên đề';
  }

  @override
  String grammarBadgeDue(int count) {
    return '$count Cần ôn';
  }

  @override
  String grammarOptionBadge(String letter) {
    return 'Đáp án $letter';
  }

  @override
  String get updateDownloadFailed => 'Tải tệp cài đặt thất bại';

  @override
  String get desktopSubtitle => 'Máy tính • Zinc';

  @override
  String get rslibLinked => 'rslib (Đã liên kết)';

  @override
  String get unknown => 'Không xác định';

  @override
  String get flankiCloud => 'Đám mây Flanki';

  @override
  String get cloudSyncSubtitle =>
      'Tự động đồng bộ thời gian thực giữa các thiết bị';

  @override
  String get signInCloud => 'Đăng nhập Cloud';

  @override
  String get signUpCloud => 'Tạo tài khoản Cloud';

  @override
  String get cloudAccount => 'Tài khoản Cloud';

  @override
  String get cloudNotConnected => 'Chưa kết nối tài khoản Cloud';

  @override
  String get cloudConnected => 'Đã kết nối Cloud';

  @override
  String pendingChanges(int count) {
    return '$count thay đổi chờ đồng bộ';
  }

  @override
  String get signOutConfirmTitle => 'Đăng xuất khỏi Cloud?';

  @override
  String get signOutConfirmDesc =>
      'Dữ liệu thẻ và lịch sử học tập cục bộ vẫn được bảo toàn trên thiết bị này.';

  @override
  String get authInvalidEmail => 'Vui lòng nhập địa chỉ email hợp lệ.';

  @override
  String get authPasswordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự.';

  @override
  String get authSuccessSubtitle => 'Tạo tài khoản và đăng nhập thành công.';

  @override
  String get examBank => 'Ngân hàng đề thi';

  @override
  String get wrongNotebook => 'Sổ tay câu sai';

  @override
  String get searchExamsPlaceholder =>
      'Tìm kiếm đề thi theo tên hoặc cấp độ...';

  @override
  String get allFilter => 'Tất cả';

  @override
  String allCountFilter(int count) {
    return 'Tất cả ($count)';
  }

  @override
  String examDurationAndQuestions(int duration, int count) {
    return '$duration phút • $count câu';
  }

  @override
  String get examDownloadedOffline => 'Đã tải về';

  @override
  String get downloadExam => 'Tải về';

  @override
  String get downloadingExam => 'Đang tải...';

  @override
  String get takeExam => 'Vào thi';

  @override
  String get noExamsFoundTitle => 'Không tìm thấy đề thi phù hợp';

  @override
  String get noExamsFoundDesc =>
      'Hãy thử thay đổi từ khóa hoặc bộ lọc danh mục.';

  @override
  String get takingExamTitle => 'Làm bài thi';

  @override
  String get backButton => 'Quay lại';

  @override
  String get examNoQuestions => 'Không có câu hỏi nào trong đề thi này';

  @override
  String get submitExam => 'Nộp bài';

  @override
  String get submitExamNow => 'Nộp bài ngay';

  @override
  String get continueExam => 'Tiếp tục làm';

  @override
  String get previousQuestion => 'Câu trước';

  @override
  String get nextQuestion => 'Câu sau';

  @override
  String get questionList => 'Danh sách';

  @override
  String get questionListTitle => 'Danh sách câu hỏi';

  @override
  String get readingPassage => 'Đoạn văn đọc hiểu:';

  @override
  String questionProgress(int current, int total) {
    return 'Câu $current / $total';
  }

  @override
  String questionNumberPrefix(int number) {
    return 'Câu $number';
  }

  @override
  String get confirmSubmitExamTitle => 'Xác nhận nộp bài thi?';

  @override
  String confirmSubmitUnfinished(int count) {
    return 'Bạn còn $count câu chưa hoàn thành. Bạn có chắc chắn muốn nộp bài thi ngay bây giờ?';
  }

  @override
  String get confirmSubmitFinished =>
      'Bạn đã hoàn thành tất cả các câu hỏi. Nộp bài để chấm điểm?';

  @override
  String get confirmExitExamTitle => 'Rời khỏi bài thi?';

  @override
  String get confirmExitExamDesc =>
      'Nếu rời khỏi bây giờ, toàn bộ câu trả lời hiện tại sẽ không được lưu lại.';

  @override
  String get stayInExam => 'Ở lại làm bài';

  @override
  String get exitExam => 'Rời khỏi';

  @override
  String get examResultTitle => 'Kết quả bài thi';

  @override
  String get examResultNotFound => 'Không tìm thấy kết quả làm bài';

  @override
  String get backToCatalog => 'Về danh mục';

  @override
  String get examPassed => 'ĐẠT';

  @override
  String get examFailed => 'CHƯA ĐẠT';

  @override
  String examScorePoints(int score) {
    return '$score Điểm';
  }

  @override
  String get correctCountStat => 'Số câu đúng';

  @override
  String get durationStat => 'Thời gian';

  @override
  String get passingScoreStat => 'Điểm chuẩn';

  @override
  String get retakeExam => 'Làm lại đề';

  @override
  String get questionDetails => 'Chi tiết câu hỏi & đáp án';

  @override
  String get correctBadge => 'Đúng';

  @override
  String get wrongBadge => 'Sai';

  @override
  String explanationPrefix(String exp) {
    return 'Giải thích: $exp';
  }

  @override
  String examPrefixLabel(String examId) {
    return 'Đề: $examId';
  }

  @override
  String selectedAnswerPrefix(String answer) {
    return 'Đã chọn: $answer';
  }

  @override
  String get reviewMistakeButton => 'Ôn lại';

  @override
  String get masteredMistakeButton => 'Thành thạo';

  @override
  String get noWrongQuestionsTitle => 'Không có câu sai nào!';

  @override
  String get noWrongQuestionsDesc =>
      'Tuyệt vời! Bạn chưa có câu hỏi nào bị sai hoặc tất cả đã thành thạo.';

  @override
  String get ankiWebLegacy => 'AnkiWeb (Cũ)';

  @override
  String get unansweredPlaceholder => '(Bỏ trống)';

  @override
  String get examCategoryJlpt => 'Kỳ thi Năng lực Nhật ngữ (JLPT)';

  @override
  String get examCategoryToeic => 'Chứng chỉ TOEIC Quốc tế';

  @override
  String get examCategoryThptqg => 'Thi tốt nghiệp THPT Quốc Gia';

  @override
  String get examCategoryGrammarTest => 'Kiểm tra Ngữ pháp Tổng hợp';

  @override
  String get examCategoryCustom => 'Đề thi tùy chỉnh';

  @override
  String get wrongStatusNew => 'Mới sai';

  @override
  String get wrongStatusReviewing => 'Đang ôn lại';

  @override
  String get wrongStatusMastered => 'Đã thành thạo';

  @override
  String get grammarDifficultyRecognition => 'Nhận biết';

  @override
  String get grammarDifficultyAnalysis => 'Phân tích & Bẫy';

  @override
  String get grammarDifficultyProduction => 'Vận dụng thực hành';

  @override
  String get grammarCatTenses => 'Thì & Khía Cạnh';

  @override
  String get grammarCatVoice => 'Câu Bị Động';

  @override
  String get grammarCatModals => 'Động Từ Khuyết Thiếu';

  @override
  String get grammarCatConditionals => 'Câu Điều Kiện';

  @override
  String get grammarCatSubjunctive => 'Thể Giả Định';

  @override
  String get grammarCatClauses => 'Mệnh Đề Quan Hệ';

  @override
  String get grammarCatInversion => 'Đảo Ngữ';

  @override
  String get grammarCatVerbForms => 'Dạng Động Từ';

  @override
  String get grammarCatConjunctions => 'Liên Từ';

  @override
  String get grammarCatSubjectVerbAgreement => 'Hòa Hợp Chủ Vị';

  @override
  String get grammarCatComparisons => 'Cấu Trúc So Sánh';

  @override
  String get grammarCatArticles => 'Mạo Từ';

  @override
  String get grammarCatDeterminers => 'Từ Hạn Định';

  @override
  String get grammarCatPronouns => 'Đại Từ';

  @override
  String get grammarCatPrepositions => 'Giới Từ';

  @override
  String get grammarCatAdjectivesAdverbs => 'Tính Từ & Trạng Từ';

  @override
  String get grammarCatNounClauses => 'Mệnh Đề Danh Từ';

  @override
  String get grammarCatSentenceStructure => 'Cấu Trúc Câu';

  @override
  String get grammarCatCausativeVerbs => 'Thể Sai Khiến';

  @override
  String get grammarCatPhrasalVerbs => 'Cụm Động Từ';

  @override
  String get grammarCatQuestions => 'Câu Hỏi & Đuôi';

  @override
  String get grammarCatEmphasis => 'Cấu Trúc Nhấn Mạnh';

  @override
  String get grammarCatParallelStructure => 'Cấu Trúc Song Song';

  @override
  String get grammarCatParticiples => 'Phân Từ & Mệnh Đề Rút Gọn';

  @override
  String get grammarCatWordFormation => 'Cấu Tạo Từ';

  @override
  String get grammarCatCollocations => 'Kết Hợp Từ';

  @override
  String get grammarCatCapstone => 'Tổng Ôn Toàn Diện';

  @override
  String get examNotFound => 'Đề thi không tồn tại hoặc đã bị xóa.';

  @override
  String examLoadFailed(String error) {
    return 'Lỗi tải đề thi: $error';
  }

  @override
  String examSubmitFailed(String error) {
    return 'Lỗi nộp bài: $error';
  }

  @override
  String examDownloadFailed(String error) {
    return 'Tải đề thi thất bại: $error';
  }

  @override
  String wrongStatusUpdateFailed(String error) {
    return 'Cập nhật trạng thái thất bại: $error';
  }

  @override
  String get learningTools => 'Công cụ học tập';

  @override
  String get refreshTooltip => 'Làm mới';

  @override
  String get bookmarkQuestion => 'Lưu';

  @override
  String get bookmarkedQuestion => 'Đã lưu';

  @override
  String get networkUnavailable => 'Không có kết nối mạng';

  @override
  String get authEmailPlaceholder => 'user@example.com';

  @override
  String get authPasswordDots => '••••••••';

  @override
  String get authUserAlreadyExists => 'Tài khoản đã tồn tại';

  @override
  String get authEmailNotConfirmed => 'Email chưa được xác nhận';

  @override
  String get updateCheckFailed => 'Không thể kiểm tra bản cập nhật';

  @override
  String get updateInstallFailed => 'Không thể tải gói cài đặt';

  @override
  String get importApkgInvalidFormat => 'Định dạng tệp APKG không hợp lệ';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get continueWithApple => 'Tiếp tục với Apple';

  @override
  String get orContinueWithEmail => 'Hoặc tiếp tục với email';

  @override
  String get authOAuthFailed =>
      'Đăng nhập bằng mạng xã hội thất bại hoặc đã bị huỷ.';

  @override
  String get selectiveSyncTitle => 'Đồng bộ chọn lọc bộ thẻ';

  @override
  String get selectiveSyncSubtitle =>
      'Chọn bộ thẻ được đồng bộ lên đám mây để tiết kiệm dung lượng';

  @override
  String get deckExcludedFromSync => 'Chỉ lưu cục bộ';

  @override
  String get deckSyncActive => 'Đã bật đồng bộ';

  @override
  String get cloudBackupTitle => 'Sao lưu & Snapshot Đám Mây';

  @override
  String get cloudBackupSubtitle =>
      'Tạo hoặc khôi phục bản sao lưu .flanki toàn diện';

  @override
  String get createBackupNow => 'Sao lưu ngay';

  @override
  String get backupCreating => 'Đang tạo bản sao lưu...';

  @override
  String get backupUploading => 'Đang tải bản sao lưu lên đám mây...';

  @override
  String get backupRestoring => 'Đang khôi phục bản sao lưu...';

  @override
  String get backupExporting => 'Đang xuất bản sao lưu...';

  @override
  String get backupSuccess => 'Tạo bản sao lưu thành công!';

  @override
  String backupFailed(String error) {
    return 'Sao lưu thất bại: $error';
  }

  @override
  String get restoreBackup => 'Khôi phục';

  @override
  String get restoreConfirmTitle => 'Khôi phục bản sao lưu?';

  @override
  String get restoreConfirmMessage =>
      'Hành động này sẽ hợp nhất hoặc khôi phục thẻ, bộ thẻ và dữ liệu đa phương tiện từ bản sao lưu này.';

  @override
  String get restoreSuccess => 'Khôi phục thành công!';

  @override
  String restoreFailed(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String get noBackupsFound => 'Chưa có bản sao lưu đám mây nào.';

  @override
  String get exportLocalBackup => 'Xuất tệp .flanki';

  @override
  String get importLocalBackup => 'Nhập tệp .flanki';

  @override
  String get storageStatsTitle => 'Thống kê dung lượng';

  @override
  String get databaseStorage => 'Bản ghi cơ sở dữ liệu';

  @override
  String get mediaStorage => 'Tệp âm thanh & hình ảnh';

  @override
  String get backupStorage => 'Bản sao lưu đám mây';

  @override
  String get localStorageUsed => 'Dung lượng cục bộ đã dùng';

  @override
  String get manageDeckSync => 'Tùy chọn đồng bộ bộ thẻ';

  @override
  String get syncDiagnosticsTitle => 'Chẩn đoán & Đo lường đồng bộ';

  @override
  String get syncDiagnosticsSubtitle =>
      'Chỉ số sức khỏe, ngắt mạch (Circuit Breaker) và dữ liệu truyền tải';

  @override
  String get syncSuccessRate => 'Tỷ lệ thành công';

  @override
  String get syncAvgLatency => 'Độ trễ trung bình';

  @override
  String get syncBandwidthTransferred => 'Dữ liệu đã truyền';

  @override
  String get syncBandwidthSaved => 'Băng thông tiết kiệm';

  @override
  String get circuitBreakerStatus => 'Trạng thái ngắt mạch';

  @override
  String get circuitBreakerClosed => 'Bình thường (Closed)';

  @override
  String get circuitBreakerOpen => 'Tạm ngắt (Open)';

  @override
  String get circuitBreakerHalfOpen => 'Đang thăm dò (Half-Open)';

  @override
  String get circuitBreakerReset => 'Đặt lại ngắt mạch';

  @override
  String get circuitBreakerResetSuccess =>
      'Đã đặt lại ngắt mạch về trạng thái bình thường.';

  @override
  String get clearTelemetryLogs => 'Xóa nhật ký';

  @override
  String get syncHistoryTitle => 'Nhật ký các phiên đồng bộ gần nhất';

  @override
  String get noSyncHistory => 'Chưa có phiên đồng bộ nào được ghi nhận.';

  @override
  String get syncDiagnosticsButton => 'Chẩn đoán';
}
