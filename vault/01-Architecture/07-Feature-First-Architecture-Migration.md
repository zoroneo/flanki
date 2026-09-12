---
title: Kiến Trúc Feature-First & Chuẩn Hóa Ranh Giới Module
created: 2026-09-12
tags:
  - architecture
  - feature-first
  - clean-architecture
  - riverpod
  - modularity
---

# 🏛️ Kiến Trúc Feature-First & Chuẩn Hóa Ranh Giới Module

Tài liệu này đặc tả kiến trúc **Feature-First (Vertical Slice Architecture)** chính thức của **Flanki**, thay thế hoàn toàn cấu trúc phân tầng cũ (Layer-First: `ui/screens/`, `core/notifiers/`, `core/states/`, `core/storage/`).

---

## 1. Lý Do Chuyển Đổi (Why Feature-First?)

Khi ứng dụng Flanki mở rộng quy mô (bổ sung module ngữ pháp học thuật, đồng bộ AnkiWeb hai chiều, FSRS v4.5 engine, và hệ thống tự động cập nhật đa nền tảng), cấu trúc Layer-First bộc lộ nhiều điểm nghẽn:
1. **Shotgun Surgery**: Để thêm hoặc chỉnh sửa một tính năng (ví dụ `grammar`), kỹ sư phải phân tán mã nguồn qua hàng loạt thư mục cách xa nhau (`lib/ui/screens/grammar/`, `lib/core/notifiers/`, `lib/core/states/`, `lib/core/services/`).
2. **Khó kiểm soát ranh giới (Unclear Boundaries)**: Các màn hình UI dễ dàng gọi chéo controller của màn hình khác, tạo thành liên kết chặt chẽ (tight coupling) khó bảo trì và khó viết test cô lập.
3. **Mô hình chuẩn của hệ sinh thái Flutter quy mô lớn**: Các ứng dụng Flutter lớn trong thực tế (như Meteo, Superlist, Tide) đều áp dụng **Feature-First + Core Infrastructure** để đảm bảo khả năng mở rộng (scale) độc lập giữa các module.

---

## 2. Sơ Đồ Cây Thư Mục Mục Tiêu (Directory Blueprint)

Toàn bộ mã nguồn tại `lib/` tuân thủ nghiêm ngặt mô hình 4 trụ cột:

```text
lib/
├── core/                         # Hạ tầng dùng chung toàn ứng dụng (Horizontal Infrastructure)
│   ├── anki/                     # Bridge FFI native, AnkiTemplateEngine, ApkgImporterService
│   ├── config/                   # Hằng số toàn cục (AppConfig)
│   ├── database/                 # Drift SQLite (AppDatabase), DatabaseService, MediaStorageService
│   ├── extensions/               # ResponsiveSizing, BuildContext helpers
│   ├── fsrs/                     # Thuật toán FSRS v4.5 & SM-2 schedulers
│   ├── localization/             # LocaleNotifier, ShadcnLocalizationsVi
│   ├── models/                   # Thực thể domain cốt lõi (CardModel, DeckModel, CustomStudyMode)
│   ├── services/                 # DesktopWindowService (tray/window), NotificationService
│   ├── theme/                    # ThemeNotifier (Light/Dark/System)
│   └── widgets/                  # AdaptiveScaffold, MobileScaffold, AppLifecycleManager,
│                                 # RichCardContent, AdaptiveModal, FormFocusHelper,
│                                 # animations/, navigation/
│
├── features/                     # 8 Lát cắt nghiệp vụ độc lập (Vertical Slices)
│   ├── browser/                  # Trình duyệt & tìm kiếm thẻ (CardBrowserScreen, Notifier, State)
│   ├── decks/                    # Quản lý & thao tác bộ thẻ (DecksScreen, DeckNotifier, 11 sub-widgets)
│   ├── editor/                   # Trình soạn thảo thẻ ghi nhớ (NoteEditorScreen, 6 sub-widgets)
│   ├── grammar/                  # Hệ thống ngữ pháp C1/C2 (3 screens, 14 widgets, FSRS 2-tier)
│   ├── settings/                 # Cài đặt ứng dụng, tùy chọn học & cập nhật Desktop (UpdateService)
│   ├── stats/                    # Thống kê học tập, Heatmap & biểu đồ tiến độ (StatsScreen)
│   ├── study/                    # Phiên ôn tập thẻ (StudySessionScreen, Notifier, 8 sub-widgets)
│   └── sync/                     # Đồng bộ AnkiWeb & Xác thực đám mây (Auth & SyncFlowCoordinator)
│
├── l10n/                         # Bản dịch ARB (app_en.arb, app_vi.arb) & sinh mã l10n
├── router/                       # Định tuyến GoRouter khai báo tập trung (app_router.dart)
└── main.dart                     # Điểm khởi chạy ứng dụng (Bootstrap)
```

