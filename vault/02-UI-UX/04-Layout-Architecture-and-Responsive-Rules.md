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

* **Cấu trúc thư mục chuẩn**: Mỗi màn hình phức tạp bắt buộc phải có thư mục `widgets/` tương ứng bên trong `lib/features/<feature>/ui/widgets/`:
  * `lib/features/decks/ui/widgets/` (DeckAppBar, DeckEmptyState, DeckSlivers, DeckCard, DeckToolbar, DeckSpeedDial, DeckStatsBar)
  * `lib/features/browser/ui/widgets/` (BrowserDesktopLayout, BrowserMobileLayout, CardBrowserFilterBar, DesktopCardDetailPane, CardBrowserListItem)
  * `lib/features/settings/ui/widgets/` (AccountSyncCard, SpacedRepetitionCard, SettingsInfoRows, ...)
  * `lib/features/study/ui/widgets/` (StudyAppBar, StudyCardFlipper, StudyBottomActionArea, StudyFinishedView, StudyRatingBar, CardFrontView, CardBackView, TypeAnswerBox)
  * `lib/features/editor/ui/widgets/` (DeckPickerDropdown, NoteEditorDesktopLayout, NoteEditorMobileLayout, NoteTypeSelectors, NoteEditorFields, NoteTagEditor)
  * `lib/features/grammar/ui/widgets/` (GrammarPracticeQuestionContent, GrammarExitDialog, PracticeShortcutsGuide, GrammarUnitCard, GrammarCatalogStats, GrammarLevelFilters, ...)
* **Đóng gói trách nhiệm**: Mỗi widget con tự quản lý phần hiển thị của mình và giao tiếp với màn hình cha thông qua các callback chuẩn (`ValueChanged<T>`, `VoidCallback`).

### 1.1. Bảng Tiêu Biểu Phân Rã Màn Hình (Case Study: Decomposed Screens)

Toàn bộ các file màn hình và widget phức tạp vượt quá ngưỡng cho phép đã được tái cấu trúc triệt để theo mô hình này:

| File Gốc | Dòng Trước | Dòng Sau | Mức Giảm | Các Sub-Widgets & Helpers Được Tách |
|---|---|---|---|---|
| `lib/main.dart` | 403 | 191 | **-52.6%** | `AppLifecycleManager` (`lib/core/widgets/app_lifecycle_manager.dart`) |
| `lib/core/widgets/app_lifecycle_manager.dart` | 497 | 286 | **-42.5%** | `update_toasts.dart` (`BackgroundDownloadToast`, `UpdateReadyToast`, ...) |
| `lib/core/widgets/rich_card_content.dart` | 446 | 260 | **-41.7%** | `card_content_parser.dart` (`CardContentParser`, HTML/regex tokenizer) |
| `lib/features/decks/ui/decks_screen.dart` | 640 | 308 | **-51.9%** | `deck_app_bar.dart`, `deck_empty_state.dart`, `deck_slivers.dart`, `deck_import_helper.dart` |
| `lib/features/decks/ui/widgets/grouped_deck_card.dart` | 377 | 273 | **-27.6%** | `subdeck_row_item.dart` (`SubdeckRowItem`) |
| `lib/features/study/ui/study_session_screen.dart` | 558 | 316 | **-43.4%** | `study_finished_view.dart`, `study_app_bar.dart`, `study_card_flipper.dart`, `study_bottom_action_area.dart`, `study_shortcuts.dart` |
| `lib/features/study/ui/widgets/card_action_sheet.dart` | 473 | 272 | **-42.5%** | `card_action_edit_form.dart`, `card_action_sheet_components.dart` (`CardFlagSelector`, `CardFsrsStatsCard`) |
| `lib/features/browser/ui/card_browser_screen.dart` | 576 | 110 | **-80.9%** | `browser_desktop_layout.dart`, `browser_mobile_layout.dart` |
| `lib/features/editor/ui/note_editor_screen.dart` | 526 | 249 | **-52.7%** | `deck_picker_dropdown.dart`, `note_editor_desktop_layout.dart`, `note_editor_mobile_layout.dart` |
| `lib/features/grammar/ui/grammar_practice_screen.dart` | 594 | 265 | **-55.4%** | `grammar_practice_question_content.dart`, `grammar_exit_dialog.dart`, `practice_shortcuts_guide.dart`, `grammar_practice_layouts.dart` |
| `lib/features/grammar/ui/widgets/grammar_theory_mobile_tabs.dart` | 518 | 176 | **-66.0%** | `grammar_theory_tab_views.dart`, `grammar_theory_extra_tab_views.dart` |
| `lib/features/grammar/ui/widgets/explanation_sheet.dart` | 461 | 206 | **-55.3%** | `explanation_content_cards.dart` (`ExplanationSection`, `DistractorItemCard`) |
| `lib/features/grammar/ui/widgets/grammar_theory_sections.dart` | 424 | 167 | **-60.6%** | `grammar_traps_guides_cards.dart` (`GrammarTheoryTrapsCard`, `GrammarTheoryGuidesCard`) |
| `lib/features/exam/ui/exam_taking_screen.dart` | 492 | 329 | **-33.1%** | `exam_taking_dialogs.dart`, `exam_questions_sheet.dart`, `exam_question_cards.dart`, `ExamTimerBadge` (tách scope rebuild) |
| `lib/features/sync/ui/anki_web_auth_sheet.dart` | 458 | 300 | **-34.5%** | `anki_web_auth_form.dart` (`AnkiWebAuthHeader`, `AnkiWebAuthErrorBanner`, `AnkiWebSubmitButton`) |
| `lib/features/sync/ui/supabase_auth_sheet.dart` | 349 | 256 | **-26.6%** | `supabase_auth_header.dart` (`SupabaseAuthHeader`) |
| `lib/features/sync/ui/widgets/sync_conflict_dialog.dart` | 365 | 273 | **-25.2%** | `sync_conflict_option_tile.dart` (`ConflictOptionCard`) |
| `lib/features/settings/ui/licenses_screen.dart` | 485 | 212 | **-56.3%** | `license_cards.dart` (`PackageLicense`, `LicenseCodeBlock`, `FlankiLicenseCard`, `PackageLicenseCard`) |

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

