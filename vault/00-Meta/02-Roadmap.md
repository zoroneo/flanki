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
    section Phase 1: Core Foundation
    Khởi tạo Flutter 3.47.2 & FVM            :done, p1_1, 2026-09-06, 1d
    Xây dựng Knowledge Vault & Docs          :active, p1_2, 2026-09-06, 1d
    Scaffold Rust Bridge (C ABI & FFI)       :active, p1_3, 2026-09-06, 2d
    section Phase 2: Domain & Import
    Giải mã định dạng .apkg (Zip & SQLite)   :p2_1, 2026-09-08, 3d
    Trình render thẻ Dual-Engine             :p2_2, 2026-09-11, 4d
    section Phase 3: Study Experience
    UI Học thẻ phong cách Mochi/RemNote     :p3_1, 2026-09-15, 4d
    Tích hợp FSRS v5 Scheduler               :p3_2, 2026-09-19, 3d
    section Phase 4: AnkiWeb Sync
    Kết nối giao thức AnkiWeb Sync          :p4_1, 2026-09-22, 5d
    Đồng bộ Media & Giải quyết xung đột      :p4_2, 2026-09-27, 4d
    section Phase 5: Multi-platform Release
    Tối ưu macOS & Windows Desktop           :p5_1, 2026-10-01, 3d
    Đóng gói Android & iOS App               :p5_2, 2026-10-04, 4d
```

### Chi tiết các cột mốc:
1. **Milestone 1 — Alpha Foundation**: Hoàn thiện cầu nối FFI Dart $\leftrightarrow$ Rust C ABI; nạp thành công database `collection.anki2` rỗng.
2. **Milestone 2 — Import .apkg & Study Engine**: Import trọn vẹn bộ thẻ 600 từ TOEIC (.apkg); phát được audio MP3 và hiển thị câu ví dụ ngữ cảnh; chấm điểm 4 nút (Again, Hard, Good, Easy).
3. **Milestone 3 — AnkiWeb Sync**: Đăng nhập tài khoản AnkiWeb; đẩy và kéo log review hai chiều trơn tru.
4. **Milestone 4 — Production Release**: Xuất bản binary macOS, Windows, Linux, file Android `.apk` và iOS build.
