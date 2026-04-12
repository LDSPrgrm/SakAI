# passenger

Rider-facing Flutter app for SakAI. Follows feature-first MVVM architecture — see [`mobile/README.md`](../README.md).

## Features

### Ride History & Rebooking

- Chronological list of past rides with pagination and pull-to-refresh
- Filter rides by status (All, Completed, Cancelled)
- Detailed view with route map, timestamps, fare breakdown, and driver details
- One-tap rebooking: pre-fills destination on the home screen for quick re-rides

### Real-time Profile Management

- Displays actual user profile data (name, phone, email, rating) fetched from the backend
- Editable profile form for updating name and phone number
- Loading, error, and retry states with graceful fallbacks

### Cancelled Ride Details

- Dedicated screen showing cancellation reason, timestamp, and who cancelled
- Driver information card (if a driver was assigned)
- Refund/fee breakdown with receipt viewing option

### Receipt Viewing & Sharing

- Professional receipt with full fare breakdown (base fare, distance, time, taxes, fees, discounts)
- Trip summary with passenger, driver, and route information
- Share receipt as image via device's native sharing (share_plus)

### Payment Method Management

- List saved payment methods (cards, e-wallets, cash) with default indicator
- Add new payment methods with type-specific forms
- Set default payment method with one tap
- Remove payment methods with confirmation dialog and undo option

### Settings & Support Pages

- Notification preferences (toggle push notifications)
- Emergency contacts management (add, edit, remove)
- Help Center with FAQs and support contact
- Terms of Service and Privacy Policy viewers
- Language selection

## Module layout

```
lib/
├── main.dart                          # Creates repositories, calls runApp(PassengerApp)
├── app/
│   ├── passenger_app.dart             # MaterialApp, routes
│   ├── router.dart                    # GoRouter route configuration
│   ├── routes.dart                    # Route path constants
│   └── providers.dart                 # Shared repository providers
└── features/
    ├── active_ride/                   # Active ride tracking
    ├── auth/                          # Authentication (login, register, session)
    ├── cancellation/                  # Ride cancellation flow
    ├── cancelled_ride/                # Cancelled ride details screen
    ├── home/                          # Home screen, map, destination sheet
    ├── payment_methods/               # Payment method CRUD
    ├── profile/                       # User profile display & editing
    ├── receipt/                       # Receipt viewing & sharing
    ├── ride/                          # Ride request flow
    ├── ride_complete/                 # Post-ride rating & tip
    ├── ride_history/                  # Ride history list & detail
    └── settings/                      # Settings & support screens
```

## Architecture

The app follows **feature-first MVVM** with Riverpod for state management:

- **Models**: Immutable data classes (value objects, DTOs)
- **Repositories**: API calls, data mapping, error handling (depends on `sakai_shared` API client)
- **View Models**: `ChangeNotifier` / `Notifier` classes that hold UI state and coordinate repositories
- **Views**: Stateless/Stateful widgets that observe ViewModels and render UI

Shared infrastructure:

- `package:sakai_shared` — theme, widgets, generated `SakaiApiClient`, `SakaiApiSupport`
- `flutter_secure_storage` — token persistence
- `go_router` — declarative routing with path parameters
- `flutter_riverpod` — reactive state management

## Running

```sh
cd mobile/passenger
flutter pub get
flutter run
```

### Prerequisites

- Flutter 3.x / Dart 3.10+
- SakAI backend running locally (see `backend/README.md`)
- `.env` file configured with backend URL (see `.env.example`)

## Dependencies

| Package                  | Purpose                                     |
| ------------------------ | ------------------------------------------- |
| `sakai_shared`           | Shared theme, widgets, generated API client |
| `sakai_api_client`       | Generated OpenAPI Dart client               |
| `flutter_riverpod`       | Reactive state management                   |
| `go_router`              | Declarative routing                         |
| `built_value`            | Immutable value types (API DTOs)            |
| `dio`                    | HTTP client (used by api_client)            |
| `flutter_secure_storage` | Secure token persistence                    |
| `shared_preferences`     | Local non-sensitive preferences             |
| `share_plus`             | Native sharing (receipts)                   |
| `path_provider`          | Temp directory access (share images)        |
| `geolocator`             | Device location                             |
| `geocoding`              | Address geocoding                           |
| `google_maps_flutter`    | Map display                                 |
| `flutter_dotenv`         | Environment variable loading                |
| `webview_flutter`        | In-app web views (terms, privacy)           |
| `uuid`                   | UUID generation (idempotency keys)          |

## Testing

```sh
# Unit and widget tests
flutter test

# Static analysis
flutter analyze

# Run with coverage (requires lcov)
flutter test --coverage
```

## Environment Configuration

Create a `.env` file in this directory (copy from `.env.example`):

```
API_BASE_URL=http://localhost:8080/api
WS_BASE_URL=ws://localhost:8080/ws
```
