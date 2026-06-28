import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:driver/features/earnings/models/session_earnings.dart';
import 'package:driver/features/earnings/view_models/earnings_notifier.dart';

void main() {
  group('EarningsNotifier', () {
    test('starts with zero earnings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(earningsNotifierProvider).earnings.completedRidesCount,
        0,
      );
      expect(
        container.read(earningsNotifierProvider).earnings.totalEarnings,
        0.0,
      );
    });

    test('addRide increases count and total', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(earningsNotifierProvider.notifier)
          .addRide(
            rideId: 'ride-1',
            fare: 150.0,
            tip: 20.0,
            completedAt: DateTime.now(),
          );

      final earnings = container.read(earningsNotifierProvider).earnings;
      expect(earnings.completedRidesCount, 1);
      expect(earnings.totalEarnings, 170.0);
    });

    test('addRide accumulates multiple rides', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(earningsNotifierProvider.notifier);

      notifier.addRide(
        rideId: 'ride-1',
        fare: 100.0,
        tip: 10.0,
        completedAt: DateTime.now(),
      );
      notifier.addRide(
        rideId: 'ride-2',
        fare: 200.0,
        tip: 0.0,
        completedAt: DateTime.now(),
      );

      final earnings = container.read(earningsNotifierProvider).earnings;
      expect(earnings.completedRidesCount, 2);
      expect(earnings.totalEarnings, 310.0);
      expect(earnings.rideBreakdowns.length, 2);
    });

    test('reset clears all earnings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(earningsNotifierProvider.notifier);

      notifier.addRide(
        rideId: 'ride-1',
        fare: 100.0,
        completedAt: DateTime.now(),
      );

      notifier.reset();

      final earnings = container.read(earningsNotifierProvider).earnings;
      expect(earnings.completedRidesCount, 0);
      expect(earnings.totalEarnings, 0.0);
    });
  });

  group('SessionEarnings', () {
    test('default values are zero', () {
      const earnings = SessionEarnings();
      expect(earnings.completedRidesCount, 0);
      expect(earnings.totalEarnings, 0.0);
      expect(earnings.rideBreakdowns, isEmpty);
    });

    test('copyWith updates values', () {
      const earnings = SessionEarnings();
      final updated = earnings.copyWith(
        completedRidesCount: 5,
        totalEarnings: 500.0,
      );
      expect(updated.completedRidesCount, 5);
      expect(updated.totalEarnings, 500.0);
    });
  });

  group('RideBreakdown', () {
    test('total is fare plus tip', () {
      final breakdown = RideBreakdown(
        rideId: 'test',
        fare: 100.0,
        tip: 25.0,
        completedAt: DateTime(2026, 4, 12),
      );
      expect(breakdown.total, 125.0);
    });

    test('zero tip works correctly', () {
      final breakdown = RideBreakdown(
        rideId: 'test',
        fare: 100.0,
        completedAt: DateTime(2026, 4, 12),
      );
      expect(breakdown.total, 100.0);
    });
  });
}
