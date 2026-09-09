---
title: Xử Lý Xung Đột Dữ Liệu & Hợp Nhất An Toàn
created: 2026-09-06
tags:
  - sync
  - conflict-resolution
  - safety
---

# 🛡️ Xử Lý Xung Đột Dữ Liệu & Hợp Nhất An Toàn (Safe Sync Merge)

## 1. Cơ Chế Phát Hiện Xung Đột (Conflict Detection)
Được điều phối tự động bởi `SyncFlowCoordinator` và `AnkiWebSyncService.checkSyncStatus`:
* Xung đột được xác định khi thỏa mãn đồng thời hai điều kiện:
  1. `serverMod.isAfter(lastSyncTime + 2s)`: Máy chủ AnkiWeb đã có thay đổi mới từ thiết bị khác (ví dụ: đã học trên Desktop).
  2. `DatabaseService.instance.hasLocalChangesSince(lastSyncTime) == true`: Thiết bị hiện tại cũng phát sinh lượt học hoặc chỉnh sửa cục bộ khi chưa sync.

---

## 2. Quy Trình Giải Quyết Hiện Hành: Hướng Dẫn Tương Tác (Interactive Conflict Dialog)
Trong kiến trúc **Pure Dart Core** hiện hành, Flanki giải quyết xung đột ở cấp độ Bộ sưu tập (Collection level) an toàn tuyệt đối, tránh hỏng SQLite:
* Tự động mở hộp thoại **`SyncConflictDialog`**:
  * **Trên Desktop ($\ge 600\text{px}$)**: Hiển thị dưới dạng Modal Dialog chuẩn `shadcn_flutter`.
  * **Trên Mobile ($< 600\text{px}$)**: Hiển thị dưới dạng Bottom Sheet trượt mượt mà.
* Cung cấp 3 lựa chọn minh bạch:
  1. **Tải lên Cloud (Upload - Giữ bản máy này)**: Gọi `exportToAnki2Db()` để đóng gói SQLite cục bộ và đẩy đè lên AnkiWeb Cloud qua `/sync/upload`.
  2. **Tải về Máy (Download - Lấy bản Cloud)**: Tải toàn bộ collection từ `/sync/download` về, nạp đè bộ thẻ và nhật ký học vào máy thông qua `ApkgImporterService`.
  3. **Hủy bỏ (Cancel)**: Giữ nguyên dữ liệu của cả 2 phía mà không thay đổi bất kỳ bản ghi nào.

---

## 3. Lộ Trình Nâng Cấp: Hợp Nhất Hạt Mịn 3 Chiều (Granular 3-Way Merge)
Khi tiến tới tích hợp cầu nối **Anki Rust Core (`rslib`)** (Phase 4):
1. **Lịch sử học tập (`revlog`)**:
   * Áp dụng nguyên tắc **Append-only**. Tất cả các dòng nhật ký ôn tập từ cả 2 thiết bị đều được giữ nguyên và gộp chung, không bao giờ mất công sức học của người dùng.
2. **Trạng thái thẻ (`card`)**:
   * Áp dụng nguyên tắc **Last-Write-Wins** dựa trên mốc thời gian `lastStudied` / `mod`.
   * Bộ máy **FSRS Scheduler** tự động tính toán lại độ bền ($S$) và độ khó ($D$) tổng hợp từ lịch sử ôn của cả 2 máy.
3. **Xóa thẻ (`graves`)**:
   * Áp dụng cơ chế **Tombstones** ghi nhận vào bảng `graves` để đồng bộ thao tác xóa thẻ mà không làm hồi sinh lại thẻ đã xóa ở máy kia.
