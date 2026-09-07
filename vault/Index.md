---
title: Flanki Project Knowledge Vault (MOC)
created: 2026-09-06
tags:
  - moc
  - index
  - flanki
  - anki
  - flutter
  - rust
---

# ⚡ Flanki Knowledge Base & Technical Blueprint

Chào mừng đến với Knowledge Vault của dự án **Flanki** — Ứng dụng flashcard thế hệ mới kết hợp sức mạnh lõi thuật toán và đồng bộ của **Anki Rust Engine (`rslib`)** với giao diện hiện đại từ **`shadcn_flutter`** và trải nghiệm học tập đỉnh cao lấy cảm hứng từ **Mochi** và **RemNote**.

---

## 🗺️ Bản Đồ Tri Thức (Map of Content)

### 00. Tổng Quan & Định Hướng Dự Án (Meta)

- [[00-Meta/00-Overview|00. Tầm Nhìn Sản Phẩm & Định Vị (Overview)]]
- [[00-Meta/01-Tech-Stack|01. Công Nghệ & Môi Trường Phát Triển (Tech Stack)]]
- [[00-Meta/02-Roadmap|02. Lộ Trình Phát Triển & Cột Mốc (Roadmap)]]

### 01. Kiến Trúc Hệ Thống (Architecture)

- [[01-Architecture/01-Rust-FFI-Bridge|01. C ABI Bridge & Giao Tiếp Đa Nền Tảng (Rust FFI)]]
- [[01-Architecture/02-Protobuf-RPC-Contract|02. Hợp Đồng Bản Tin Protobuf RPC (Protobuf Contract)]]
- [[01-Architecture/03-Cross-Platform-Strategy|03. Chiến Lược Hỗ Trợ Đa Nền Tảng (Desktop & Mobile)]]
- [[01-Architecture/04-Pure-Dart-Engine-Architecture|04. Kiến Trúc Pure Dart Core Engine & Reactive Storage]]

### 02. Trải Nghiệm Người Dùng & Thiết Kế (UI / UX)

- [[02-UI-UX/01-Shadcn-Design-Tokens|01. Hệ Thống Design Tokens & shadcn_flutter]]
- [[02-UI-UX/02-Study-Experience-Mochi-RemNote|02. Thiết Kế Trải Nghiệm Học Tập Tối Ưu]]
- [[02-UI-UX/03-Dual-Card-Rendering|03. Cơ Chế Dual-Engine Render Thẻ (Native + WebKit)]]

### 03. Đặc Tả Nghiệp Vụ Anki (Domain Spec)

- [[03-Domain-Spec/01-APKG-Packaging-Spec|01. Đặc Tả Định Dạng Đóng Gói .apkg]]
- [[03-Domain-Spec/02-FSRS-Scheduling-Engine|02. Thuật Toán Lặp Lại Ngắt Quãng FSRS]]
- [[03-Domain-Spec/03-Anki-Collection-Schema|03. Cấu Trúc Cơ Sở Dữ Liệu SQLite collection.anki2]]

### 04. Động Cơ Đồng Bộ (Sync Engine)

- [[04-Sync-Engine/01-AnkiWeb-Sync-Protocol|01. Giao Thức Mạng AnkiWeb Sync Protocol]]
- [[04-Sync-Engine/02-Delta-Media-Synchronization|02. Đồng Bộ Delta USN & Media SHA-1]]
- [[04-Sync-Engine/03-Conflict-Resolution|03. Xử Lý Xung Đột Dữ Liệu & Hợp Nhất An Toàn]]

---

## 📌 Nguyên Tắc Kỹ Thuật Bất Biến (Guiding Principles)

1. **100% Anki Compatible**: Không bao giờ làm hỏng cấu trúc dữ liệu hoặc lịch ôn của người dùng Anki hiện hữu.
2. **Native Performance & Low Latency**: Khởi động app dưới 500ms, lật thẻ phản hồi dưới 16ms (60-120 FPS).
3. **No Ugly UI**: Áp dụng triệt để thẩm mỹ tối giản, sạch sẽ của `shadcn_flutter` với bảng màu Zinc.
4. **Offline First**: Mọi thao tác học, thêm từ, sửa thẻ đều vận hành trơn tru khi không có mạng; đồng bộ âm thầm khi có kết nối.
