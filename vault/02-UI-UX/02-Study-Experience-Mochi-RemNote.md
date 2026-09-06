---
title: Thiết Kế Trải Nghiệm Học Tập Tối Ưu (Mochi & RemNote)
created: 2026-09-06
tags:
  - ux
  - mochi
  - remnote
  - learning-science
---

# 🧠 Thiết Kế Trải Nghiệm Học Tập Tối Ưu (Mochi & RemNote)

## 1. Trạng Thái Tập Trung Tuyệt Đối (Distraction-Free Mode)
Khi bước vào phiên học (Study Session):
* Toàn bộ thanh menu, sidebar và các con số thống kê gây phân tâm tự động ẩn đi.
* Màn hình chỉ còn duy nhất chiếc Flashcard ở giữa cùng thanh tiến độ (Progress Bar) siêu mỏng ở đỉnh màn hình.

---

## 2. Tương Tác Học Thẻ (Interaction Dynamics)
* **Desktop**:
  * Nhấn `Space` $\to$ Lật thẻ xem đáp án kèm hiệu ứng chuyển động 3D xoay trục Y mềm mại (180ms).
  * Nhấn `1`, `2`, `3`, `4` $\to$ Gửi đánh giá ngay lập tức, tự động trượt sang thẻ tiếp theo không có độ trễ.
  * Nhấn `R` $\to$ Phát lại audio phát âm (nếu có).
* **Mobile**:
  * Chạm 1 chạm $\to$ Lật thẻ.
  * Vuốt sang trái $\to$ Đánh giá `Again` (Quên).
  * Vuốt sang phải $\to$ Đánh giá `Good` (Thuộc).
  * Phản hồi rung nhẹ haptic feedback (iOS Taptic Engine / Android Haptics).

---

## 3. Dopamine Loops & Thói Quen (Habit Retention)
* **Heatmap lịch sử học**: Lấy cảm hứng từ GitHub Contribution Graph, hiển thị mức độ chăm chỉ từng ngày trong năm.
* **Streak Counter**: Đếm chuỗi ngày học liên tục kèm huy hiệu chúc mừng khi đạt các mốc 7, 30, 100 ngày.