* **Nhất quán giữa các Tab & Sub-screens**:
  * Tất cả các màn hình chính (Decks, Browser, Stats, Grammar, Settings) và các màn hình phụ/modal (NoteEditor, GrammarTheory, GrammarPractice, Licenses, PrivacyPolicy) phải dùng chung phong cách AppBar: chiều cao, cỡ chữ, độ đậm chữ, icon hành động và lề hai bên.
* **Quy chuẩn Title AppBar trên Mobile**:
  * **Tránh rớt dòng & font quá khổ**: Bắt buộc giới hạn `maxLines: 1` và `overflow: TextOverflow.ellipsis`.
  * **Typography quy chuẩn**: Dùng `(isMobile ? theme.typography.base : theme.typography.large).copyWith(fontWeight: FontWeight.w600)` (hoặc `theme.typography.base` ~16px) thay vì để Shadcn mặc định kế thừa `h4` (20px - 24px) gây tràn chữ và phình to mất cân đối.
  * **Nút hành động Trailing trên Mobile**: Các nút submit/save trên AppBar phải đặt `size: ButtonSize.small` để không chiếm dụng bề ngang của tiêu đề.
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

---

## 9. Cơ Chế Phân Cụm Nội Dung Mobile (Swipeable Segmented Tabs & Clean Reader)

> [!IMPORTANT] Giải Quyết "Hội Chứng Mỏi Cuộn Dọc" (Vertical Infinite Scroll Fatigue)
> Trên màn hình điện thoại (chiều rộng hẹp, chiều dọc dài), việc dồn mọi tài liệu học/lý thuyết dài thành một danh sách cuộn dọc liên tục sẽ khiến người dùng mất phương hướng, khó tra cứu và mỏi ngón tay. Bắt buộc áp dụng cơ chế **Swipeable Tabs kết hợp Clean Reader**.

* **Thanh Tab Trượt Ngang Tự Co Giãn (Adaptive Segmented Bar)**:
  * Đặt ngay dưới Header Banner, chiều cao cố định chuẩn **36px – 38px**.
  * Dùng `ListView.separated(scrollDirection: Axis.horizontal)` với nhãn ngắn gọn (`Cốt lõi`, `Công thức`, `Bẫy thi`, `Mở rộng`).
  * Tab chỉ hiển thị khi mục nội dung đó thực sự có dữ liệu (tự động loại bỏ tab rỗng).
  * Tab được chọn có nền `color.withValues(alpha: 0.12)`, viền `color.withValues(alpha: 0.35)`, chữ đậm màu nhận diện.
