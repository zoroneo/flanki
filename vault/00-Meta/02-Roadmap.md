---
title: Lộ Trình Phát Triển Dự Án Flanki
created: 2026-09-06
tags:
  - meta
  - roadmap
  - milestones
---

# 🗺️ Lộ Trình Phát Triển (Roadmap)

```mermaid
gantt
    title Kế Hoạch Triển Khai Flanki
    dateFormat  YYYY-MM-DD
    section Phase 1: Foundation & Design
    Khởi tạo Flutter 3.47.2 & FVM            :done, p1_1, 2026-09-06, 1d
    Design System (shadcn_flutter Zinc Tokens):done, p1_2, 2026-09-06, 1d
    Localization Đầy Đủ (EN & VI)             :done, p1_3, 2026-09-06, 1d
    section Phase 2: Domain, Storage & Import
    Lưu trữ SQLite & Optimistic Caching      :done, p2_1, 2026-09-06, 1d
    Giải mã .apkg & AnkiTemplateEngine       :done, p2_2, 2026-09-06, 1d
    RichCardContent (HTML, Cloze, Audio)     :done, p2_3, 2026-09-06, 1d
    Thuật toán FSRS v4.5 Scheduler (Dart)    :done, p2_4, 2026-09-06, 1d
    section Phase 3: Study Experience & Management
    UI Decks (Cây phả hệ "::" & Speed Dial)  :done, p3_1, 2026-09-06, 1d
    Card Browser (Tìm kiếm, Lọc, Xóa, Undo)  :done, p3_2, 2026-09-06, 1d
    Study Session (Scratchpad & Action Sheet):done, p3_3, 2026-09-06, 1d
    section Phase 4: AnkiWeb Sync
    AnkiWeb Auth (Multipart form)            :done, p4_1, 2026-09-06, 1d
    AnkiWeb Sync Protocol (Meta & Download)  :active, p4_2, 2026-09-06, 2d
    section Phase 5: Multi-platform Release
    Tối ưu hóa iOS & Android                 :p5_1, 2026-09-08, 3d
    Đóng gói macOS & Windows Desktop         :p5_2, 2026-09-11, 3d
    section Phase 6: Academic Grammar Engine
    Data Pipeline & Drift Schema             :done, p6_1, 2026-09-09, 1d
    Two-Tier FSRS & Ghost Review System      :done, p6_2, 2026-09-09, 1d
    UI Practice (Choice, Error ID, Cloze)    :done, p6_3, 2026-09-09, 1d
    section Phase 7: Codebase Standardization & Safety
    Anti-Hardcode & 100% L10n Coverage       :done, p7_1, 2026-09-11, 1d
    Enum Safety (Platform, Updater, Tray)    :done, p7_2, 2026-09-11, 1d
    Fix Cram Bug & Centralize AppConfig      :done, p7_3, 2026-09-11, 1d
    section Phase 8: State Modernization & Optimization
    Freezed Immutable State Models           :done, p8_1, 2026-09-11, 1d
    Fine-Grained Consumer Scope Isolation    :done, p8_2, 2026-09-11, 1d
    Riverpod Annotation & Code Generation    :done, p8_3, 2026-09-11, 1d
    section Phase 9: Feature-First Architecture Migration
    Boundary Setup & ARCHITECTURE.md         :done, p9_1, 2026-09-12, 1d
    Pilot Slices (Stats & Grammar)           :done, p9_2, 2026-09-12, 1d
    Core Domain Slices (Decks, Study, Browser):done, p9_3, 2026-09-12, 1d
    Support Slices (Sync, Settings)          :done, p9_4, 2026-09-12, 1d
    Core & Clean Old Folders (120/120 Tests) :done, p9_5, 2026-09-12, 1d
    section Phase 10: Responsive Polish, Overflow Immunity & Media Engine
    AppTokens & Guardrail (check_dimensions) :done, p10_1, 2026-09-13, 1d
    Zero Overflow Matrix (6 Viewports/Scales):done, p10_2, 2026-09-13, 1d
    CardAudioService & Case-Insensitive Ext4 :done, p10_3, 2026-09-13, 1d
    Background Desktop Downloader (Dio)      :done, p10_4, 2026-09-13, 1d
    100% L10n Coverage & 154/154 Tests Pass  :done, p10_5, 2026-09-13, 1d
    section Phase 11: Build Isolation, Input Ergonomics & Inset Resilience (v1.1.5)
    Phân tách Build Mode & Dữ liệu 5 Nền tảng :done, p11_1, 2026-09-14, 1d
    Draggable Quick Focus Tag & Input UX     :done, p11_2, 2026-09-15, 1d
    Zero-Distortion Viewport & Bottom Inset Fix :done, p11_3, 2026-09-15, 1d
    154/154 Tests PASS (100% Suite Stability):done, p11_4, 2026-09-16, 1d
    section Phase 12: Standardized Exam, Navigation Parity & Widget Modularization
    Tích hợp Exam Navigation (5 Tabs & Shell):done, p12_1, 2026-09-16, 1d
    Anti-Hardcode 6 Phân Hệ & Clean DB       :done, p12_2, 2026-09-16, 1d
    Tách Mock Exam sang JSON Asset Ngoài     :done, p12_3, 2026-09-16, 1d
    Tối Ưu Widget (~300 lines) & Scope Isolation:done, p12_4, 2026-09-16, 1d
    208/208 Tests PASS & 0 Analyze Issues    :done, p12_5, 2026-09-16, 1d
```

