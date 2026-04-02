# driver

Driver-facing Flutter app. Follows feature-first MVVM → see [`mobile/README.md`](../README.md).

## Module layout

```
lib/
├── main.dart                              # runApp(DriverApp())
├── app/driver_app.dart                    # MaterialApp, routes
└── features/home/
    ├── models/driver_session.dart         # DriverSession entity (placeholder)
    ├── repositories/driver_repository_impl.dart
    ├── view_models/driver_home_view_model.dart
    └── views/driver_home_screen.dart
```

**Status:** Feature-first MVVM boundaries are in place. UI is scaffolded.  
**Planned:** driver auth, WebSocket trip-state, GPS location reporting.

## Running

```sh
cd mobile/driver
flutter pub get
flutter run
```

## Dependencies

| Package        | Purpose                                    |
|----------------|--------------------------------------------|
| `sakai_shared` | Shared theme, widgets, generated API client |
