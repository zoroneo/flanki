---
title: Công Nghệ & Môi Trường Phát Triển Flanki
created: 2026-09-06
tags:
  - meta
  - tech-stack
  - tooling
---

# 🛠️ Công Nghệ & Môi Trường Phát Triển Flanki

## 1. Công nghệ Frontend & Core Engine (Flutter & Dart)
* **Flutter SDK**: `3.47.2 (channel stable)` quản lý chặt chẽ qua **FVM** (`.fvmrc`).
* **Dart SDK**: `^3.13.2` (Dart 3.5+ runtime).
* **Design System**: **`shadcn_flutter`** (v0.0.54+) & **`lucide_icons_flutter`** (v3.1.18):
  - Bảng màu Zinc Dark / Light với typography hiện đại.
  - Component primitives: `SurfaceCard`, `Button`, `Badge`, `ActionSheet`, `Modal`, `Dialog`, `DropdownMenu`.
  - Hỗ trợ đa ngôn ngữ hoàn chỉnh: English (`app_en.arb`) và Tiếng Việt (`app_vi.arb`, `shadcn_localizations_vi.dart`).
* **State Management & Immutability**:
  - **`flutter_riverpod`** & **`hooks_riverpod`** (v3.4.3).
  - **`riverpod_annotation`** (v4.0.7) & **`riverpod_generator`** (v4.0.9): Code generation cho class-based và functional notifiers, type-safe providers, override clean cho testing.
  - **`freezed`** (v3.2.5) & **`freezed_annotation`** (v3.1.0): 100% immutable state modeling với deep equality cho collections, copyWith, và pattern matching.
* **Local Storage & Database**:
  - **`sqlite3`** (v3.5.2) + **`drift`** (v2.24.2): Tương tác trực tiếp với file `collection.anki2` của Anki.
  - **Optimistic In-Memory Caching** trong `DatabaseService` để đảm bảo độ trễ UI bằng 0.
* **Scheduling Engine**: Thuật toán **FSRS v4.5** triển khai hoàn toàn bằng Pure Dart (`fsrs` package + `FsrsEngineService`).
* **APKG & Template Engine**:
  - **`archive`** (v4.2.0): Giải nén file `.apkg` và xử lý media map.
  - **`AnkiTemplateEngine`**: Bóc tách thẻ Cloze `{{c1::...}}`, cú pháp Mustache `{{Field}}`, `{{#Field}}`, `{{^Field}}`.
* **Rich Content & Media**:
  - **`flutter_widget_from_html_core`**: Render HTML/CSS của thẻ flashcard, hỗ trợ công thức toán học LaTeX.
  - **`audioplayers`** (v6.1.0): Phát âm thanh từ vựng đính kèm `[sound:...]`.
* **Sync Engine**:
  - **`AnkiWebSyncService`** & **`AnkiWebAuthService`**: Giao thức mạng `multipart/form-data` đồng bộ hóa 2 chiều với máy chủ AnkiWeb.
  - **`flutter_secure_storage`**: Lưu trữ an toàn session key (token hkey).

---

## 2. Kiến trúc Core Engine: Pure Dart vs Rust FFI
* **Giai đoạn Hiện Tại (Pure Dart Engine)**:
  - Tối ưu hóa tính di động (Zero native C-compiler requirement, dễ dàng chạy trên iOS, Android, macOS, Web, Windows, Linux).
  - Tốc độ khởi tạo tức thì, không phát sinh chi phí marshalling bộ nhớ FFI.
* **Giai đoạn Mở Rộng (Rust `rslib` Bridge)**:
  - Chuẩn bị sẵn module Rust FFI cho các tính năng kiểm tra toàn vẹn bộ thẻ cấp thấp và giải mã thuật toán Anki 2.1 cũ khi cần.

---

## 3. Quản lý phiên bản & Công cụ (Tooling)
* **FVM (Flutter Version Management)**: Khóa phiên bản Flutter cục bộ, tránh lệch phiên bản giữa máy dev và CI/CD.
* **Git**: Kiểm soát phiên bản với `.gitignore` tối ưu hóa cho Flutter + SQLite temporary files (`.db-shm`, `.db-wal`) và SwiftPM.
