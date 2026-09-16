---
title: Chuẩn Hóa Codebase, Anti-Hardcode & Type-Safe Architecture
created: 2026-09-11
tags:
  - architecture
  - refactor
  - l10n
  - enums
  - safety
  - tests
---

# 🛡️ Chuẩn Hóa Codebase, Anti-Hardcode & Type-Safe Architecture

Tài liệu này ghi lại kiến trúc, chuẩn mực kỹ thuật và giải pháp triệt tiêu hoàn toàn mã cứng (hardcode), chuỗi thô (magic strings), số ma thuật (magic numbers) và lỗi bản địa hóa đa ngôn ngữ trên toàn bộ dự án **Flanki**.

---

## 1. Vấn Đề Kỹ Thuật Trước Refactor (The Problem)

Trước đợt chuẩn hóa toàn diện (2026-09-11), codebase Flanki gặp phải các rủi ro kỹ thuật tiềm ẩn:
1. **Lỗi logic khi đổi ngôn ngữ (Multi-language Regressions)**:
   - Bộ thẻ Cày đề (Cram / Custom Study) được định danh bằng tiền tố giao diện 'Cram: '. Khi người dùng chuyển app sang Tiếng Việt ('Cày đề: '), hàm startsWith('Cram: ') trả về alse, làm mất icon Zap màu Amber và sai lệch luồng hoàn trả thẻ về deck gốc.
2. **Parser chuỗi rủi ro (Fragile String Splitting)**:
   - Phân giải tag từ ID hàng đợi tùy biến (custom_study_tag_<tagName>) bằng id.split('_')[1]. Khi tên tag chứa dấu gạch dưới (ví dụ unit_1, phrasal_verb), parser cắt sai chuỗi hoặc gây RangeError.
3. **Hardcode chuỗi UI & Thông điệp lỗi**:
   - Các dialog cài đặt bộ thẻ, thông báo cập nhật, nút xác nhận rải rác văn bản tiếng Anh hardcode, thiếu key trong ARB localization.
4. **Chuỗi thô thay cho Enum (Type Insecurity)**:
   - Các định danh nền tảng OS ('windows', 'macos', 'android'), mã lỗi updater ('unsupported_platform'), hành động khay hệ thống (tray action) sử dụng chuỗi tự do, dễ gây lỗi chính tả âm thầm (typo bug).
5. **Magic Numbers phân tán**:
   - Timeout mạng (10s), thời lượng toast (3s), bước học lại mặc định (10m) bị rải rác trực tiếp trong code thay vì tập trung hóa cấu hình.

---

## 2. Kiến Trúc Giải Pháp & Mô Hình Chuẩn Hóa

`mermaid
graph TD
    subgraph Config Layer [AppConfig Centralization]
        AC[AppConfig]
        AC --> Loc[defaultLocale & supportedLocales]
        AC --> Fallback[getL10n: Fallback Safe AppLocalizations]
        AC --> Timeouts[updateCheckTimeout: 10s]
        AC --> Durations[toastLongDuration: 3s]
    end

    subgraph Type Safety [Strict Enum Models]
        AP[AppPlatform Enum]
        UE[UpdateErrorType Enum]
        DTA[DesktopTrayAction Enum]
        TM[ThemeMode.values.byName]
    end

    subgraph Core Domain Safety [Robust Parsers & Multi-lang]
        IC[deck.isCram Property Safe]
        CSQ[Substring Prefix Tag Parser]
    end

    subgraph Localization [100% ARB Coverage]
        ARB_EN[app_en.arb]
        ARB_VI[app_vi.arb]
    end

    AC --> Localization
    Core Domain Safety --> Config Layer
    Type Safety --> AC
`

---

## 3. Các Trụ Cột Triển Khai Kỹ Thuật

### 3.1. Tập Trung Hóa Locale & Tránh Boilerplate (AppConfig)
Tập trung toàn bộ cấu hình ngôn ngữ, logic nhận diện locale hệ thống và hàm trợ giúp fallback an toàn tại lib/core/config/app_config.dart:

