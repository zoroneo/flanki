---
title: Quy Chuẩn Kiến Trúc Layout, Modular Widget & UI/UX Responsive
created: 2026-09-11
tags:
  - ui
  - ux
  - layout
  - responsive
  - flutter
  - architecture
  - clean-code
---

# 📐 Quy Chuẩn Kiến Trúc Layout, Modular Widget & UI/UX Responsive

Tài liệu đặc tả toàn bộ các nguyên tắc bắt buộc về tổ chức mã nguồn UI, cấu trúc layout thích ứng đa nền tảng (Mobile, Tablet, Desktop), tối ưu mật độ hiển thị và trải nghiệm người dùng trong dự án **Flanki**.

---

## 1. Kiến Trúc Tách Widget Modular (Giới Hạn ~300 Dòng)

> [!IMPORTANT] Quy Tắc ~300 Dòng / File
> Mỗi file màn hình (Screen) hoặc Widget chỉ nên dài **khoảng 300 dòng** (ngưỡng tối đa ~400 dòng). Bất kỳ file nào phình to đều phải phân rã thành các sub-widgets độc lập.

* **Cấu trúc thư mục chuẩn**: Mỗi màn hình phức tạp bắt buộc phải có thư mục `widgets/` tương ứng:
  * `lib/ui/screens/decks/widgets/` (DeckCard, DeckToolbar, DeckSpeedDial, DeckStatsBar)
  * `lib/ui/screens/browser/widgets/` (CardBrowserFilterBar, DesktopCardDetailPane, CardBrowserListItem)
  * `lib/ui/screens/settings/widgets/` (AccountSyncCard, SpacedRepetitionCard, SettingsInfoRows, ...)
  * `lib/ui/screens/study/widgets/` (StudyRatingBar, CardFrontView, CardBackView, TypeAnswerBox)
  * `lib/ui/screens/editor/widgets/` (NoteTypeSelectors, NoteEditorFields, NoteTagEditor)
  * `lib/ui/screens/grammar/widgets/` (GrammarUnitCard, GrammarCatalogStats, GrammarLevelFilters, ...)
* **Đóng gói trách nhiệm**: Mỗi widget con tự quản lý phần hiển thị của mình và giao tiếp với màn hình cha thông qua các callback chuẩn (`ValueChanged<T>`, `VoidCallback`).

---

## 2. Quy Chuẩn Hàm `build()` Điều Phối (Declarative Coordinator Pattern)

> [!WARNING] Cấm Cây Widget Lồng Nhau Hàng Trăm Dòng
> Tuyệt đối không lồng toàn bộ cây widget trực tiếp trong phương thức `build()`. Hàm `build()` chỉ đóng vai trò **điều phối khai báo (Declarative Coordinator)**.

* **Tách hàm Helper ngữ nghĩa**:
  * `_buildAppBar(...)`: Thanh tiêu đề, action buttons và shortcut hint.
  * `_buildMobileLayout(...)` / `_buildDesktopLayout(...)`: Cấu trúc riêng biệt cho từng loại thiết bị.
  * `_buildGrid(...)` / `_buildList(...)`: Danh sách thẻ hoặc sliver grid.
  * `_buildEmptyState(...)`: Trạng thái trống khi tìm kiếm hoặc lọc không có kết quả.
* **Tách biệt Logic & State**:
  * Các hooks (`useState`, `useEffect`, `useAnimationController`) và Riverpod watches nằm ở đầu hàm `build()`.
  * Truyền state xuống các hàm helper dưới dạng tham số typed rõ ràng.

---

## 3. Kích Thước Button & Nguyên Tắc Single-Action CTA

* **Không dùng Button quá to trên Mobile**:
  * Chiều cao nút trên mobile chuẩn hoá ở mức **38px – 44px** (`ButtonSize.small` hoặc `ButtonSize.normal`).
  * Tránh làm nút bấm phình to khiến diện tích hiển thị nội dung bị thu hẹp.
* **Triệt tiêu nút bấm trùng lặp (Single-Action CTA)**:
  * Không bố trí 2 nút cùng thực hiện một hành động (ví dụ: vừa có nút lật thẻ ở giữa vừa có nút lật thẻ ở dưới).
  * Giữ đúng 1 hành động chính (Primary CTA) rõ ràng, nổi bật cho mỗi ngữ cảnh.
* **Hiển thị phím tắt linh hoạt**:
  * Desktop: Kèm phím tắt ngay trên nút bấm (e.g. `[Space]`, `Ctrl/⌘ + ↵`, `1-4`).
  * Mobile: Ẩn phím tắt để tiết kiệm chiều ngang màn hình.

---

## 4. Chuẩn Hóa Responsive (`responsive_builder: ^0.7.1`)

