# passenger

Rider-facing Flutter app. Follows the mobile module-split convention → see [`mobile/README.md`](../README.md).

## Module layout

```
lib/
├── main.dart                          # Creates AuthRepositoryImpl, calls runApp(PassengerApp)
├── app/passenger_app.dart             # MaterialApp, routes
├── domain/
│   ├── auth_repository.dart           # Abstract AuthRepository port (interface)
│   ├── auth_session.dart              # AuthSession entity
│   └── auth_exception.dart            # Typed domain auth errors
├── data/
│   └── auth_repository_impl.dart      # Calls sakai_api_client, maps → AuthSession
└── presentation/
    ├── auth/
    │   ├── login_screen.dart          # Rider login UI
    │   └── login_view_model.dart      # LoginViewModel (ChangeNotifier)
    └── home/
        └── rider_home_screen.dart     # Home placeholder (post-login)
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
