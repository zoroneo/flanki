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

---

## 4. Bảng Vẽ Nháp & Thao Tác Thẻ Nhanh (Scratchpad & Card Actions)
* **Bảng vẽ nháp (Scratchpad Overlay)**:
  - Cho phép người dùng viết/vẽ nháp câu trả lời, chữ Hán, công thức toán trực tiếp đè lên mặt trước của thẻ trước khi lật xem đáp án.
  - Công cụ tối giản: Nét bút (Pencil), Tẩy (Eraser), và Xóa sạch (Clear). Nét vẽ tự động xóa khi chuyển sang thẻ mới.
* **Bảng thao tác thẻ nhanh (Card Action Sheet)**:
  - Truy cập tức thì qua biểu tượng ba chấm (`...`) trên `StudyAppBar`.
  - Hỗ trợ gắn 7 màu cờ (Red, Orange, Green, Blue, Pink, Turquoise, Purple) theo chuẩn Anki.
  - Tạm dừng thẻ (`Suspend`) hoặc đặt lại tiến độ học (`Reset`) mà không cần rời khỏi màn hình ôn tập.

---

## 5. Trải Nghiệm Gõ Đáp Án & Nút Nổi Hút Viền (`DraggableQuickFocusTag`)
Khi ôn luyện các thẻ có trường gõ từ `{{type:Field}}`:
* **Desktop Auto-Focus**:
  - Tự động kích hoạt con trỏ chuột vào ô nhập đáp án ngay khi thẻ nạp xong (`focusNode.requestFocus()`), giúp người dùng gõ ngay lập tức mà không cần nhấp chuột.
* **Mobile Draggable Quick Focus Tag**:
  - Trên thiết bị di động, thẻ nổi `DraggableQuickFocusTag` hiển thị ở góc thẻ flashcard.
  - **Vật lý hút viền (Edge-Snapping Physics)**: Dựa trên vận tốc vuốt (`VelocityTracker` vượt quá $\pm 400\text{px/s}$) hoặc vị trí ngang so với điểm giữa (`midX`), thẻ tự động trượt êm ái về cạnh trái hoặc cạnh phải gần nhất.
  - Vị trí dọc được giới hạn trong biên an toàn (`clamp(edgeMargin, maxHeight - edgeMargin)`).
  - Khi chạm vào tag: Tự động kích hoạt bàn phím ảo, rung phản hồi xúc giác nhẹ (`HapticFeedback.lightImpact()`), và tự động cuộn khung nhìn (`scrollController.animateTo`) đưa ô nhập liệu vào tầm nhìn tối ưu của người học.

---

## 6. Miễn Nhiễm Biến Dạng Khung Nhìn (Viewport & Keyboard Inset Stability)
* Thiết lập `resizeToAvoidBottomInset: false` trên Scaffolds của phiên học.
* Khung thẻ (`CardFrontView`, `CardBackView`) sử dụng `CustomScrollView` kết hợp `SliverFillRemaining(hasScrollBody: false)`, giữ nguyên tỉ lệ kích thước thẻ và tỉ lệ thẩm mỹ Zinc Card, loại bỏ hoàn toàn hiện tượng méo form, co rút chữ đột ngột khi bàn phím ảo bật lên.
