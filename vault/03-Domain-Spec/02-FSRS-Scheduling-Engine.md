---
title: Thuật Toán Lặp Lại Ngắt Quãng FSRS
created: 2026-09-06
tags:
  - domain
  - srs
  - fsrs
  - algorithm
---

# 📈 Thuật Toán Lặp Lại Ngắt Quãng FSRS (Free Spaced Repetition Scheduler)

Flanki tích hợp trực tiếp **FSRS v5** từ Anki `rslib`, thay thế hoàn toàn thuật toán SM-2 cổ điển của những năm 1980.

## 1. Ba Trụ Cột Của FSRS
FSRS mô hình hoá bộ nhớ não bộ thông qua 3 biến số thực:
1. **Retrievability ($R$) — Khả năng nhớ lại**: Xác suất người học nhớ được thông tin tại thời điểm $t$. $R$ giảm dần theo hàm mũ theo thời gian trôi qua.
2. **Stability ($S$) — Độ ổn định**: Số ngày để khả năng nhớ lại $R$ giảm từ $100\%$ xuống $90\%$. Thẻ ôn tập càng nhiều lần thành công thì $S$ càng tăng vọt.
3. **Difficulty ($D$) — Độ khó của kiến thức**: Đo lường mức độ khó của thẻ trên thang đo từ $1$ đến $10$.

$$R(t) = \left(1 + \text{factor} \cdot \frac{t}{S}\right)^{\text{power}}$$

---

## 2. Vì Sao FSRS Vượt Trội Hơn SM-2 Cũ?
* **Cùng độ nhớ, giảm 30% số lượt ôn**: Tránh hiện tượng ôn tập dư thừa đối với các từ vựng dễ.
* **Cá nhân hóa theo người dùng**: FSRS học từ lịch sử ôn tập của chính bạn để tự tối ưu bộ 17 trọng số (Weights optimization).
* **Mục tiêu Retention tùy biến**: Bạn có thể đặt mục tiêu "Muốn nhớ 85% để học nhanh" hoặc "Muốn nhớ 95% trước khi đi thi" $\to$ Thuật toán tự co giãn lịch học phù hợp.