> [!CAUTION] Cấm Xử Lý Thủ Công Bằng Raw MediaQuery Width
> Tuyệt đối không dùng các biểu thức so sánh cứng như `MediaQuery.of(context).size.width >= 800` trong cây widget.

* **Áp dụng toàn diện `responsive_builder`**:
  * Dùng `ScreenTypeLayout.builder` khi giao diện mobile và desktop có cấu trúc khác biệt căn bản (ví dụ: Mobile 1 cột vs Desktop Master-Detail 2 cột).
  * Dùng `getValueForScreenType<T>` để tính toán các tham số tỉ lệ (số cột grid, padding, khoảng cách spacing):
    ```dart
    final crossAxisCount = getValueForScreenType<int>(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
    ```
* **Breakpoints chuẩn hóa**:
  * **Mobile**: `< 600px` (hoặc `< 800px` cho chế độ Master-Detail đa cột)
  * **Tablet**: `600px – 1024px`
  * **Desktop**: `>= 1024px`

---

## 5. Mật Độ Thông Tin & Typography Trên Mobile

* **Tối đa hóa diện tích hiển thị (Screen Real Estate)**:
  * Mobile có không gian hạn chế; cần giảm bớt font chữ quá lớn và các khoảng cách lề dư thừa.
* **Tỉ lệ Padding Card**:
  * **Mobile**: `12px – 16px` padding.
  * **Tablet/Desktop**: `20px – 24px` padding.
* **Thang kích thước chữ (Typography Scaling)**:
  * Tiêu đề chính màn hình/card: `15px – 17px`, `FontWeight.w700` trên Mobile (thay vì 20px – 24px của Desktop).
  * Nội dung body: `13px – 14px`.
  * Ghi chú, phụ đề: `10.5px – 11.5px`.

---

## 6. Đồng Bộ Header (AppBar) & Điều Hướng Hệ Thống

* **Nhất quán giữa các Tab**:
  * Tất cả các màn hình chính (Decks, Browser, Stats, Grammar, Settings) phải dùng chung phong cách AppBar: chiều cao, độ đậm chữ, icon hành động và lề hai bên.
* **Quy chuẩn Icon điều hướng**:
  * Quay lại màn hình trước: Luôn dùng `LucideIcons.chevronLeft` hoặc `LucideIcons.arrowLeft`.
  * Đóng cửa sổ / Modal / BottomSheet: Luôn dùng `LucideIcons.x`.

---

## 7. Xử Lý Padding Cuộn & Chống Cắt Xén Nội Dung

> [!WARNING] Cấm Cắt Xén Nội Dung Do Padding Cứng
> Không bao giờ bọc padding cố định bên ngoài `SingleChildScrollView` hay `ListView` dẫn đến việc phần tử đầu/cuối bị cắt mất khi người dùng cuộn.

* **Đưa padding vào trong danh sách cuộn**:
  * Luôn truyền `padding` trực tiếp vào container cuộn:
    * `SingleChildScrollView(padding: EdgeInsets.fromLTRB(16, 12, 16, 24))`
    * `ListView(padding: ...)` hoặc `SliverPadding(...)`
* **Safe Area Insets**:
  * Ở các thanh action dính đáy (Sticky Footer/CTA), bắt buộc cộng thêm `MediaQuery.paddingOf(context).bottom` để tránh bị thanh điều hướng ảo của hệ điều hành che khuất.

---

## 8. Tối Ưu Hóa Rebuild & Thu Gọn Consumer Scope (Render Isolation)

Chi tiết quy chuẩn kiến trúc xem tại: [[01-Architecture/06-State-Management-and-Render-Optimization|06. Kiến Trúc State Freezed & Tối Ưu Hóa Rebuild Riverpod]].

* **Tránh `ref.watch` rộng ở Screen Root**: Không lắng nghe toàn bộ Notifier State phức tạp ở gốc màn hình làm cả cây widget nặng nề rebuild lại khi chỉ có một trường thay đổi.
* **Bọc `Consumer` cục bộ tại lá cây (Leaf Nodes)**:
  * Huy hiệu badge, số lượng thẻ due, thanh tiến độ, icon trạng thái đồng bộ sync cần được bọc trong `Consumer` riêng hoặc dùng `ref.watch(provider.select(...))` để cô lập phạm vi dựng hình.
* **Tách Sub-Card thành `ConsumerWidget` độc lập**:
  * Các card cài đặt (như `AccountSyncCard`, `AppPreferencesCard`, `SpacedRepetitionCard`) tự quản lý lắng nghe state của mình, giải phóng màn hình cha `SettingsScreen` khỏi mọi thao tác re-render không cần thiết.
