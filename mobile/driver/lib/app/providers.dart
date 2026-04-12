import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/driver_auth_repository.dart';
import '../features/auth/repositories/driver_auth_repository_impl.dart';
import '../features/home/repositories/driver_repository.dart';
import '../features/home/repositories/driver_repository_impl.dart';
import '../features/home/services/gps_location_service.dart';
import '../features/active_ride/repositories/active_ride_repository.dart';
import '../features/active_ride/repositories/active_ride_repository_impl.dart';

/// Shared HTTP client — single instance per app lifetime.
final apiClientProvider = Provider<SakaiApiClient>((ref) {
  return SakaiApiSupport.createClient();
});

/// Auth repository — domain boundary over the generated API client.
final authRepositoryProvider = Provider<DriverAuthRepository>((ref) {
  return DriverAuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Driver repository — domain boundary for driver status and location.
final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepositoryImpl(ref.watch(apiClientProvider));
});

/// Active ride repository — domain boundary for ride state transitions.
final activeRideRepositoryProvider = Provider<ActiveRideRepository>((ref) {
  return ActiveRideRepositoryImpl(ref.watch(apiClientProvider));
});

/// WebSocket client singleton for real-time events.
final wsClientProvider = Provider<WsClient>((ref) {
  return WsClient();
});

/// GPS location service singleton.
final gpsLocationServiceProvider = Provider<GpsLocationService>((ref) {
  return GpsLocationService();
});
