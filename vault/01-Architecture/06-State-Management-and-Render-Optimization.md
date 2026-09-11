---
title: Kiến Trúc Quản Lý State Với Freezed & Tối Ưu Hóa Rebuild Riverpod
created: 2026-09-11
tags:
  - architecture
  - state-management
  - freezed
  - riverpod
  - performance
  - rendering
---

# 🚀 Kiến Trúc Quản Lý State Với Freezed & Tối Ưu Hóa Rebuild Riverpod

Tài liệu này chuẩn hóa mô hình quản lý trạng thái, tính bất biến (immutability) và kỹ thuật cô lập cây dựng hình (widget tree render isolation) trên toàn bộ ứng dụng **Flanki**.

---

## 1. Vấn Đề Hiệu Năng Trước Tối Ưu (The Bottlenecks)

1. **State Quản Lý Quá Nhiều Thuộc Tính (Fat States)**:
   - Các Notifier như `StudySessionNotifier`, `GrammarSessionNotifier` (13 fields), `SettingsNotifier` (10 fields) quản lý nhiều trạng thái đồng thời.
   - Trước khi áp dụng `@freezed`, việc kiểm tra equality giữa các state không thực hiện deep comparison cho collections (`List`, `Map`), dẫn đến việc phát tín hiệu notify liên tục dù giá trị nội bộ không đổi.
2. **Rebuild Toàn Bộ Màn Hình (Over-rendering Scope)**:
   - Các màn hình lớn như `DecksScreen`, `SettingsScreen`, `AdaptiveScaffold`, `MobileScaffold` sử dụng `ref.watch(provider)` trực tiếp tại root `build()`.
   - Hệ quả: Chỉ cần người dùng học 1 thẻ (cập nhật thống kê `stats`), thay đổi một cấu hình nhỏ (như giờ nhắc học `reminderHour`), hay lật thẻ thì toàn bộ cây danh sách hàng chục deck, slivers, thẻ cài đặt và bottom nav bar đều bị kích hoạt `build()` lại.

---

## 2. Kiến Trúc State Bất Biến Với Freezed

Toàn bộ 7 State Classes của ứng dụng đã được di chuyển sang `@freezed`:

| STT | State Model | File Định Nghĩa | File Sinh Mã | Đặc Tính Nổi Bật |
|---|---|---|---|---|
| 1 | `AuthState` | `lib/core/notifiers/auth_state.dart` | `auth_state.freezed.dart` | `unauthenticated()`, `authenticated()`, `error()`, deep equality |
| 2 | `StudySessionState` & `StudySessionSnapshot` | `lib/core/notifiers/study_session_notifier.dart` | `study_session_notifier.freezed.dart` | `initial()`, snapshot undo list bất biến |
| 3 | `GrammarSessionState` | `lib/core/notifiers/grammar_session_notifier.dart` | `grammar_session_notifier.freezed.dart` | 13 biến trạng thái, getters `currentExercise`, `progressFraction` |
| 4 | `CardBrowserState` | `lib/core/notifiers/card_browser_notifier.dart` | `card_browser_notifier.freezed.dart` | Bộ lọc danh sách thẻ, query tìm kiếm |
| 5 | `StudySettings` | `lib/core/notifiers/settings_notifier.dart` | `settings_notifier.freezed.dart` | 10 tham số thuật toán FSRS & tùy chọn app |
| 6 | `StatsData` | `lib/core/notifiers/stats_notifier.dart` | `stats_notifier.freezed.dart` | Ma trận 2D `List<List<int>> heatmapLevels` deep equal |
| 7 | `UpdateState` | `lib/core/notifiers/update_notifier.dart` | `update_notifier.freezed.dart` | Tiến độ tải bản cập nhật, mã lỗi `UpdateErrorType` |

---

## 3. Chiến Lược Thu Hẹp Watch Scope (Fine-Grained Selectors & Isolation)

### 3.1. Fine-Grained `select` Cho State Lớn
- Thay vì `ref.watch(studySessionProvider)`, các widget con chỉ lắng nghe đúng thuộc tính cần hiển thị:
  - `ref.watch(studySessionProvider.select((s) => s.currentCard))`
  - `ref.watch(studySessionProvider.select((s) => s.isFlipped))`
  - `ref.watch(studySessionProvider.select((s) => s.canUndo))`
- Kết quả: Khi timer tính giây học của thẻ trôi qua hoặc khi ghi nhận thẻ vào lịch sử undo, widget câu hỏi và thẻ bài không bị giật lag (giữ vững 60-120 FPS).

### 3.2. Bọc `Consumer` Tại Lá Cây (Leaf Node Scoping)
- **`DecksScreen`**:
  - Đưa `stats.streakDays` và `studySettings.desiredRetention` vào `Consumer` bọc riêng quanh `DeckStatsBar`.
  - Đưa FSRS badge (`studySettings.fsrsEnabled`) và Sync cloud button (`auth.isAuthenticated`) vào `Consumer` trong AppBar.
  - Cây danh sách Deck (hàng chục deck và nhóm deck) hoàn toàn không rebuild khi dữ liệu học hay cấu hình ứng dụng thay đổi.
