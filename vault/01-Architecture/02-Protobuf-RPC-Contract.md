---
title: Hợp Đồng Bản Tin Protobuf RPC (Protobuf Contract)
created: 2026-09-06
tags:
  - architecture
  - protobuf
  - rpc
  - schema
---

# 📜 Hợp Đồng Bản Tin Protobuf RPC

Toàn bộ API giữa Flutter UI và Anki Rust Core được định nghĩa thông qua các file Google Protocol Buffers (`.proto`) nằm trong `ankitects/anki/proto`.

## 1. Bảng Mã Dịch Vụ Cốt Lõi (Service & Method IDs)

| Service ID | Tên Service | Phương thức tiêu biểu | Chức năng chính |
| :--- | :--- | :--- | :--- |
| **0** | `CollectionService` | `OpenCollection`, `CloseCollection` | Mở/đóng file `collection.anki2`, kiểm tra tính toàn vẹn database. |
| **1** | `DecksService` | `GetDeckTree`, `NewDeck`, `RemoveDeck` | Lấy cây phân cấp thư mục Deck, thêm/xoá/đổi tên bộ thẻ. |
| **2** | `CardService` | `GetCard`, `AnswerCard`, `BuryCards` | Đánh giá thẻ (Again/Hard/Good/Easy), tính toán khoảng cách ngày tiếp theo theo FSRS. |
| **3** | `SyncService` | `SyncStatus`, `FullSync`, `SyncCollection`, `SyncMedia` | Đăng nhập AnkiWeb, đồng bộ Delta USN, đồng bộ âm thanh/hình ảnh. |
| **4** | `StatsService` | `GetReviewSummary`, `GetGraph` | Thống kê số thẻ đến hạn (Due), tỷ lệ ghi nhớ (Retention), lịch sử ôn tập. |

---

## 2. Ví dụ luồng `AnswerCard` (Đánh giá thẻ)

```protobuf
// anki_proto/card.proto
message AnswerCardRequest {
  int64 card_id = 1;
  int32 rating = 2; // 1: Again, 2: Hard, 3: Good, 4: Easy
}

message AnswerCardResponse {
  int64 next_due_timestamp = 1;
  int32 new_interval_days = 2;
  double stability = 3;
  double difficulty = 4;
}
```

```dart
// Dart invocation
final request = AnswerCardRequest()
  ..cardId = 1682390123
  ..rating = 3; // Good

final responseBytes = ankiBridge.runMethod(
  Services.cardService,
  Methods.answerCard,
  request.writeToBuffer(),
);

final response = AnswerCardResponse.fromBuffer(responseBytes!);
print('Next due: in ${response.newIntervalDays} days');
```