* **Vuốt Ngang Chuyển Luồng (Two-Way Gesture Navigation)**:
  * Nội dung bên dưới bọc trong `PageView.builder` kết hợp `PageController`.
  * Hỗ trợ đồng thời 2 cử chỉ ngón cái:
    1. Bấm vào nút Tab ở trên để nhảy tức thì đến luồng mong muốn (`animateToPage`).
    2. Vuốt ngang (swipe left/right) trực tiếp trên vùng đọc nội dung để lướt qua lại mượt mà (`onPageChanged` sync ngược lại active tab index).
* **Mỗi Luồng Là Một Stream Độc Lập**:
  * Tab Cốt Lõi: Tập trung diễn giải bản chất và tư duy gốc của ngữ pháp/chủ đề.
  * Tab Công Thức: Trực quan hóa công thức cú pháp, chia động từ dạng bảng/code block.
  * Tab Bẫy Thi: Trực diện vào các lỗi sai kinh điển, cấu trúc câu `Đúng` (xanh) vs `Sai` (đỏ) và phân tích nguyên nhân.
  * Tab Mở Rộng: Các trường hợp đặc biệt, ngoại lệ, mẹo nhớ nhanh.

---

## 10. Quy Tắc Trừ Khử Lồng Card & Padding Bloat (Anti-Nested-Card Padding)

> [!CAUTION] Cấm Lỗi "Card Lồng Card" và Double Padding
> Component `Card` của thư viện `shadcn_flutter` đã có thuộc tính padding mặc định (~16px). Việc bọc thêm `Padding` bên trong con của `Card` sẽ tạo ra lỗi cộng dồn padding (~30px – 32px mỗi bên), bóp nghẹt 20% - 25% diện tích hiển thị của màn hình mobile.

* **Truyền padding trực tiếp vào `Card(padding: ...)`**:
  * Không bao giờ viết: `Card(child: Padding(padding: ..., child: ...))`
  * Luôn viết: `Card(padding: isMobile ? const EdgeInsets.all(12) : const EdgeInsets.all(16), child: ...)`
* **Loại Bỏ Đường Viền Dày Không Cần Thiết Trên Mobile**:
  * Khi hiển thị danh sách thẻ con (như từng công thức hay từng bẫy thi), ưu tiên dùng background phẳng (`theme.colorScheme.muted.withValues(alpha: 0.3)`) với `BorderRadius.circular(8)` thay vì lồng thêm nhiều lớp `Card` với shadow/border nổi.
* **Mật Độ Khoảng Cách (Spacing)**:
  * Khoảng cách giữa các khối nội dung trên mobile: `SizedBox(height: 10)` đến `12`.
  * Khoảng cách giữa các tab: `SizedBox(width: 6)`.
  * Padding viền ngoài toàn màn hình đọc mobile: `12px` (thay vì 24px của desktop).

---

## 11. Header Banner Tinh Gọn Trên Mobile (Compact Lesson Banner)

* **Không Gian Chiều Dọc Tối Đa**:
  * Banner đầu bài học trên mobile chỉ nên cao khoảng **65px – 80px**.
  * Bố cục: Icon chủ đề (kích thước 32px - 34px), đi kèm 2 badge nhỏ gọn (Level & Chuyên mục) cỡ font 10.5px.
  * Tiêu đề bài học giới hạn `fontSize: 15px - 16px`, `fontWeight: FontWeight.w700`, `maxLines: 2`.
  * Triệt tiêu toàn bộ mô tả dài dòng chiếm nửa màn hình; nhường 100% tầm nhìn đầu tiên cho thanh Tabs và nội dung bài học.

---

## 12. Quy Chuẩn Triệt Tiêu Số Ma Thuật Kích Thước (`AppTokens` Guardrail)

> [!CAUTION] Cấm Tuyệt Đối Số Ma Thuật Kích Thước (Raw Numeric Dimensions)
> Không viết trực tiếp các giá trị số thô như `SizedBox(width: 8)`, `padding: EdgeInsets.all(16)`, `Icon(..., size: 16)`, `BorderRadius.circular(8)` trong code UI.

* **Sử dụng bộ token chuẩn hóa**:
  * `SizedBox` khoảng cách: dùng `AppGaps.h8`, `AppGaps.v12`, `AppGaps.v16`...
  * `EdgeInsets`: dùng `AppEdgeInsets.all12`, `AppEdgeInsets.h12v8`, `AppEdgeInsets.h16v12`...
  * `BorderRadius`: dùng `AppRadius.borderSm`, `AppRadius.borderMd`, `AppRadius.borderLg`...
  * Kích thước biểu tượng: dùng `AppIconSize.xs` (12), `sm` (14), `md` (16), `lg` (20), `xl` (24).