- **`AdaptiveScaffold` / `MobileScaffold`**:
  - Badge số thẻ cần học `totalDue` được trích xuất bằng `select` và chỉ rebuild đúng icon tab Decks. Thân scaffold và các tab khác không re-render.

### 3.3. Tách Biệt Thẻ Cài Đặt Thành `ConsumerWidget` Độc Lập
- Chuyển đổi 5 thẻ của màn hình Cài đặt thành `ConsumerWidget`:
  - `AccountSyncCard`: Tự watch `authNotifierProvider`.
  - `AppPreferencesCard`: Tự watch `localeNotifierProvider`, `themeNotifierProvider`.
  - `SpacedRepetitionCard`: Tự watch `studySettingsProvider`.
  - `StudyRemindersCard`: Tự watch `studySettingsProvider`.
  - `AboutInfoCard`: Tự watch `updateProvider`, `themeNotifierProvider`.
- Màn hình cha `SettingsScreen` không còn bất kỳ `ref.watch` nào; tất cả các card đều là `const` constructor. Khi người dùng kéo thanh trượt tỷ lệ ghi nhớ (retention) hay chọn theme sáng/tối, chỉ duy nhất thẻ tương ứng được dựng hình lại.

---

## 4. Hiện Đại Hóa Provider Với `riverpod_annotation: ^4.0.7` & `riverpod_generator`

Toàn bộ Provider trong ứng dụng được chuẩn hóa bằng Riverpod Code Generator:

1. **Class-based Notifiers**:
   - Sử dụng `@Riverpod(keepAlive: true, name: '...') class XNotifier extends _$XNotifier`.
   - Giữ nguyên định danh Provider (`themeNotifierProvider`, `localeNotifierProvider`, `deckListProvider`, v.v.) để bảo đảm 100% tương thích ngược với mã UI và Tests hiện có.
2. **Functional Providers & Router**:
   - Khai báo gọn gàng bằng cú pháp hàm: `@Riverpod(keepAlive: true) T myService(Ref ref)`.
   - **`appRouterProvider`**: Chuẩn hóa router `GoRouter` tại `lib/ui/router/app_router.dart` với generator `@Riverpod(keepAlive: true) GoRouter appRouter(Ref ref)` -> `app_router.g.dart`. Lắng nghe `authNotifierProvider` bằng `Listenable.merge` để tự động chuyển hướng (auth redirect/guards) an toàn.
3. **Lợi ích kiến trúc**:
   - Loại bỏ boilerplate thủ công `NotifierProvider<X, State>(X.new)`.
   - Tự động sinh `debugGetCreateSourceHash()`, `overrideWithValue()` chuẩn mực cho unit testing.
   - Type-safe hoàn toàn, tự động đồng bộ khi state thay đổi qua `build_runner`.

---

## 5. Chuẩn Hóa Cấu Trúc Layer-First Notifiers (`lib/core/notifiers/`)

Trước khi chuẩn hóa, các Notifier bị phân mảnh tại các thư mục màn hình UI (`lib/ui/screens/.../notifiers/`), gây phụ thuộc vòng giữa UI và Core services, cản trở việc kiểm thử đơn vị độc lập.

### 5.1. Gom Cụm Về `lib/core/notifiers/`
Toàn bộ Notifiers của ứng dụng được di chuyển và quản lý tập trung:
- `auth_notifier.dart` & `auth_state.dart`
- `theme_notifier.dart`
- `locale_notifier.dart`
- `deck_list_notifier.dart`
- `study_session_notifier.dart`
- `grammar_session_notifier.dart`
- `card_browser_notifier.dart`
- `settings_notifier.dart`
- `stats_notifier.dart`
- `update_notifier.dart`

### 5.2. Barrel Export Tập Trung
- Điểm truy xuất duy nhất: `lib/core/notifiers/notifiers.dart`.
- Bất kỳ thành phần UI hay Service nào chỉ cần `import 'package:flanki/core/notifiers/notifiers.dart';` là có thể truy cập đầy đủ các state và provider.

### 5.3. Loại Bỏ File Tham Chiếu & Import Trực Tiếp (Zero-Indirection Direct Imports)
- Toàn bộ các file tham chiếu/forwarder trung gian (`core/auth/auth_notifier.dart`, `core/localization/locale_notifier.dart`, `core/theme/theme_notifier.dart`) đã được xóa bỏ triệt để.
- 100% các màn hình, widgets và bộ kiểm thử chuyển sang import trực tiếp vào file cụ thể tại `core/notifiers/` (hoặc thông qua barrel export `package:flanki/core/notifiers/notifiers.dart`), loại bỏ hoàn toàn tầng indirection thừa thãi.

---

## 6. Quy Chuẩn Kiểm Định (Quality Gates)

Mọi thay đổi liên quan đến State & Notifier đều phải thỏa mãn 2 điều kiện tiên quyết:
1. `fvm flutter analyze` đạt 0 warnings, 0 errors, 0 lints.
2. `fvm flutter test` chạy trọn vẹn toàn bộ 117 tests không lỗi (100% pass rate).
