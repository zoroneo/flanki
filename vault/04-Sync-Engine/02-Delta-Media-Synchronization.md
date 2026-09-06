---
title: Đồng Bộ Delta USN & Media SHA-1
created: 2026-09-06
tags:
  - sync
  - delta
  - usn
  - media
---

# 🔄 Đồng Bộ Delta USN & Media SHA-1

## 1. Cơ Chế USN (Update Sequence Number)
Để tránh phải tải lại toàn bộ database hàng trăm Megabytes mỗi lần học, Anki sử dụng số tuần tự **USN**:
* Mỗi bản ghi (Card, Note, Deck, Revlog) đều có một trường số nguyên `usn`.
* Thao tác tại client khi chưa sync: `usn = -1`.
* Khi đồng bộ:
  1. Client gửi `max_usn` của lần sync trước lên server.
  2. Server truy vấn tất cả bản ghi có `usn > max_usn` và trả về client.
  3. Client gửi tất cả bản ghi có `usn = -1` lên server.
  4. Server gán số USN mới cho các bản ghi này và phản hồi về client cập nhật lại.

---

## 2. Đồng Bộ Tệp Tin Âm Thanh / Hình Ảnh (Media Sync)
* **Media Manifest**: Cả client và server đều duy trì một danh sách ánh xạ `(filename -> sha1_hash)`.
* **So khớp Hash**: Khi sync media:
  * Client gửi danh sách mã hash các file media địa phương.
  * Server tính toán `Diff = (Server_Files - Client_Files)` và `Upload_Diff = (Client_Files - Server_Files)`.
  * Chỉ những file âm thanh/ảnh thực sự thiếu mới được truyền tải dưới dạng các chunk nén `.zip`.
