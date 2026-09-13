---
title: Đồng Bộ Delta USN & Media SHA-1
created: 2026-09-06
tags:
  - sync
  - delta
  - usn
  - media
---

# 🔄 Đồng Bộ Delta USN & Media Sync (/msync/)

## 1. Cơ Chế USN (Update Sequence Number)
Để theo dõi và đồng bộ các thay đổi cục bộ giữa các phiên:
* Mỗi bản ghi trong SQLite (`cards`, `notes`, `revlog`, `col`) đều chứa trường số nguyên `usn`:
  * Khi bản ghi được tạo mới hoặc chỉnh sửa cục bộ tại client: gán `usn = -1` (`AppConfig.ankiSyncUsnModified`).
  * Khi xuất database để upload (`exportToAnki2Db`): gán thẻ và log với `usn = -1`, tăng `col.usn = col.usn + 1` và cập nhật mốc thời gian `mod = now`.
* **Phát hiện thay đổi cục bộ**: `DatabaseService.instance.hasLocalChangesSince(lastSyncTime)` quét các thẻ và `review_logs` có mốc thời gian `lastStudied` / `createdAt` / `reviewTime` sau mốc `lastSyncTime`.

---

## 2. Đồng Bộ Tệp Tin Đa Phương Tiện (Media Sync via `/msync/`)
Flanki triển khai giao thức AnkiWeb Media Sync Protocol v2 (`AnkiWebMediaSyncService`):

1. **Khởi tạo phiên (`/msync/begin`)**:
   * Client gửi `hostKey` và `clientVersion`.
   * Server trả về `serverUsn` hiện tại và session key `sk`.
2. **Lấy danh sách thay đổi (`/msync/mediaChanges`)**:
   * Client gửi `lastUsn` của lần sync trước.
   * Server phản hồi danh sách delta: `[[filename, usn, sha1], ...]`.
   * Client lọc các file có mã `sha1` hợp lệ và chưa tồn tại trong bộ nhớ (`MediaStorageService.instance.mediaFileExists(filename)`).
3. **Tải theo khối Zip (`/msync/downloadFiles`)**:
   * Tải tuần tự theo từng batch tối đa **25 tệp** (`maxMediaFilesInZip = 25`).
   * Server đóng gói các file thành một tệp nén `.zip` có chứa tệp đặc biệt `_meta`.
   * Tệp `_meta` chứa JSON ánh xạ: `{ "0": "image1.png", "1": "audio.mp3" }`.
   * Client giải nén và lưu trữ trực tiếp vào thư mục lưu trữ media của thiết bị (`saveMediaFileSync`).

---

## 3. Kiến Trúc Phát Âm Thanh Đơn Phiên (`CardAudioService`)
* **Vấn đề trước đây**: Việc tạo mới instance `AudioPlayer` trên mỗi nút bấm hoặc chuyển thẻ dẫn đến cạn kiệt native buffer của hệ điều hành (Android `MediaPlayer: error (-19, 0)` hoặc `E/AudioTrack: AudioTrack cannot be created`).
* **Giải pháp Singleton**:
  * Tái sử dụng một instance `AudioPlayer` duy nhất qua `CardAudioService.instance`.
  * Quản lý trạng thái phát toàn cục qua `ValueNotifier<String?> playingFilenameNotifier`.
  * Thiết lập cấu hình hệ thống: `stayAwake: true`, `contentType: AndroidContentType.speech`, `audioFocus: AndroidAudioFocus.gainTransientMayDuck`.
  * Tự động dừng phiên trước trước khi nạp tệp mới.

---

## 4. Phân Giải Tệp Đa Phương Tiện Đa Nền Tảng (`MediaStorageService`)
* **Hỗ trợ định dạng & định danh linh hoạt**:
  1. Loại bỏ dấu ngoặc kép hoặc đơn bao quanh tên tệp (`"audio.mp3"` -> `audio.mp3`).
  2. Giải mã URL-encoded (ví dụ: `sound%2001.mp3` -> `sound 01.mp3`).
  3. **Hỗ trợ Case-Insensitive trên Linux/Android ext4/f2fs**: Khi không tìm thấy tên chính xác, tự động quét thư mục và so khớp không phân biệt hoa thường (`targetLower == entryLower`).
  4. **Chống lỗi tệp rỗng (0-byte file)**: Tự động bỏ qua các tệp 0-byte bị lỗi ghi mạng và trả về badge phương tiện thiếu để UI hiển thị trạng thái an toàn.

