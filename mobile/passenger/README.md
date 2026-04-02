# passenger

Rider-facing Flutter app. Follows feature-first MVVM → see [`mobile/README.md`](../README.md).

## Module layout

```
lib/
├── main.dart                          # Creates repositories, calls runApp(PassengerApp)
├── app/passenger_app.dart             # MaterialApp, routes
└── features/
    ├── auth/
    │   ├── models/                    # AuthSession, AuthException
    │   ├── repositories/              # AuthRepository + AuthRepositoryImpl
    │   ├── view_models/               # Login/Register view models
    │   └── views/                     # Login/Register screens
    ├── home/
    │   ├── repositories/              # Geocoding service
    │   ├── view_models/               # Home and destination sheet VMs
    │   └── views/                     # Rider home, activity, profile, sheet
    └── ride/
        ├── models/                    # RideException
        ├── repositories/              # RideRepository + RideRepositoryImpl
        ├── view_models/               # WaitingViewModel
        └── views/                     # WaitingScreen
```

## Running

```sh
cd mobile/passenger
flutter pub get
flutter run
```

## Dependencies

| Package           | Purpose                                    |
|-------------------|--------------------------------------------|
| `sakai_shared`    | Shared theme, widgets, generated API client |
| `built_value`     | Immutable value types (API DTOs)           |
| `dio`             | HTTP client                                |
