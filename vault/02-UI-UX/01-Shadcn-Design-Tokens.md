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

---

## 3. Hệ Thống AppTokens (`lib/core/theme/app_tokens.dart`)

Dự án Flanki chuẩn hóa 100% kích thước khoảng cách, bo góc, icon và hoạt ảnh qua `AppTokens`:

### 3.1. Thang Đo Khoảng Cách (`AppSpacing`)
* `xs`: 4.0 dp (micro elements, indicator bars)
* `sm`: 8.0 dp (compact margins, inline badges)
* `smPlus`: 10.0 dp (mobile cards, compact buttons)
* `md`: 12.0 dp (default mobile inner padding)
* `mdPlus`: 14.0 dp (intermediate desktop rows)
* `lg`: 16.0 dp (standard card padding, form gaps)
* `xl`: 20.0 dp (modal dialogs, section dividers)
* `xxl`: 24.0 dp (desktop screen gutters)
* `xxxl`: 32.0 dp (hero headers)

### 3.2. Tiêu Chuẩn Bo Góc (`AppRadius`)
* `xs`: 4.0 dp (`AppRadius.borderXs`)
* `sm`: 6.0 dp (`AppRadius.borderSm`)
* `md`: 8.0 dp (`AppRadius.borderMd` - tiêu chuẩn thẻ/card)
* `lg`: 12.0 dp (`AppRadius.borderLg` - modal/overlay)
* `xl`: 16.0 dp (`AppRadius.borderXl`)
* `full`: 9999.0 dp (circle avatar, pill badge)

### 3.3. Tiêu Chuẩn Icon (`AppIconSize`)
* `xs`: 12.0 dp
* `sm`: 14.0 dp
* `md`: 16.0 dp
* `lg`: 20.0 dp
* `xl`: 24.0 dp
* `xxl`: 32.0 dp

### 3.4. Khoảng Cách Cố Định (`AppGaps`) & Đệm Lề (`AppEdgeInsets`)
* Cung cấp sẵn các `SizedBox` const: `AppGaps.v2`, `AppGaps.v4`, `AppGaps.v8`, `AppGaps.v12`, `AppGaps.v16`, `AppGaps.h4`, `AppGaps.h8`, `AppGaps.h12`, `AppGaps.h16`...
* Cung cấp các `EdgeInsets` tối ưu: `AppEdgeInsets.h12v8`, `AppEdgeInsets.h16v12`, `AppEdgeInsets.all12`, `AppEdgeInsets.all16`, `AppEdgeInsets.all20`...
* Kiểm soát tự động bằng linter: `fvm dart run tool/check_dimensions.dart`.

