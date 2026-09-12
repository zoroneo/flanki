# Flanki Architecture Guidelines (Feature-First)

## 1. Directory Blueprint

```text
lib/
├── core/                         # Shared infrastructure across the entire app
│   ├── anki/                     # anki_bridge, template engine, apkg importer
│   ├── database/                 # app_database (Drift), database_service
│   ├── fsrs/                     # FSRS & SM2 scheduler engines
│   ├── services/                 # notification, window, desktop update poller
│   ├── theme/ & localization/    # App styling, l10n
│   ├── extensions/ & utils/      # Common helpers
│   └── widgets/                  # Primitive UI (adaptive_scaffold, mobile_scaffold, etc.)
│
├── features/                     # Vertical Slices
│   ├── <feature_name>/
│   │   ├── data/                 # Repositories & specific data sources (optional)
│   │   ├── models/               # Domain entities & Freezed UI states
│   │   ├── providers/            # Riverpod Notifiers (@riverpod)
│   │   └── ui/                   # Screens & local widgets
│
├── router/                       # GoRouter route declarations
└── main.dart
```

## 2. Dependency Matrix & Architectural Guardrails

| Source Layer | Allowed to Import | FORBIDDEN to Import |
| :--- | :--- | :--- |
| **`core/`** | External packages, Flutter SDK, `core/` internals | ❌ `features/**`, `router/**` |
| **`features/<A>/`** | `core/**`, internal `features/<A>/**` | ❌ `features/<B>/ui/**`, `features/<B>/providers/**` |
| **`router/`** | `features/**/ui/**`, `core/**` | - |

### Cross-Feature Communication Rules
1. **Navigation:** Features must never push or instantiate screens belonging to another feature directly. Always use `context.go(...)` or `context.push(...)` via **GoRouter**.
2. **Shared Data:** If multiple features need access to a shared domain entity (e.g., `Deck`, `Card`), that entity resides in `core/` or is exposed via a shared contract/provider in `core/`.
3. **No circular imports:** Never create cyclical dependencies between modules.

## 3. Code Generation Runbook (`build_runner`)
When moving files containing generated parts:
1. Move the `.dart` file.
2. Delete outdated `.g.dart` and `.freezed.dart` files from the old location.
3. Update relative paths in imports and `part '...g.dart';` / `part '...freezed.dart';`.
4. Run:
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```
5. Verify with:
   ```bash
   fvm flutter analyze
   ```
