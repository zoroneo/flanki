---
title: Đặc Tả Định Dạng Đóng Gói .apkg
created: 2026-09-06
tags:
  - domain
  - anki
  - apkg
  - file-format
---

# 📦 Đặc Tả Định Dạng Đóng Gói .apkg (Anki Package)

File `.apkg` là tiêu chuẩn đóng gói và phân phối bài học trong hệ sinh thái Anki.

## 1. Cấu Trúc File .apkg Bên Dưới
Thực chất, file `.apkg` là một file nén **ZIP** tiêu chuẩn chứa các thành phần sau:

```
my_deck.apkg (ZIP archive)
├── collection.anki2 (hoặc collection.anki21) -> File cơ sở dữ liệu SQLite
├── media -> File văn bản JSON chứa từ điển ánh xạ file âm thanh/hình ảnh
├── 0 -> File nhị phân của media đầu tiên (ví dụ: phát âm audio.mp3)
├── 1 -> File nhị phân của media thứ hai (ví dụ: hình ảnh minh hoạ.jpg)
└── ...
```

---

## 2. File `media` (Ánh Xạ Tên File)
Bên trong file zip, các file media không lưu theo tên gốc mà được đánh số (`0`, `1`, `2`, ...). File `media` là một chuỗi JSON thuần:
```json
{
  "0": "toeic_001_Q.mp3",
  "1": "illustration_familiar.jpg",
  "2": "pronounce_tool.mp3"
}
```

---

## 3. Quy Trình Import File .apkg Trong Flanki
1. **Giải nén bộ đệm**: Đọc file zip trong bộ nhớ hoặc trích xuất vào thư mục tạm `scratch/`.
2. **Đọc SQLite Collection**: Mở file `collection.anki2` bằng SQLite / `rslib`.
3. **Đổi tên Media**: Duyệt từ điển `media`, đổi tên các file `0`, `1` thành tên file gốc và di chuyển vào thư mục `collection.media` của app.
4. **Hợp nhất Deck**: Đưa các note, card và lịch sử ôn tập vào cơ sở dữ liệu chính của người dùng mà không làm ghi đè lịch sử cũ.
