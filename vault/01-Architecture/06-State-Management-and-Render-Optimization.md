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

Toàn bộ 7 State Classes của ứng dụng đã được đóng gói thành các value objects thuần túy tại thư mục `domain/` của từng Feature slice:

| STT | State Model | File Định Nghĩa | File Sinh Mã | Đặc Tính Nổi Bật |
|---|---|---|---|---|
| 1 | `AuthState` | `lib/features/sync/domain/auth_state.dart` | `auth_state.freezed.dart` | `unauthenticated()`, `authenticated()`, `error()`, deep equality |
| 2 | `StudySessionState` & `StudySessionSnapshot` | `lib/features/study/domain/study_session_state.dart` | `study_session_state.freezed.dart` | `initial()`, snapshot undo list bất biến |
| 3 | `GrammarSessionState` | `lib/features/grammar/domain/grammar_session_state.dart` | `grammar_session_state.freezed.dart` | 13 biến trạng thái, getters `currentExercise`, `progressFraction` |
| 4 | `CardBrowserState` | `lib/features/browser/domain/card_browser_state.dart` | `card_browser_state.freezed.dart` | Bộ lọc danh sách thẻ, query tìm kiếm, `CardFilterType` |
| 5 | `StudySettings` | `lib/features/settings/domain/settings_state.dart` | `settings_state.freezed.dart`<br>`settings_state.g.dart` | 10 tham số thuật toán FSRS, tuần tự hóa tự động qua `json_serializable` (`fromJson`/`toJson`) |
| 6 | `StatsData` | `lib/features/stats/domain/stats_state.dart` | `stats_state.freezed.dart` | Ma trận 2D `List<List<int>> heatmapLevels` deep equal |
| 7 | `UpdateState` | `lib/features/settings/domain/update_state.dart` | `update_state.freezed.dart` | Tiến độ tải bản cập nhật, enum `UpdateStatus`, `UpdateErrorType` |

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
   - **`appRouterProvider`**: Chuẩn hóa router `GoRouter` tại `lib/router/app_router.dart` với generator `@Riverpod(keepAlive: true) GoRouter appRouter(Ref ref)` -> `app_router.g.dart`. Lắng nghe `authNotifierProvider` bằng `Listenable.merge` để tự động chuyển hướng (auth redirect/guards) an toàn.
3. **Lợi ích kiến trúc**:
   - Loại bỏ boilerplate thủ công `NotifierProvider<X, State>(X.new)`.
   - Tự động sinh `debugGetCreateSourceHash()`, `overrideWithValue()` chuẩn mực cho unit testing.
   - Type-safe hoàn toàn, tự động đồng bộ khi state thay đổi qua `build_runner`.

---

## 5. Chuẩn Hóa State & Notifier Phân Bố Theo Feature-First Architecture

Hệ thống quản lý trạng thái được đóng gói trực tiếp vào từng feature slice tương ứng, đảm bảo High Cohesion và Loose Coupling:

```
lib/
├── core/
│   ├── localization/
│   │   └── locale_notifier.dart      # (locale_notifier.g.dart)
│   └── theme/
│       └── theme_notifier.dart       # (theme_notifier.g.dart)
├── features/
│   ├── browser/
│   │   ├── domain/card_browser_state.dart
│   │   └── logic/card_browser_notifier.dart
│   ├── decks/
│   │   └── logic/deck_list_notifier.dart
│   ├── grammar/
│   │   ├── domain/grammar_session_state.dart
│   │   └── logic/
│   │       ├── grammar_session_notifier.dart
│   │       └── grammar_answer_evaluator.dart
│   ├── settings/
│   │   ├── domain/
│   │   │   ├── settings_state.dart
│   │   │   └── update_state.dart
│   │   └── logic/
│   │       ├── settings_notifier.dart
│   │       └── update_notifier.dart
│   ├── stats/
│   │   ├── domain/stats_state.dart
│   │   └── logic/stats_notifier.dart
│   ├── study/
│   │   ├── domain/study_session_state.dart
│   │   └── logic/study_session_notifier.dart
│   └── sync/
│       ├── domain/auth_state.dart
│       └── logic/auth_notifier.dart
└── router/
    └── app_router.dart               # (app_router.g.dart)
```

### 5.1. Domain State Models (Pure Value Objects)
- Nằm trong `lib/features/<feature>/domain/`.
- Sử dụng `@freezed` để sinh `*.freezed.dart`.
- **Hoàn toàn không phụ thuộc vào `flutter_riverpod` hay `riverpod_annotation`**.
- Đảm bảo tính bất biến (immutability), deep equality cho collections/ma trận và hàm `copyWith()`.

### 5.2. Logic Controllers (Riverpod Notifiers)
- Nằm trong `lib/features/<feature>/logic/` (hoặc `core/localization/`, `core/theme/` đối với state toàn cục).
- Chỉ chứa business logic và state mutations qua các action methods.
- Sinh mã bằng `riverpod_generator` (`*.g.dart`).
- Mỗi Notifier import trực tiếp file State tương ứng trong cùng feature slice.

### 5.3. Trích Xuất Domain Logic
- Logic chấm điểm ngữ pháp phức tạp (`GrammarAnswerEvaluator`) được đóng gói tại `lib/features/grammar/logic/grammar_answer_evaluator.dart`.
- Notifier chỉ đóng vai trò điều phối luồng người dùng và cập nhật state, giữ SRP (Single Responsibility Principle).

### 5.4. Xóa Bỏ Hoàn Toàn `core/states/` & `core/notifiers/`
- Toàn bộ các thư mục gom cụm phẳng cũ (`core/states/`, `core/notifiers/`, `ui/`) đã được dọn sạch 100%.
- Không còn các barrel export trung gian thừa thãi gây import cycles. Mỗi component import trực tiếp từ domain/logic của feature cần thiết theo quy chuẩn `ARCHITECTURE.md`.

---

## 6. Quy Chuẩn Kiểm Định (Quality Gates)

Mọi thay đổi liên quan đến State & Notifier đều phải thỏa mãn 2 điều kiện tiên quyết:
1. `fvm flutter analyze` đạt 0 warnings, 0 errors, 0 lints.
2. `fvm flutter test` chạy trọn vẹn toàn bộ 120 tests không lỗi (100% pass rate).