### Chi tiết các cột mốc:
1. **Milestone 1 — Foundation & Tokens**: Xây dựng nền tảng Flutter Clean Architecture với Riverpod, `shadcn_flutter`, bộ biểu tượng Lucide và hệ thống bản địa hóa (English + Tiếng Việt).
2. **Milestone 2 — Core Domain & Pure Dart Engine**: Triển khai `DatabaseService` với bộ đệm in-memory phản ứng nhanh, bộ giải nén `.apkg` với `AnkiTemplateEngine`, render HTML/LaTeX/Audio với `RichCardContent` và thuật toán FSRS v4.5 chuẩn xác.
3. **Milestone 3 — Study Experience Mochi/RemNote**: Trải nghiệm ôn thẻ tương tác mượt mà với Scratchpad vẽ nháp, Card Action Sheet (Gắn cờ, Tạm dừng, Đặt lại), phân cấp bộ thẻ `::`, trình duyệt thẻ với chức năng Xóa thẻ & Hoàn tác (Undo).
4. **Milestone 4 — AnkiWeb Synchronization**: Đăng nhập AnkiWeb qua giao thức mạng `multipart/form-data`, đồng bộ danh sách thẻ và trạng thái ôn tập.
5. **Milestone 5 — Multi-platform Polish**: Hoàn thiện đóng gói và phát hành ứng dụng trên iOS, Android, macOS và Windows.
6. **Milestone 6 — Academic Grammar Engine**: Hệ thống 36 chuyên đề C1/C2 (540 bài tập chuẩn hóa), thuật toán FSRS hai tầng (Unit Mastery + Item Spacing), cơ chế Ghost Review triệt tiêu điểm yếu và tương tác tìm lỗi sai (`error_id`) trực tiếp trên văn bản.
7. **Milestone 7 — Codebase Standardization & Hardcode Elimination**: Triệt tiêu toàn bộ magic strings, magic numbers; chuẩn hóa enum type-safe (`AppPlatform`, `UpdateErrorType`, `DesktopTrayAction`); tập trung hóa `AppConfig.getL10n()` và `supportedLocales`; sửa lỗi nhận diện bộ thẻ Cày đề (Cram deck) và parser tag đa ngôn ngữ; đạt 100% test pass (117/117).
8. **Milestone 8 — State Modernization & Render Optimization**: Chuyển đổi 100% state models sang `@freezed` (7 classes) với deep equality; thu hẹp scope watch Riverpod với `.select()` và bọc `Consumer` / `ConsumerWidget` độc lập tại lá cây (Settings cards, Decks stats/badges, Scaffolds); di chuyển sang `riverpod_annotation: ^4.0.7` và `riverpod_generator: ^4.0.9` sinh mã tự động cho toàn bộ providers; tối ưu hóa hiệu năng render 60-120 FPS.
9. **Milestone 9 — Feature-First Architecture Migration**: Tái cấu trúc toàn diện từ Layer-First sang Feature-First (`features/{stats, grammar, decks, study, browser, editor, sync, settings}/`). Di chuyển hạ tầng dùng chung vào `core/` (`anki/`, `database/`, `fsrs/`, `localization/`, `theme/`, `widgets/`), router về `lib/router/app_router.dart`. Thiết lập quy chuẩn ranh giới trong `ARCHITECTURE.md`, xóa bỏ hoàn toàn `lib/ui/`, `core/storage/`, `core/importer/`, `core/states/`, `core/notifiers/`, bảo đảm 120/120 tests pass.
10. **Milestone 10 — Responsive Polish, Overflow Immunity, Media Engine & Dio In-App Downloader**:
    - Thiết lập hệ thống `AppTokens` chuẩn mực (`AppSpacing`, `AppRadius`, `AppIconSize`, `AppEdgeInsets`, `AppGaps`, `AppAnimationDurations`).
    - Xây dựng công cụ kiểm tra tự động `tool/check_dimensions.dart` chặn đứng số ma thuật (magic numbers) trong toàn bộ code UI.
    - Bảo đảm miễn nhiễm tràn màn hình (Zero Overflow Guarantee) qua ma trận kiểm thử 6 khung nhìn (Mobile 320x568, A11y Scale 1.5x, Tablet 768x1024, Desktop 1280x800).
    - Quản lý âm thanh đơn phiên `CardAudioService` chống tràn bộ nhớ đệm native Android MediaPlayer; phân giải file media đa nền tảng `MediaStorageService` (URL decoding, loại bỏ quotes, tìm kiếm case-insensitive trên Android ext4, xử lý file rỗng 0-byte).
    - Cập nhật desktop in-app trực tiếp qua `Dio` chạy nền (background download toast, tiến độ thời gian thực, tự động khởi động lại và cài đặt).
    - Bản địa hóa 100% ARB song ngữ Anh - Việt, đạt mốc **154 / 154 tests PASS**.
