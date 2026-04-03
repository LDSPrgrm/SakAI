import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/repositories/auth_repository_impl.dart';
import '../features/ride/repositories/ride_repository.dart';
import '../features/ride/repositories/ride_repository_impl.dart';

/// Shared HTTP client — single instance per app lifetime.
final apiClientProvider = Provider<SakaiApiClient>((ref) {
  return SakaiApiSupport.createClient();
});

/// Auth repository — domain boundary over the generated API client.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(apiClientProvider));
});

/// Ride repository — domain boundary over the generated API client.
final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl(ref.watch(apiClientProvider));
});