* **Kiểm tra tự động trước commit (Automated Dimension Guardrail)**:
  * Lệnh kiểm tra: `fvm dart run tool/check_dimensions.dart`.
  * Tự động quét toàn bộ `lib/` và chặn đứng mọi PR/commit vi phạm.

---

## 13. Bảo Đảm Miễn Nhiễm Tràn Màn Hình (Zero Overflow Guarantee)

* **Ma Trận Khung Nhìn Đa Thiết Bị (Viewport & Scale Matrix)**:
  1. `Small Mobile`: 320 x 568 (iPhone SE gen 1, Android compact).
  2. `Small Mobile + A11y Text Scale`: 320 x 568 với `TextScaler.linear(1.5)` (chế độ người khiếm thị/chữ to).
  3. `Standard Mobile`: 390 x 844 (iPhone 14/15/16).
  4. `Tablet`: 768 x 1024 (iPad Mini / Portrait Tablet).
  5. `Desktop`: 1280 x 800 (Laptop / Desktop Window).
* **Quy Tắc Thích Ứng Thành Phần Con (Component Responsive Rules)**:
  * **Dialogs & BottomSheets**: Dưới 420px tự động chuyển bố cục nút từ `Row` sang `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` (như `UpdateDialog`, `SyncConflictDialog`).
  * **Text & Labels**: Mọi tiêu đề trên `Row` đều phải bọc trong `Flexible` hoặc `Expanded` kèm `maxLines: 1` và `overflow: TextOverflow.ellipsis`.
  * **Form & Sheet Inputs**: Luôn có `SingleChildScrollView` với `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` để không bị bàn phím ảo đẩy tràn màn hình.
  * **Test Tự Động**: Toàn bộ ma trận được bảo vệ bởi test suite `test/widget/screens/overflow_resizing_matrix_test.dart`.

---

## 14. Cách Ly Đổi Kích Thước Bàn Phím (Bottom Inset Isolation & Stable Layout)

> [!IMPORTANT] Triệt Tiêu Biến Dạng Khung Nhìn Khi Xuất Hiện Bàn Phím Ảo
> Mặc định Flutter Scaffold bật `resizeToAvoidBottomInset: true`. Khi người dùng chạm vào ô tìm kiếm hoặc ô nhập từ, bàn phím ảo bật lên đẩy đáy màn hình lên đột ngột, làm các widget layout (như thẻ Card, FAB, SpeedDial, BottomNav) bị ép méo hoặc nhảy vị trí giật cục.

* **Khóa Khung Nhìn Tuyệt Đối (`resizeToAvoidBottomInset: false`)**:
  * Áp dụng trên toàn bộ khung Scaffold chính: `AdaptiveScaffold`, `DecksScreen`, `BrowserMobileLayout`.
  * Giữ nguyên kích thước chiều cao của toàn bộ cây widget, bảo toàn tỉ lệ card 100%.
* **Bù Trừ Khoảng Đệm Bàn Phím Có Chọn Lọc (Selective Inset Compensation)**:
  * Đọc độ cao bàn phím động: `final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;`
  * Ở chân danh sách cuộn (`SliverToBoxAdapter` / `CustomScrollView`), cộng thêm `keyboardBottom` vào khoảng đệm cuối (`height: 100 + keyboardBottom`), bảo đảm phần tử cuối cùng vẫn cuộn lên được trên bàn phím.
  * Ẩn các nút hành động nổi (Floating SpeedDial/Buttons) khi `isKeyboardOpen = keyboardBottom > 0` để không che khuất nội dung gõ.

---

## 15. Nút Thẻ Tương Tác Nổi & Vật Lý Hút Viền (`DraggableQuickFocusTag`)

