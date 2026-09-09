---
title: Giao Thức Mạng AnkiWeb Sync Protocol
created: 2026-09-06
tags:
  - sync
  - ankiweb
  - networking
  - protocol
---

# 🌐 Giao Thức Mạng AnkiWeb Sync Protocol

Flanki giao tiếp trực tiếp với máy chủ AnkiWeb (`https://sync.ankiweb.net`) thông qua giao thức HTTP Multipart POST mã hoá TLS/HTTPS, chia thành 3 nhóm endpoint chuyên biệt:

## 1. Các Nhóm Endpoint Cốt Lõi

### A. Xác Thực (Authentication)
* `POST /sync/hostKey`: Xác thực email/password người dùng (`c=0, data={"u": email, "p": password}`) $\to$ cấp session key (`hostKey`) để thực hiện các yêu cầu đồng bộ tiếp theo mà không cần lưu password gốc trên thiết bị.

### B. Đồng Bộ Bộ Sưu Tập (Collection Sync)
* `POST /sync/meta`: Gửi phiên bản giao thức (`v=10`) và định danh ứng dụng (`cv=anki,2.1.57,...`) $\to$ nhận mốc thời gian cập nhật server (`mod` / `scm`) và số thứ tự đồng bộ `usn`.
* `POST /sync/download`: Tải nguyên vẹn gói binary SQLite (`collection.anki2`) từ máy chủ về client để giải nén và nạp thẻ (`ApkgImporterService`).
* `POST /sync/upload`: Đẩy gói binary SQLite từ client lên máy chủ (`DatabaseService.exportToAnki2Db`).
* *(Lộ trình Rust Core Granular Delta Sync)*: `POST /sync/start`, `POST /sync/applyChanges`, `POST /sync/applyChunk`, `POST /sync/finish`.

### C. Đồng Bộ Tệp Phương Tiện (Media Sync - `/msync/`)
* `POST /msync/begin`: Khởi tạo phiên media sync với `hostKey` $\to$ nhận `serverUsn` và session key tạm thời (`sk`).
* `POST /msync/mediaChanges`: Gửi `lastUsn` $\to$ nhận danh sách các tệp media thêm mới/chỉnh sửa dạng `[[filename, usn, sha1], ...]`.
* `POST /msync/downloadFiles`: Tải media theo từng khối (batch 25 tệp) dưới dạng tệp Zip kèm tệp chỉ mục JSON `_meta`.
* `POST /msync/uploadFiles`: Đẩy media từ client lên cloud.

---

## 2. Token Xác Thực & Bảo Mật
* Mọi giao tiếp đều đi qua kênh bảo mật TLS/HTTPS (`sync.ankiweb.net`).
* Session token (`hostKey`), tài khoản và mốc thời gian `lastSyncedAt` được lưu trữ mã hóa qua `flutter_secure_storage`:
  * **iOS / macOS**: Apple Keychain Services.
  * **Android**: KeyStore & EncryptedSharedPreferences (AES-256).
  * **Windows**: DPAPI (Data Protection API) / Credential Locker.
  * **Linux**: Secret Service API / libsecret.
