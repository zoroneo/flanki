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

AnkiWeb sử dụng giao thức HTTP REST + WebSocket tùy chỉnh với cơ chế mã hóa và nén Zstandard/Gzip.

## 1. Các Endpoint Cốt Lõi (Sync Endpoints)
* `POST /sync/hostKey`: Xác thực username/password người dùng $\to$ cấp session key (HostKey) để thực hiện các yêu cầu tiếp theo mà không cần lưu password gốc.
* `POST /sync/meta`: Trao đổi thông tin Schema Version, Client Version và giá trị USN hiện tại.
* `POST /sync/start`: Khởi tạo phiên đồng bộ, khóa database server tạm thời để tránh xung đột ghi đồng thời.
* `POST /sync/applyChanges`: Đẩy các dòng ghi nhận thay đổi (Notes, Cards, Revlog) lên server.
* `POST /sync/applyChunk`: Kéo các thay đổi từ server về và cập nhật vào SQLite địa phương.
* `POST /sync/finish`: Đóng phiên, mở khoá database.

---

## 2. Token Xác Thực & Bảo Mật
* Mọi giao tiếp đều đi qua TLS/HTTPS (`sync.ankiweb.net`).
* Session token được lưu trong Keychain an toàn của hệ điều hành (macOS Keychain, iOS Secure Enclave, Android Keystore) thông qua `flutter_secure_storage`.