* **Khái Niệm**: Thẻ điều khiển nổi mini kích thước **44px x 44px** trên các thẻ học có ô nhập `{{type:...}}` trên thiết bị cảm ứng (Mobile/Tablet).
* **Mô Hình Vật Lý Hút Viền (Edge-Snapping Kinematics)**:
  * Sử dụng `GestureDetector` với `onPanUpdate` và `onPanEnd(DragEndDetails details)`.
  * Khi người dùng buông tay, vận tốc vuốt được đánh giá qua `details.velocity.pixelsPerSecond`:
    * Nếu `velocityX > 400`: Hút mạnh về cạnh phải (`cardWidth - tagSize`).
    * Nếu `velocityX < -400`: Hút mạnh về cạnh trái (`0.0`).
    * Nếu vuốt nhẹ hoặc thả tay: So sánh tọa độ ngang với điểm giữa `midX = (cardWidth - tagSize) / 2` để quyết định mép hút gần nhất.
  * Tọa độ dọc $Y$ tính toán đà rơi tự nhiên kết hợp clamp an toàn:
    `targetY = (startPos.dy + velocityY * 0.06).clamp(edgeMargin, cardHeight - tagSize - edgeMargin)`
  * Chuyển động hút dùng `AnimationController` với `Curves.easeOutCubic` (thời lượng 250ms), kết hợp rung xúc giác nhẹ `HapticFeedback.lightImpact()`.
* **Phản Hồi Trạng Thái (Active/Inactive State)**:
  * Khi ô nhập đang focus (`isFocused = true`): Tag chuyển sang viền sáng nhận diện `theme.colorScheme.primary` kèm hiệu ứng viền phát sáng nhẹ.
  * Khi bấm vào Tag: Tự động gọi `focusNode.requestFocus()` và cuộn mượt đưa ô gõ vào vùng nhìn (`scrollController.animateTo`).

---

## 16. Hệ Thống Điều Hướng Đa Nền Tảng & Chống Tràn Thanh Tab Mobile (5-Tab Adaptive Navigation & Zero-Overflow)

> [!IMPORTANT] Thích Ứng Điều Hướng Nhất Quán Giữa Desktop Sidebar, Tablet NavRail & Mobile BottomNav
> Khi bổ sung phân hệ Đề Thi (`/exams`), số lượng nhánh chính tăng lên 5 tabs: **Decks (0)**, **Browser (1)**, **Grammar (2)**, **Exams (3)**, **Stats (4)**, cộng thêm lối tắt Cài đặt **Settings**.

* **Cấu Trúc Router Phân Nhánh (`StatefulShellBranch`)**:
  * Định nghĩa tại `lib/router/app_router.dart`: Tích hợp nhánh thứ 4 cho `/exams` render `ExamCatalogScreen()`.
  * Các màn hình thi (`ExamTakingScreen`) và kết quả thi (`ExamResultScreen`) là tuyến con nhưng cấu hình `parentNavigatorKey: rootNavigatorKey` để hiển thị chế độ toàn màn hình (Fullscreen Experience), ẩn hoàn toàn thanh điều hướng ngoài.
* **Phím Tắt Đa Nền Tảng (Desktop & Keyboard Ergonomics)**:
  * Desktop Sidebar (`DesktopSidebar`):
    * `Ctrl+1`: Decks
    * `Ctrl+2`: Card Browser
    * `Ctrl+3`: Grammar
    * `Ctrl+4`: Exams (Icon: `LucideIcons.graduationCap`)
    * `Ctrl+5`: Stats
    * `Ctrl+6`: Settings
  * Tablet NavRail (`TabletNavRail`): Đồng bộ các phím tắt `Ctrl+1`..`Ctrl+6` và hỗ trợ cả tap lẫn keyboard shortcuts.
* **Quy Chuẩn Chống Tràn Thanh Điều Hướng Đáy 5 Tab (Mobile Bottom Bar Zero-Overflow)**:
  * Trên màn hình mobile siêu hẹp 320px (iPhone SE 1st gen, Android nhỏ), thanh điều hướng đáy có 5 items cạnh tranh bề ngang $320px - 2 \times 8px \text{ padding} = 304px$ (mỗi tab chỉ có ~60px).
  * Quy tắc bảo vệ nghiêm ngặt trong `MobileBottomNavBar`:
    1. Bọc mỗi tab trong `Expanded`.
    2. Ràng buộc `constraints: BoxConstraints(minWidth: 40)`.
    3. Padding ngang thu hẹp tối đa: `EdgeInsets.symmetric(horizontal: 2, vertical: 4)`.
    4. Cỡ icon 18px (`AppIconSize.md`).
    5. Text nhãn: `maxLines: 1`, `overflow: TextOverflow.ellipsis`, `fontSize: 10.5px`.
  * Đảm bảo kiểm thử **Zero Overflow Guarantee** vượt qua 100% trong `overflow_resizing_matrix_test.dart`.



