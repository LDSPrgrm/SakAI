import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'package:driver/features/active_ride/models/active_ride_step.dart';
import 'package:driver/features/active_ride/view_models/active_ride_notifier.dart';

void main() {
  group('ActiveRideState', () {
    test('mapStatusToStep maps accepted to enRoute', () {
      expect(
        ActiveRideState.mapStatusToStep(RideStatus.accepted),
        ActiveRideStep.enRoute,
      );
    });

    test('mapStatusToStep maps arrived to arrived', () {
      expect(
        ActiveRideState.mapStatusToStep(RideStatus.arrived),
        ActiveRideStep.arrived,
      );
    });

    test('mapStatusToStep maps inProgress to inProgress', () {
      expect(
        ActiveRideState.mapStatusToStep(RideStatus.inProgress),
        ActiveRideStep.inProgress,
      );
    });

    test('mapStatusToStep defaults unknown to enRoute', () {
      expect(
        ActiveRideState.mapStatusToStep(RideStatus.completed),
        ActiveRideStep.enRoute,
      );
      expect(
        ActiveRideState.mapStatusToStep(RideStatus.cancelled),
        ActiveRideStep.enRoute,
      );
    });

    test('copyWith updates fields', () {
      const state = ActiveRideState(
        currentStep: ActiveRideStep.enRoute,
        isTransitioning: false,
      );

      final updated = state.copyWith(
        currentStep: ActiveRideStep.arrived,
        isTransitioning: true,
        errorMessage: 'Test error',
      );

      expect(updated.currentStep, ActiveRideStep.arrived);
      expect(updated.isTransitioning, true);
      expect(updated.errorMessage, 'Test error');
    });
  });
}