`dart
class AppConfig {
  static const Locale defaultLocale = Locale('en');
  static const List<Locale> supportedLocales = [Locale('en'), Locale('vi')];

  /// Lấy AppLocalizations an toàn, tự động fallback về AppLocalizationsEn
  /// nếu BuildContext chưa mount hoặc thiếu Provider scope (Headless/Tests)
  static AppLocalizations getL10n([BuildContext? context]) {
    if (context != null) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) return l10n;
    }
    return AppLocalizationsEn();
  }

  /// Phân giải an toàn mã ngôn ngữ hệ thống
  static String resolveSystemLocaleCode(String systemLocale) {
    final langCode = systemLocale.split('_').first.toLowerCase();
    return supportedLocales.any((l) => l.languageCode == langCode)
        ? langCode
        : defaultLocale.languageCode;
  }
}
`
**Lợi ích**: Triệt tiêu hoàn toàn 8 khối mã AppLocalizations.of(context) ?? AppLocalizationsEn() lặp lại rải rác trên toàn app.

---

### 3.2. Chuẩn Hóa Enum An Toàn Kiểu Dữ Liệu (Type Safety)
Thay thế toàn bộ chuỗi tự do bằng Enum có type checking lúc compile:

1. **AppPlatform** (lib/core/enums/app_platform.dart):
   - Thay thế các chuỗi 'windows', 'macos', 'linux', 'android', 'ios', 'web'.
   - Cung cấp getter tiện ích: isDesktop, isMobile, current.
2. **UpdateErrorType** (lib/core/enums/update_error_type.dart):
   - Định danh trạng thái kiểm tra bản cập nhật: unsupportedPlatform, 
etworkError, ateLimited, parseError, serverError, unknown.
3. **DesktopTrayAction** (lib/core/enums/desktop_tray_action.dart):
   - Quản lý sự kiện khay desktop: showApp, quickStudy, syncNow, checkUpdate, exitApp.
4. **ThemeMode Serialization**:
   - Sử dụng ThemeMode.values.byName(name) an toàn thay cho chuỗi switch-case lặp thủ công.

---

### 3.3. Sửa Lỗi Gốc Cram Deck & Parser Chuỗi An Toàn
1. **Định danh Cram Deck Đa Ngôn Ngữ**:
   - Thay thế kiểm tra cứng deck.name.startsWith('Cram: ') bằng thuộc tính domain deck.isCram.
   - Đảm bảo khi người dùng chuyển sang Tiếng Việt ('Cày đề: '), màu sắc icon Zap Amber và logic hoàn trả thẻ hoạt động chuẩn xác 100%.
2. **Parser Tag Hàng Đợi Tùy Biến**:
   - Chuyển đổi:
     `dart
     // CŨ (Lỗi khi tag có dấu _):
     final tag = id.split('_')[1];

     // MỚI (An toàn tuyệt đối):
     const prefix = 'custom_study_tag_';
     if (id.startsWith(prefix)) {
       final tag = id.substring(prefix.length);
       // Xử lý an toàn...
     }
     `

---

### 3.4. 100% Bản Địa Hóa (Localization Coverage)
Bổ sung 65+ translation keys mới cho cả Tiếng Anh (`app_en.arb`) và Tiếng Việt (`app_vi.arb`):
- Bản địa hóa 100% 4 màn hình thi: `ExamCatalogScreen`, `ExamTakingScreen`, `ExamResultScreen`, `WrongNotebookScreen`.
- Bản địa hóa các widget dùng chung: `DeckAppBar`, `AccountSyncCard`, `TabletNavRail`.
- Enum labels: `GrammarDifficulty` và `GrammarCategory` qua extension methods `getLocalizedLabel(l10n)` và `getLocalizedName(l10n)`; chuẩn hóa fallback tiếng Anh cho `ExamCategory` và `WrongQuestionStatus`.
- Bổ sung 5 mã lỗi và khóa thông báo lỗi đa ngôn ngữ: `examNotFound`, `examLoadFailed`, `examSubmitFailed`, `examDownloadFailed`, `wrongStatusUpdateFailed`.

---