---

## 3. Cấu Trúc Nội Bộ Của Một Feature Slice

Mỗi thư mục trong `lib/features/<feature>/` có thể bao gồm tối đa 4 tầng con tùy thuộc vào độ phức tạp của nghiệp vụ:

```text
lib/features/<feature_name>/
├── data/                         # Dịch vụ mạng chuyên biệt, Repository, Evaluator (tùy chọn)
├── models/                       # Entity nội bộ và UI State Models (@freezed)
├── providers/                    # Riverpod Notifiers & Controllers (@riverpod code generation)
└── ui/                           # Màn hình chính (Screen)
    └── widgets/                  # Các widget con nội bộ chỉ phục vụ cho feature này
```

---

## 4. Ma Trận Phụ Thuộc & Ranh Giới Bất Khả Xâm Phạm (Dependency Rules)

| Tầng nguồn | ĐƯỢC PHÉP Import | CẤM TUYỆT ĐỐI Import |
| :--- | :--- | :--- |
| **`lib/core/**`** | External packages, Flutter SDK, nội bộ `core/**` | ❌ `features/**`, `router/**` |
| **`lib/features/<A>/**`** | `core/**`, nội bộ `features/<A>/**` | ❌ `features/<B>/ui/**`, `features/<B>/providers/**` |
| **`lib/router/**`** | `features/**/ui/**`, `core/**` | - |
| **`lib/main.dart`** | `core/**`, `router/**` | ❌ Trực tiếp import các màn hình UI con |

### 3 Nguyên Tắc Giao Tiếp Liên Feature (Cross-Feature Rules)
1. **Điều Hướng (Navigation)**: Tuyệt đối không import hoặc `Navigator.push` trực tiếp Widget của feature khác. Mọi điều hướng liên feature bắt buộc đi qua **`context.go(...)`** hoặc **`context.push(...)`** của GoRouter.
2. **Dữ Liệu Dùng Chung (Shared Data Entities)**: Nếu nhiều feature cùng thao tác trên một thực thể (ví dụ `CardModel`, `DeckModel`), thực thể đó thuộc về `lib/core/models/` hoặc dịch vụ `lib/core/database/DatabaseService`.
3. **Widget Đa Feature (Shared UI Components)**: Nếu một UI widget được sử dụng bởi từ 2 features trở lên (ví dụ `RichCardContent` dùng trong cả `study` và `grammar`), widget đó lập tức được nâng cấp lên `lib/core/widgets/`.

---

## 5. Lộ Trình 5 Bước Tái Cấu Trúc (Migration Milestones)

Dự án đã thực hiện quá trình tái cấu trúc theo nguyên tắc **Ponytail Lazy Senior Dev** (diff ngắn, zero mock slop, kiểm thử liên tục ở từng phase):

| Phase | Phạm Vi Chuyển Đổi | Git Commit | Kết Quả Kiểm Thử |
| :--- | :--- | :--- | :--- |
| **Phase 0** | Khởi tạo cấu trúc `lib/features/`, tài liệu ranh giới `ARCHITECTURE.md`, l10n gen | - | Baseline setup |
| **Phase 1** | Thí điểm 2 feature độc lập: `stats` và `grammar` (3 screens, 14 widgets, 5 test suites) | `4bd7338`<br>`4065e92` | 120/120 tests pass |
| **Phase 2** | Nhóm Core Domain: `decks`, `study`, `browser`, `editor` & tách `RichCardContent` sang `core/widgets/` | `a5fde56` | 120/120 tests pass |
| **Phase 3** | Nhóm Hạ tầng hỗ trợ: `sync` (AnkiWeb auth + sync) và `settings` (study settings + desktop update) | `6259bae` | 120/120 tests pass |
| **Phase 4** | Chuẩn hóa `core/` (`anki`, `database`, `localization`, `theme`, `widgets`), chuyển `router/`, xóa bỏ hoàn toàn `lib/ui/`, `core/storage/`, `core/importer/`, `core/notifiers/`, `core/states/` | `3cedfd5` | 120/120 tests pass, 0 lints |

---

## 6. Lợi Ích Sau Chuyển Đổi

1. **Tính Tự Trị Cao (High Autonomy)**: Khi phát triển hoặc sửa lỗi trong bất kỳ feature nào, nhà phát triển chỉ cần làm việc trọn vẹn trong một thư mục `lib/features/<name>/`.
2. **Kiến Trúc Bền Vững (Future-Proof)**: Dễ dàng thêm mới các tính năng lớn tiếp theo (ví dụ: AI Card Generator, Multiplayer Deck Sharing) mà không làm ảnh hưởng đến mã nguồn hiện tại.
3. **Zero Regression**: Toàn bộ 120 unit, widget và flow integration tests được bảo toàn 100% pass rate qua toàn bộ hành trình chuyển đổi.
