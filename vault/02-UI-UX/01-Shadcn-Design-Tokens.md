---
title: Hệ Thống Design Tokens & shadcn_flutter
created: 2026-09-06
tags:
  - ui
  - ux
  - design-system
  - shadcn
---

# 🎨 Hệ Thống Design Tokens & shadcn_flutter

Flanki sử dụng thư viện **`shadcn_flutter`** để mang lại ngôn ngữ thiết kế tối giản, sắc nét và hiện đại.

## 1. Bảng Màu (Color Palette): Zinc Theme
* **Dark Mode (`ColorSchemes.darkZinc`)**: Nền đen xám carbon (`#09090b`), chữ xám nhạt (`#fafafa`), viền phân cách mỏng (`#27272a`). Chống mỏi mắt tuyệt đối khi học ban đêm.
* **Light Mode (`ColorSchemes.lightZinc`)**: Nền trắng tinh khiết (`#ffffff`), chữ đen xám than (`#09090b`), viền sắc nét (`#e4e4e7`).

```dart
// Theme initialization
ShadcnApp(
  theme: ThemeData(
    colorScheme: ColorSchemes.lightZinc,
    radius: 0.5, // Bo góc 8px tiêu chuẩn
  ),
  darkTheme: ThemeData(
    colorScheme: ColorSchemes.darkZinc,
    radius: 0.5,
  ),
);
```

---

## 2. Thẻ Đánh Giá (Rating Action Buttons)
Các nút đánh giá sau khi lật thẻ được mã hoá màu theo mức độ nhận thức:
* **Again (Quên)**: `DestructiveButton` (Đỏ `#ef4444`) — Phím `1`
* **Hard (Khó)**: `OutlineButton` (Cam `#f97316`) — Phím `2`
* **Good (Tốt)**: `PrimaryButton` (Xanh dương `#3b82f6`) — Phím `3`
* **Easy (Dễ)**: `PrimaryButton` (Xanh lá `#22c55e`) — Phím `4`