11. **Milestone 11 — Build Mode Isolation, Input Ergonomics & Bottom Inset Resilience (v1.1.5)**:
    - **Phân tách môi trường Build & Cô lập dữ liệu (5 Nền tảng)**: Áp dụng định danh riêng (`.debug`, `.profile`) và nhãn ứng dụng (`[DEBUG] Flanki`, `[PROFILE] Flanki`, `Flanki`) trên Android, iOS, macOS, Linux, Windows. Phân tách database `flanki_debug.sqlite` / `flanki.sqlite` và thư mục media `flanki_media_debug` / `flanki_media`, bảo vệ triệt để collection thật của người dùng khi dev/test.
    - **Draggable Quick Focus Tag & Input Ergonomics**: Nút nổi tương tác (`DraggableQuickFocusTag`) cho thẻ flashcard có ô nhập `{{type:...}}` trên mobile. Tích hợp cơ chế vật lý hút viền thông minh (edge-snapping physics dựa trên vận tốc kéo `VelocityTracker` > 400 hoặc điểm giữa `midX`), phản hồi rung xúc giác `HapticFeedback.lightImpact()`, tự động cuộn đến ô nhập và tự động focus trên desktop.
    - **Zero-Distortion Viewport & Bottom Inset Fix**: Cấu hình `resizeToAvoidBottomInset: false` trên toàn bộ Scaffolds (`AdaptiveScaffold`, `MobileScaffold`, `DecksScreen`, `BrowserMobileLayout`) kết hợp bù trừ khoảng cách bàn phím ảo bằng `SizedBox(height: ... + keyboardBottom)`, triệt tiêu hiện tượng méo layout hoặc giật khung hình khi bàn phím xuất hiện.
    - Toàn bộ test suite duy trì độ ổn định tuyệt đối: **154 / 154 tests PASS**.
12. **Milestone 12 — Standardized Exam Module, Navigation Parity, Zero-Hardcode & Widget Modularization**:
    - **Hệ Thống Điều Hướng Đa Nền Tảng (5 Tabs & Shell)**: Mở rộng `appRouterProvider` với `StatefulShellBranch` thứ 4 (`/exams`). Bổ sung `DesktopSidebar` (`Ctrl+4`), `TabletNavRail` (`Ctrl+4`), và `MobileBottomNavBar` với kỹ thuật bọc `Expanded` và co lề chữ chống tràn tuyệt đối trên màn hình 320px hẹp. Các màn hình làm bài (`ExamTakingScreen`) và kết quả (`ExamResultScreen`) được bọc `parentNavigatorKey: rootNavigatorKey` hiển thị toàn màn hình (Fullscreen).
    - **Triệt Tiêu Hoàn Toàn Mã Cứng (Zero-Hardcode & Clean DB)**: Bổ sung 65+ keys bản địa hóa cho phân hệ Exam, chuẩn hóa enum models (`GrammarDifficulty`, `GrammarCategory`, `ExamCategory`, `WrongQuestionStatus`), tập trung mã lỗi notifier (`getLocalizedError(l10n)`), làm sạch database (loại bỏ chuỗi hardcode `(Bỏ trống)` thành chuỗi rỗng `""` và map qua `l10n.unansweredPlaceholder`).
    - **Tách Dữ Liệu Mock Exam sang JSON Asset Ngoài**: Trích xuất toàn bộ dữ liệu mock exam sang `assets/data/exams/jlpt_n3_mock_01.json`, nạp qua `rootBundle` kèm fallback đọc file vật lý trực tiếp cho headless unit tests.
    - **Tối Ưu Hóa Widget (~300 Dòng) & Cô Lập Scope Rebuild**: Rà soát toàn bộ cây thư mục `lib/`, tái cấu trúc 14 file vượt ngưỡng xuống chuẩn ~300 dòng. Tách riêng `ExamTimerBadge` (lắng nghe `remainingSeconds`) giúp loại bỏ hoàn toàn việc re-render 60 lần/phút của toàn bộ màn hình phòng thi; sử dụng fine-grained `.select(...)` trên toàn bộ consumers.
    - **Kiểm Định Tuyệt Đối**: Đạt **208 / 208 tests PASS** (70 widget tests + 138 unit tests), `fvm flutter analyze` 0 warnings/errors/lints.

