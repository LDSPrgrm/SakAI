import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'package:driver/features/home/models/driver_session.dart';
import 'package:driver/features/home/view_models/driver_home_notifier.dart';
import 'package:driver/features/home/repositories/driver_repository.dart';
import 'package:driver/app/providers.dart';

// Mock repository for testing
class _MockDriverRepository implements DriverRepository {
  bool onlineRequested = false;
  bool offlineRequested = false;
  int locationUpdateCount = 0;
  bool shouldFail = false;

  @override
  Future<void> goOnline() async {
    if (shouldFail) throw Exception('Network error');
    onlineRequested = true;
  }

  @override
  Future<void> goOffline() async {
    if (shouldFail) throw Exception('Network error');
    offlineRequested = true;
  }

  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {
    locationUpdateCount++;
  }

  @override
  Future<RideResponse?> getIncomingRide() async {
    return null;
  }
}

void main() {
  group('DriverHomeNotifier', () {
    test('starts offline', () {
      final container = ProviderContainer(
        overrides: [
          driverRepositoryProvider.overrideWithValue(_MockDriverRepository()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(driverHomeNotifierProvider);
      expect(state.online, false);
      expect(state.loading, false);
    });

    test('toggleStatus goes online successfully', () async {
      final mockRepo = _MockDriverRepository();
      final container = ProviderContainer(
        overrides: [driverRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(driverHomeNotifierProvider.notifier).toggleStatus();

      final state = container.read(driverHomeNotifierProvider);
      expect(state.online, true);
      expect(state.loading, false);
      expect(mockRepo.onlineRequested, true);
    });

    test('toggleStatus goes offline successfully', () async {
      final mockRepo = _MockDriverRepository();
      final container = ProviderContainer(
        overrides: [driverRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      // Go online first
      await container.read(driverHomeNotifierProvider.notifier).toggleStatus();
      mockRepo.onlineRequested = false;

      // Now toggle offline
      await container.read(driverHomeNotifierProvider.notifier).toggleStatus();

      final state = container.read(driverHomeNotifierProvider);
      expect(state.online, false);
      expect(state.loading, false);
      expect(mockRepo.offlineRequested, true);
    });

    test('handles error on toggle failure', () async {
      final mockRepo = _MockDriverRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [driverRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(driverHomeNotifierProvider.notifier).toggleStatus();

      final state = container.read(driverHomeNotifierProvider);
      expect(state.online, false);
      expect(state.loading, false);
      expect(state.errorMessage, isNotNull);
    });

    test('clearError removes error message', () async {
      final mockRepo = _MockDriverRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [driverRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      await container.read(driverHomeNotifierProvider.notifier).toggleStatus();
      expect(
        container.read(driverHomeNotifierProvider).errorMessage,
        isNotNull,
      );

      container.read(driverHomeNotifierProvider.notifier).clearError();
      expect(container.read(driverHomeNotifierProvider).errorMessage, isNull);
    });
  });

  group('DriverSession', () {
    test('default values are offline', () {
      const session = DriverSession();
      expect(session.isOnline, false);
      expect(session.status, DriverSessionStatus.offline);
      expect(session.gpsAvailable, false);
      expect(session.currentLocation, isNull);
    });

    test('copyWith updates fields', () {
      const session = DriverSession();
      final updated = session.copyWith(
        isOnline: true,
        status: DriverSessionStatus.online,
        gpsAvailable: true,
      );
      expect(updated.isOnline, true);
      expect(updated.status, DriverSessionStatus.online);
      expect(updated.gpsAvailable, true);
    });
  });
}
