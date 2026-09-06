---
title: Chiến Lược Đa Nền Tảng (Desktop & Mobile)
created: 2026-09-06
tags:
  - architecture
  - cross-platform
  - deployment
---

# 📱💻 Chiến Lược Hỗ Trợ Đa Nền Tảng (Desktop & Mobile)

Flanki hướng tới trải nghiệm đồng nhất trên cả 5 nền tảng: **macOS, Windows, Linux, Android, iOS**.

## 1. Đóng Gói Binary Rust Theo Nền Tảng

```
flanki/
├── macos/
│   └── Frameworks/libanki_bridge.dylib (Universal Binary x86_64 + arm64)
├── ios/
│   └── Frameworks/anki_bridge.xcframework (Device arm64 + Simulator)
├── android/
│   └── app/src/main/jniLibs/
│       ├── arm64-v8a/libanki_bridge.so
│       ├── armeabi-v7a/libanki_bridge.so
│       └── x86_64/libanki_bridge.so
├── windows/
│   └── anki_bridge.dll (x86_64)
└── linux/
    └── libanki_bridge.so (x86_64)
```

---

## 2. Thích Ứng Giao Diện Theo Kích Thước Màn Hình (Adaptive Layout)

| Thành phần | Desktop (Màn hình $\ge 900\text{px}$) | Mobile (Màn hình $< 900\text{px}$) |
| :--- | :--- | :--- |
| **Điều hướng** | Sidebar cố định 240px bên trái | Bottom Navigation Bar 4 tab |
| **Phím tắt học** | Phím `Space` lật thẻ, `1`-`4` đánh giá | Vuốt trái (Again), vuốt phải (Good), chạm lật thẻ |
| **Màn hình học** | Tập trung không xao nhãng (Centered 720px Card) | Toàn màn hình (Full width edge-to-edge) |
| **Nhập liệu** | Hỗ trợ gõ câu trả lời trực tiếp từ bàn phím rời | Bàn phím ảo tự động focus hoặc chọn trắc nghiệm |