### 3.5. Tách Dữ Liệu Mock Ra Asset JSON & Nạp Headless An Toàn
- **Vấn đề**: `ExamRepository.seedSampleExams()` từng chứa hơn 90 dòng code chứa chuỗi hardcode tiếng Nhật và tiếng Việt cho đề thi mẫu JLPT N3.
- **Giải pháp**:
  - Trích xuất toàn bộ sang file JSON chuẩn: [`assets/data/exams/jlpt_n3_mock_01.json`](file:///d:/Workspace/flanki/assets/data/exams/jlpt_n3_mock_01.json).
  - Tải động qua `rootBundle.loadString(...)` khi ứng dụng chạy thông thường.
  - Cơ chế **Headless Fallback**: Nếu `rootBundle` ném ngoại lệ (như khi chạy headless unit tests mà không gắn kết flutter test asset bundle), tự động fallback đọc file vật lý trực tiếp qua `dart:io File('assets/data/exams/...')`. Đảm bảo code sạch 100% chuỗi thô mà không làm gãy bất kỳ unit test nào.

---

### 3.6. Làm Sạch Database & Tập Trung Hóa Tham Số Hệ Thống
1. **Làm sạch Database Field**:
   - Thay thế `userAnswer ?? '(Bỏ trống)'` thành `userAnswer ?? ''` (chuỗi rỗng).
   - Tầng UI tự động ánh xạ chuỗi rỗng sang `l10n.unansweredPlaceholder` ("Chưa trả lời" / "Unanswered"). Database SQLite hoàn toàn trung lập với ngôn ngữ hiển thị.
2. **Tập trung hóa hằng số kết nối & đồng bộ**:
   - `SupabaseConfig`: Tập trung `defaultPushBatchLimit = 100`, `defaultPullBatchLimit = 500`, `mockUrl`, `mockAnonKey`, hỗ trợ `--dart-define=SUPABASE_MEDIA_BUCKET=...`.
   - `AppConfig`: Tập trung `defaultSyncPeriodicInterval`, `defaultSyncDebounceDuration`, `defaultMaxClockDriftMillis`, `GITHUB_REPO_OWNER`, `GITHUB_REPO_NAME`.
   - `AnkiWebConfig`: Tập trung `defaultSyncHost`, `defaultTimeout`, hỗ trợ `--dart-define=ANKIWEB_SYNC_HOST=...`.

---

## 4. Kiểm Thử & Đảm Bảo Chất Lượng (Verification)

Toàn bộ test suite và linting guardrail được chạy xác thực trên môi trường FVM Flutter:

```bash
# Kiểm tra kích thước ma thuật (AppTokens Guardrail)
fvm dart run tool/check_dimensions.dart

# Kiểm tra phân tích mã nguồn linter
fvm flutter analyze

# Chạy toàn bộ test suite (70 widget + 138 unit tests)
fvm flutter test test/unit/ test/widget/
```

**Kết quả**:
- **208 / 208 tests PASS** (100% Xanh).
- **Phân tích tĩnh**: `No issues found! (ran in 4.6s)`.
- Không phát sinh hồi quy (zero regression) trên:
  - FSRS Algorithm & Deck Scheduling.
  - Academic Grammar Two-Tier Engine & Ghost Review.
  - AnkiWeb Sync Engine, Delta Media Sync & Auth.
  - Supabase Sync Engine, HLC Clock Drift & Chaos Fault Hardening.
  - Exam Taking, Scoring, Auto-Submit, Question Palettes & Wrong Notebook.
  - Multi-platform Desktop Window Manager & In-app Updater.
  - Responsive Viewport & Scale Matrix (320px -> 1280px, A11y 1.5x) - Zero Overflow.

---

## 5. Quy Chuẩn Duy Trì Codebase (Maintenance Standards)

Từ cột mốc này, toàn bộ mã nguồn đóng góp mới vào Flanki bắt buộc tuân thủ:
1. **Không viết chuỗi UI trực tiếp trong Widget**: Mọi text hiển thị cho người dùng phải định nghĩa trong `app_en.arb` và `app_vi.arb`.
2. **Không dùng raw string cho các tập giá trị cố định**: Bắt buộc tạo enum trong thư mục `lib/core/enums/`.
3. **Mọi hằng số thời gian/kích thước hệ thống**: Khai báo tập trung tại `lib/core/config/app_config.dart`.
4. **Không dùng số ma thuật cho khoảng cách/kích thước UI (Magic Dimensions)**: Bắt buộc sử dụng `AppSpacing`, `AppRadius`, `AppIconSize`, `AppEdgeInsets`, `AppGaps` từ `lib/core/theme/app_tokens.dart`.
5. **Truy cập Localization**: Sử dụng `AppConfig.getL10n(context)` hoặc `context.l10n` để đảm bảo luôn có fallback an toàn.
6. **Kiểm tra tự động trước commit**: Chạy `fvm dart run tool/check_dimensions.dart && fvm flutter analyze && fvm flutter test`.
