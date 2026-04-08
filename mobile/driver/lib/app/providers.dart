import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/driver_auth_repository.dart';
import '../features/auth/repositories/driver_auth_repository_impl.dart';
import '../features/home/repositories/driver_repository.dart';
import '../features/home/repositories/driver_repository_impl.dart';

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
