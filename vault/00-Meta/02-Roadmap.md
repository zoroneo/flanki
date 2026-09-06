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
```

### Chi tiết các cột mốc:
1. **Milestone 1 — Foundation & Tokens**: Xây dựng nền tảng Flutter Clean Architecture với Riverpod, `shadcn_flutter`, bộ biểu tượng Lucide và hệ thống bản địa hóa (English + Tiếng Việt).
2. **Milestone 2 — Core Domain & Pure Dart Engine**: Triển khai `DatabaseService` với bộ đệm in-memory phản ứng nhanh, bộ giải nén `.apkg` với `AnkiTemplateEngine`, render HTML/LaTeX/Audio với `RichCardContent` và thuật toán FSRS v4.5 chuẩn xác.
3. **Milestone 3 — Study Experience Mochi/RemNote**: Trải nghiệm ôn thẻ tương tác mượt mà với Scratchpad vẽ nháp, Card Action Sheet (Gắn cờ, Tạm dừng, Đặt lại), phân cấp bộ thẻ `::`, trình duyệt thẻ với chức năng Xóa thẻ & Hoàn tác (Undo).
4. **Milestone 4 — AnkiWeb Synchronization**: Đăng nhập AnkiWeb qua giao thức mạng `multipart/form-data`, đồng bộ danh sách thẻ và trạng thái ôn tập.
5. **Milestone 5 — Multi-platform Polish**: Hoàn thiện đóng gói và phát hành ứng dụng trên iOS, Android, macOS và Windows.
