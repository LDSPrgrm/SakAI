import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/cancellation/driver_cancel_reason.dart';

void main() {
  group('DriverCancelReason', () {
    test('wire values match the backend taxonomy', () {
      const expected = <String>{
        'passenger_no_show',
        'unsafe_pickup_area',
        'vehicle_issue',
        'passenger_request',
        'other_driver_reason',
        'other',
      };
      final actual = DriverCancelReason.values.map((r) => r.wire).toSet();
      expect(actual, expected);
    });

    test('fromWire round-trips every code', () {
      for (final r in DriverCancelReason.values) {
        expect(DriverCancelReason.fromWire(r.wire), r);
      }
    });

    test('fromWire returns null for unknown wire values', () {
      expect(DriverCancelReason.fromWire('not_a_real_code'), isNull);
    });

    test('ordered list includes every value with `other` last', () {
      expect(DriverCancelReason.ordered.length,
          DriverCancelReason.values.length);
      expect(DriverCancelReason.ordered.last, DriverCancelReason.other);
    });
  });

  group('PassengerCancelReason', () {
    test('wire values match the backend taxonomy', () {
      const expected = <String>{
        'driver_too_far',
        'changed_plans',
        'wrong_pickup',
        'driver_not_moving',
        'safety_concern',
        'other',
      };
      final actual = PassengerCancelReason.values.map((r) => r.wire).toSet();
      expect(actual, expected);
    });

    test('fromWire round-trips every code', () {
      for (final r in PassengerCancelReason.values) {
        expect(PassengerCancelReason.fromWire(r.wire), r);
      }
    });

    test('ordered list ends with `other`', () {
      expect(PassengerCancelReason.ordered.last, PassengerCancelReason.other);
    });
  });
}
