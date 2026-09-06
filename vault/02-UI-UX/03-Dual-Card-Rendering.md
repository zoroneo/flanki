---
title: Cơ Chế Dual-Engine Render Thẻ (Native + WebKit)
created: 2026-09-06
tags:
  - architecture
  - ui
  - card-rendering
  - webview
---

# ⚡ Cơ Chế Dual-Engine Render Thẻ (Native + WebKit)

Một trong những hạn chế lớn nhất của Anki trên mobile là phải chạy Webview cho toàn bộ thẻ, gây tốn RAM và trễ cảm ứng. Flanki giải quyết bằng kiến trúc **Dual-Engine**:

```mermaid
flowchart TD
    Card[Dữ liệu Thẻ Flashcard] --> Detect{Kiểm tra độ phức tạp của Template}
    Detect -->|Chỉ có Text, Cloze, Markdown, Audio| Native[Native Flutter Engine]
    Detect -->|Có Custom HTML, CSS phức tạp, JS Scripts| WebEngine[WebKit / WebEngineView]

    Native --> Render1[Render bằng Flutter Text & Widgets cực mượt 120 FPS]
    WebEngine --> Render2[Render bằng WebKit cô lập an toàn]
```

## 1. Engine 1: Native Flutter Widget Engine (90% số thẻ)
* Áp dụng cho các thẻ từ vựng thông thường (Basic, Cloze deletion, TOEIC vocab, hình ảnh, audio).
* Thẻ được vẽ trực tiếp bằng Skia / Impeller của Flutter.
* **Tốc độ**: Render dưới 4ms, tiết kiệm 80% RAM, animation 120 FPS.

## 2. Engine 2: Embedded WebEngine (10% số thẻ còn lại)
* Áp dụng khi bộ thẻ người dùng import có chứa CSS phức tạp hoặc script Javascript tuỳ biến.
* Chạy trong WebView cô lập, hỗ trợ đầy đủ các tính năng nâng cao của Anki Desktop.
