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
Bổ sung 21 translation keys mới cho cả Tiếng Anh (pp_en.arb) và Tiếng Việt (pp_vi.arb):
- Các thông báo lỗi tên deck (errorInvalidDeckName).
- Thông báo rỗng khi cày đề (cramEmptyNotice, cramEmptyHint).
- Dialog cấu hình học tập (studyOptionsTitle, maxReviewsPerDayLabel, maxNewCardsPerDayLabel).
- Trạng thái kiểm tra cập nhật (checkingForUpdates, 
oUpdatesAvailable, updateAvailableTitle).

---

## 4. Kiểm Thử & Đảm Bảo Chất Lượng (Verification)

Toàn bộ test suite được cập nhật và chạy xác thực trên môi trường FVM Flutter:

`ash
fvm flutter test
`

**Kết quả**:
- **117 / 117 tests PASS** (100% Xanh).
- Thời gian thực thi: ~15-20s.
- Không phát sinh hồi quy (zero regression) trên:
  - FSRS Algorithm & Deck Scheduling.
  - Academic Grammar Two-Tier Engine & Ghost Review.
  - AnkiWeb Sync Engine.
  - Multi-platform Desktop & Window Manager.

---

## 5. Quy Chuẩn Duy Trì Codebase (Maintenance Standards)

Từ cột mốc này, toàn bộ mã nguồn đóng góp mới vào Flanki bắt buộc tuân thủ:
1. **Không viết chuỗi UI trực tiếp trong Widget**: Mọi text hiển thị cho người dùng phải định nghĩa trong pp_en.arb và pp_vi.arb.
2. **Không dùng raw string cho các tập giá trị cố định**: Bắt buộc tạo enum trong thư mục lib/core/enums/.
3. **Mọi hằng số thời gian/kích thước hệ thống**: Khai báo tập trung tại lib/core/config/app_config.dart.
4. **Truy cập Localization**: Sử dụng AppConfig.getL10n(context) để đảm bảo luôn có fallback an toàn.
