---
title: Tầm Nhìn Sản Phẩm & Định Vị Flanki
created: 2026-09-06
tags:
  - meta
  - product
  - vision
---

# 🚀 Tầm Nhìn & Định Vị Sản Phẩm Flanki

## 1. Nỗi đau của hệ sinh thái Anki hiện tại
Mặc dù Anki là "tiêu chuẩn vàng" trong giới học thuật, y khoa và học ngoại ngữ nhờ thuật toán lặp lại ngắt quãng (SRS/FSRS) và hệ thống lưu trữ bền vững:
* **Giao diện Desktop (Qt6)**: Cũ kỹ, phong cách phần mềm thập niên 2000, nhiều bảng thông báo modal chặn tương tác, cấu hình rườm rà.
* **Giao diện Mobile (iOS)**: AnkiMobile tính phí \$24.99 và đóng mã nguồn; người dùng không thể can thiệp hay đóng góp tính năng.
* **Trải nghiệm học (UX)**: Thiếu các tương tác mượt mà (smooth gestures, streak dopamine, micro-animations, context clozes) vốn có trên các ứng dụng thế hệ mới như Mochi hay RemNote.

---

## 2. Giải pháp Flanki
Flanki kết hợp những gì **tinh túy nhất của Anki** với chuẩn **UI/UX hiện đại nhất**:

| Tiêu chí | Anki Truyền Thống | Mochi / RemNote | Flanki |
| :--- | :--- | :--- | :--- |
| **Giao diện & Thẩm mỹ** | Qt6 / Cổ điển | Tối giản, hiện đại (Notion-like) | **shadcn_flutter (Zinc Theme, bóng đổ tinh tế)** |
| **Nền tảng mục tiêu** | Desktop + Android (iOS đóng) | Web + Mobile | **Desktop (macOS, Win, Linux) + Mobile (iOS, Android)** |
| **Động cơ đồng bộ** | AnkiWeb Protocol | Cloud riêng (có phí) | **AnkiWeb Sync Engine gốc của Anki (Rust `rslib`)** |
| **Khả năng nhập/xuất** | Chuẩn `.apkg` | Import hạn chế | **Tương thích 100% file `.apkg` và kho AnkiWeb** |
| **Mã nguồn** | Hybrid (Rust, Python, Svelte) | Đóng mã nguồn | **Mã nguồn mở 100% (Flutter + Rust)** |

---

## 3. Trải nghiệm học tập lấy cảm hứng từ Mochi & RemNote
1. **Mochi-inspired**:
   - Thẻ hiển thị dạng trang giấy nổi, phân cấp chữ rõ ràng.
   - Hỗ trợ Markdown tự nhiên, gõ tới đâu format tới đó.
   - Âm thanh phản hồi xúc giác nhẹ nhàng khi bấm nút đánh giá (Again, Hard, Good, Easy).
2. **RemNote-inspired**:
   - Khái niệm học theo ngữ cảnh (Contextual Flashcards).
   - Tối ưu hóa phím tắt số (`1`, `2`, `3`, `4`) và phím cách (`Space`) cho Desktop; thao tác vuốt thẻ hai chiều trực quan cho Mobile.
   - Thống kê Heatmap và chuỗi ngày học (Streak) tạo động lực học liên tục.
