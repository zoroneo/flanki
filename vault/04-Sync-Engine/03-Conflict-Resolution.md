---
title: Xử Lý Xung Đột Dữ Liệu & Hợp Nhất An Toàn
created: 2026-09-06
tags:
  - sync
  - conflict-resolution
  - safety
---

# 🛡️ Xử Lý Xung Đột Dữ Liệu & Hợp Nhất An Toàn (Safe Sync Merge)

## 1. Các Tình Huống Gây Xung Đột
* **Học offline đồng thời trên 2 máy**: Máy tính Mac học 50 thẻ, iPhone học 30 thẻ khi không có internet. Khi cả 2 máy cùng sync lên AnkiWeb, lịch sử có thể bị chênh lệch.
* **Thay đổi lược đồ thẻ (Note Type Schema change)**: Người dùng sửa thêm/xóa field từ vựng trên Desktop.

---

## 2. Chiến Lược Hợp Nhất (Merge Strategy)
Flanki kế thừa chiến lược **Non-destructive Safe Merge** của Anki Rust Core:
1. **Đối với bản ghi lịch sử học (`revlog`)**:
   * Áp dụng nguyên tắc **Append-only**. Bản ghi ôn tập từ cả 2 thiết bị đều được giữ lại nguyên vẹn và bổ sung vào bảng `revlog`, đảm bảo không mất công sức học của người dùng.
2. **Đối với trạng thái thẻ (`card`)**:
   * Nếu có xung đột về ngày đến hạn (Due), bản ghi có mốc thời gian cập nhật (`mod`) mới hơn (Last-Write-Wins) sẽ được ưu tiên, sau đó bộ máy FSRS tự động hiệu chỉnh lại độ ổn định ($S$).
3. **Khi có thay đổi Schema cấu trúc lớn (Full Sync)**:
   * Nếu cấu trúc dữ liệu bị phân kỳ sâu (Diverged), Flanki sẽ hiển thị giao diện đối chiếu trực quan (Visual Diff Dialog) bằng `shadcn_flutter` để người dùng chọn: Giữ bản trên máy (Upload) hay Lấy bản trên máy chủ (Download).
