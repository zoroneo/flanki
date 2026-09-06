---
title: Công Nghệ & Môi Trường Phát Triển Flanki
created: 2026-09-06
tags:
  - meta
  - tech-stack
  - tooling
---

# 🛠️ Công Nghệ & Môi Trường Phát Triển Flanki

## 1. Công nghệ Frontend (Flutter & Dart)
* **Flutter SDK**: `3.47.2 (channel stable)` quản lý chặt chẽ qua **FVM** (`.fvmrc`).
* **Dart SDK**: `3.13.2`.
* **Design System**: **`shadcn_flutter`** (v0.0.54+) — Cung cấp hệ thống UI Tokens hiện đại:
  - Bảng màu Zinc Dark / Light.
  - Component primitives: `Card`, `PrimaryButton`, `GhostButton`, `PrimaryBadge`, `DestructiveBadge`, `SurfaceCard`.
* **State Management**: **`flutter_riverpod`** (v3.4.3) kết hợp kiến trúc Clean Architecture.
* **RPC Serialization**: **`package:protobuf`** (v6.0.0) — Giải mã bản tin nhị phân từ Rust backend.
* **Native Interop**: **`dart:ffi`** kết hợp **`package:ffi`** (v2.2.0).

---

## 2. Công nghệ Backend & Core Engine (Rust)
* **Rust Toolchain**: `stable` (Rust 1.80+ / 2021 edition).
* **Anki Core Engine**: Crate **`rslib`** trích xuất từ repository chính thức `ankitects/anki`.
  - Quản lý cơ sở dữ liệu SQLite (`collection.anki2`).
  - Thuật toán lên lịch **FSRS v5** (Free Spaced Repetition Scheduler) và SM-2 legacy.
  - Bộ máy đồng bộ AnkiWeb Sync Engine.
* **C ABI Bridge (`anki-bridge-rs`)**: Thư viện động C (`cdylib` / `staticlib`) xuất khẩu 4 hàm FFI nguyên thuỷ.

---

## 3. Quản lý phiên bản & Công cụ (Tooling)
* **FVM (Flutter Version Management)**: Khóa phiên bản Flutter cục bộ, tránh lệch phiên bản giữa máy dev và CI/CD.
* **Git**: Kiểm soát phiên bản với `.gitignore` tối ưu hóa cho Flutter + Rust build outputs.
