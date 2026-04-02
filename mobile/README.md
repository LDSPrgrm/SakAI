# Mobile — Module Split (Passenger + Driver)

Both apps follow **Clean Architecture + MVVM** and are structured identically inside `lib/`.

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

Each app's `lib/` is split into four layers:

```
lib/
├── main.dart                 # Entry point — wires DI, calls runApp()
├── app/                      # App root (MaterialApp, router, DI composition)
├── domain/                   # Entities + repository interfaces (pure Dart — NO Flutter/networking imports)
├── data/                     # Repository implementations, DTO mapping, API calls
└── presentation/             # Screens + ViewModels (MVVM via ChangeNotifier)
    └── <feature>/
        ├── <feature>_screen.dart
        └── <feature>_view_model.dart
```

### Layer responsibilities

| Layer            | What lives here                                                           | Must NOT import            |
|------------------|---------------------------------------------------------------------------|----------------------------|
| `domain/`        | Entities (`*Session`, `*Exception`), abstract repository interfaces       | Flutter, `dio`, any `data/`|
| `data/`          | `*RepositoryImpl` — calls generated API client, maps DTOs to domain types | `presentation/`            |
| `presentation/`  | Widgets/screens + ViewModels (`ChangeNotifier`)                           | `data/` directly           |
| `app/`           | `MaterialApp`, route table, DI wiring (passes repos into ViewModels)      | business logic             |

---

## passenger (`mobile/passenger`)

**Current state:** Auth flow is fully implemented end-to-end.

```
lib/
├── main.dart                            # Creates AuthRepositoryImpl via sakai_shared client, runApp
├── app/passenger_app.dart               # MaterialApp + named routes
├── domain/
│   ├── auth_repository.dart             # Abstract AuthRepository port
│   ├── auth_session.dart                # AuthSession entity (token, userId, …)
│   └── auth_exception.dart             # Typed domain errors from auth failures
├── data/
│   └── auth_repository_impl.dart        # Calls generated OpenAPI client, maps → AuthSession
└── presentation/
    ├── auth/
    │   ├── login_screen.dart            # Rider login UI
    │   └── login_view_model.dart        # LoginViewModel (ChangeNotifier, calls AuthRepository)
    └── home/
        └── rider_home_screen.dart       # Post-login home placeholder
```

**Key dependency:** `sakai_shared` (theme + generated `SakaiApiClient`), `built_value`, `dio`.

---

## driver (`mobile/driver`)

**Current state:** Scaffold in place; UI-only with domain/data boundaries ready for future work.

```
lib/
├── main.dart                            # runApp(DriverApp())
├── app/driver_app.dart                  # MaterialApp + routes
├── domain/
│   └── driver_session.dart             # DriverSession entity (placeholder)
├── data/
│   └── driver_repository_impl.dart      # Stub — ready for auth/WS/location integration
└── presentation/
    └── home/
        └── driver_home_screen.dart      # Driver home placeholder
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
2. **Domain layer** — add entity + abstract repository interface in `domain/`; no external imports.
3. **Data layer** — implement repository in `data/` using the generated `sakai_api_client`.
4. **Presentation layer** — create ViewModel (`ChangeNotifier`) + screen widget in `presentation/<feature>/`.
5. **Wire it up** — inject repository → ViewModel in `app/` (constructor injection via `main.dart`).
6. **Shared UI only** — if the widget is used in both apps, add it to `sakai_shared/widgets/`.

---

## Rules

- **`domain/` must stay pure Dart** — no `package:flutter`, no `package:dio`.
- **ViewModels must not import `data/`** directly — only `domain/` interfaces (injected via constructor).
- **Screens must not call repositories** — go through the ViewModel.
- Regenerate the API client after any `swagger.yaml` change:
  ```sh
  cd shared && dart run build_runner build --delete-conflicting-outputs
  ```
