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
