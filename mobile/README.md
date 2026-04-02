# Mobile — Module Split (Passenger + Driver)

Both apps now follow a **feature-first MVVM** layout inside `lib/`.

---

## Monorepo layout

```
mobile/
├── passenger/          # Rider-facing Flutter app
├── driver/             # Driver-facing Flutter app
└── shared/             # sakai_shared — shared UI, theme, and generated API client
```

---

## Module structure (per app)

Each app's `lib/` is split by feature, and each feature keeps MVVM parts together:

```
lib/
├── main.dart                 # Entry point — wires dependencies, calls runApp()
├── app/                      # App root (MaterialApp, routes)
└── features/
    └── <feature>/
        ├── models/           # Feature entities/value types/exceptions
        ├── repositories/     # Repository contracts + implementations
        ├── view_models/      # ChangeNotifier-based view models
        └── views/            # Widgets/screens (View layer)
```

### MVVM responsibilities

| Area              | What lives here                                                           | Must NOT import            |
|-------------------|---------------------------------------------------------------------------|----------------------------|
| `features/*/models`       | Feature entities (`*Session`, `*Exception`)                               | Flutter UI concerns        |
| `features/*/repositories` | Repository interfaces + implementations, API calls, DTO mapping          | View widgets               |
| `features/*/view_models`  | UI state/actions (`ChangeNotifier`)                                       | Widget tree concerns       |
| `features/*/views`        | Screens/widgets only                                                      | HTTP/API clients directly  |
| `app/`                    | `MaterialApp`, routes, app-level composition                             | feature business logic     |

---

## passenger (`mobile/passenger`)

**Current state:** Auth flow is fully implemented end-to-end.

```
lib/
├── main.dart                            # Creates repositories, runApp
├── app/passenger_app.dart               # MaterialApp + routes
└── features/
    ├── auth/
    │   ├── models/
    │   ├── repositories/
    │   ├── view_models/
    │   └── views/
    ├── home/
    │   ├── repositories/
    │   ├── view_models/
    │   └── views/
    └── ride/
        ├── models/
        ├── repositories/
        ├── view_models/
        └── views/
```

**Key dependency:** `sakai_shared` (theme + generated `SakaiApiClient`), `built_value`, `dio`.

---

## driver (`mobile/driver`)

**Current state:** Scaffold in place; UI-only with feature-first MVVM boundaries ready for future work.

```
lib/
├── main.dart                            # runApp(DriverApp())
├── app/driver_app.dart                  # MaterialApp + routes
└── features/home/
    ├── models/driver_session.dart       # DriverSession entity (placeholder)
    ├── repositories/driver_repository_impl.dart
    ├── view_models/driver_home_view_model.dart
    └── views/driver_home_screen.dart
```

**Planned additions:** driver auth, WebSocket trip-state updates, GPS location reporting.

---

## shared (`mobile/shared` → package `sakai_shared`)

Imported by both apps via `path: ../shared`.

```
lib/
├── sakai_shared.dart          # Single barrel export
├── api/
│   └── sakai_api_support.dart # SakaiApiSupport.createClient() factory
├── api_client/                # Generated OpenAPI Dart client (sakai_api_client package)
├── theme/
│   ├── sakai_design_tokens.dart
│   ├── sakai_semantic_colors.dart
│   ├── sakai_theme.dart
│   └── sakai_theme_config.dart
└── widgets/
    ├── sakai_primary_button.dart
    ├── sakai_secondary_button.dart
    ├── sakai_screen_scaffold.dart
    ├── sakai_surface_card.dart
    └── sakai_text_field.dart
```

> **Note:** `api_client/` is also published as a separate package (`sakai_api_client`) so it can be depended on independently if needed.

---

## Adding a new feature — checklist

1. **API contract first** — add endpoint to `openapi/swagger.yaml`; regenerate client.
2. **Feature models** — add entities/exceptions in `features/<feature>/models/`.
3. **Feature repositories** — add interface + implementation in `features/<feature>/repositories/`.
4. **Feature view model** — create a `ChangeNotifier` in `features/<feature>/view_models/`.
5. **Feature views** — build screen widgets in `features/<feature>/views/`; inject repositories/view models via constructor.
6. **Shared UI only** — if the widget is used in both apps, add it to `sakai_shared/widgets/`.

---

## Rules

- **Feature models stay UI-free** — avoid widget concerns inside `models/`.
- **View models coordinate state and actions** — views should not call API clients directly.
- **Views stay declarative** — user interaction delegates to view models.
- **Repository contracts + implementations are side-by-side** in each feature's `repositories/`.
- Regenerate the API client after any `swagger.yaml` change:
  ```sh
  cd shared && dart run build_runner build --delete-conflicting-outputs
  ```
