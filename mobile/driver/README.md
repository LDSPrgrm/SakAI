# driver

Driver-facing Flutter app. Follows the mobile module-split convention → see [`mobile/README.md`](../README.md).

## Module layout

```
lib/
├── main.dart                              # runApp(DriverApp())
├── app/driver_app.dart                    # MaterialApp, routes
├── domain/
│   └── driver_session.dart               # DriverSession entity (placeholder)
├── data/
│   └── driver_repository_impl.dart        # Stub — ready for auth/WS/location work
└── presentation/
    └── home/
        └── driver_home_screen.dart        # Home placeholder
```

**Status:** Domain and data boundaries are in place. UI is scaffolded.  
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
