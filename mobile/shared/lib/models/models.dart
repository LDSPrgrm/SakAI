/// Shared domain models for SakAI mobile apps.
///
/// These wrap the generated API client types to provide a clean, stable
/// domain layer that does not change when the OpenAPI spec is regenerated.
library;

export 'user.dart';
export 'ride.dart';
export 'driver.dart';
export 'vehicle.dart';
export 'error_response.dart';

// Core shared entities used across passenger and driver apps.
export 'ride_location.dart';
export 'ride_entity.dart';
export 'ride_type_selection.dart';
export 'driver_rating_state.dart';
