---
title: Quy Chuẩn Phân Cấp Thư Mục Test & Tiêu Chuẩn Kiểm Thử
created: 2026-09-11
tags:
  - testing
  - hierarchy
  - standards
  - flutter
---

# 🧪 Quy Chuẩn Phân Cấp Thư Mục Test & Tiêu Chuẩn Kiểm Thử

## 1. Tổng Quan & Mục Tiêu

Dự án Flanki áp dụng cấu trúc kiểm thử phân cấp nhiều tầng (Hierarchical Testing Pyramid), loại bỏ hoàn toàn mô hình thư mục test phẳng (*flat tests*). Mục tiêu:
1. **Dễ định vị**: Cấu trúc test ánh xạ tương ứng với các tầng kiến trúc trong `lib/`.
2. **Tách biệt ranh giới**: Tách biệt rõ ràng giữa Unit Tests chạy thuần túy logic (không phụ thuộc Flutter UI pipeline), Widget Tests (kiểm tra tương tác UI, render, responsive), và Integration Tests (kiểm thử end-to-end user flows).
3. **Thực thi chọn lọc**: Có thể chạy nhanh từng nhóm bài kiểm tra theo danh mục mà không phải nạp toàn bộ suite nặng.

---

## 2. Bản Đồ Phân Cấp Thư Mục `test/`

```
test/
├── unit/                          # Kiểm thử đơn vị logic thuần túy (Fast execution)
│   ├── core/                      # Constants, models, localization, bridge
│   │   ├── app_config_and_bridge_test.dart
│   │   ├── deck_grouping_test.dart
│   │   └── l10n_test.dart
│   ├── notifiers/                 # State management notifiers & evaluation logic
│   │   ├── deck_creation_test.dart
│   │   └── grammar_session_notifier_test.dart
│   ├── services/                  # Algorithms, engines, system & platform services
│   │   ├── desktop_update_service_test.dart
│   │   ├── fsrs_and_apkg_test.dart
│   │   ├── grammar_service_test.dart
│   │   ├── notification_service_test.dart
│   │   └── study_settings_and_sm2_test.dart
│   ├── storage/                   # SQLite, Drift repositories, media storage
│   │   ├── card_deletion_and_settings_test.dart
│   │   ├── database_service_test.dart
│   │   └── grammar_repository_test.dart
│   └── sync/                      # AnkiWeb sync protocol, delta & media syncing
│       └── anki_web_media_sync_test.dart
│
├── widget/                        # Kiểm thử giao diện widget & components
│   ├── components/                # Isolated widgets, dialogs, rich text, toolbar
│   │   ├── anki_web_sync_conflict_test.dart
│   │   ├── deck_toolbar_height_test.dart
│   │   ├── grammar_ui_test.dart
│   │   └── rich_card_content_test.dart
│   └── screens/                   # Màn hình hoàn chỉnh, responsive layout & hotkeys
│       ├── desktop_adaptive_layout_test.dart
│       ├── desktop_shortcuts_and_browser_test.dart
│       ├── flanki_smoke_test.dart
│       ├── grammar_navigation_test.dart
│       └── note_editor_screen_test.dart
│
└── integration/                   # Kiểm thử tích hợp đa tầng, end-to-end flows
    └── grammar_practice_flow_test.dart
```

---

## 3. Quy Định Phân Loại Bài Test Mới

Mọi file test tạo mới trong dự án Flanki **bắt buộc** phải tuân theo vị trí tương ứng:

| Loại Kiểm Thử | Vị Trí Thư Mục | Đối Tượng Kiểm Thử | Điều Kiện & Kỹ Thuật |
|---|---|---|---|
| **Core Logic** | `test/unit/core/` | Helpers, Config, Models, Parsing | Không phụ thuộc Flutter UI bindings |
| **State Notifier** | `test/unit/notifiers/` | Riverpod Notifiers, State reducers | Sử dụng `ProviderContainer`, test state transitions |
| **Engine / Service** | `test/unit/services/` | FSRS, SM-2, Importer, Updaters | Xử lý thuật toán, mocks I/O |
| **Data Storage** | `test/unit/storage/` | SQLite (`DatabaseService`), Drift (`AppDatabase`) | Sử dụng in-memory database hoặc isolated temp files |
| **Network & Sync** | `test/unit/sync/` | AnkiWeb protocol, USN sync | Sử dụng `MockClient`, test binary payload parsing |
| **Component Widget** | `test/widget/components/` | Dialogs, Cards, Custom Buttons | Dùng `testWidgets`, wrap bằng `ShadcnApp` |
| **Screen & Layout** | `test/widget/screens/` | Toàn màn hình, hotkey, responsive breakpoints | Kiểm tra kích thước cửa sổ mobile/tablet/desktop |
| **Integration Flow** | `test/integration/` | Luồng người dùng từ UI xuống Database | Kiểm tra đa bước (VD: Học bài -> Nộp bài -> FSRS lưu DB -> Summary) |

---

## 4. Lệnh Thực Thi Tiêu Chuẩn

```powershell
# Chạy toàn bộ test suite (117/117 tests)
fvm flutter test

# Chạy riêng nhóm Unit Tests (cực nhanh)
fvm flutter test test/unit/

# Chạy riêng Widget Tests
fvm flutter test test/widget/

# Chạy riêng Integration Tests
fvm flutter test test/integration/
```
