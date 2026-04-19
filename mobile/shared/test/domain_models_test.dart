import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('DomainErrorResponse', () {
    test('maps INVALID_CREDENTIALS to user-friendly message', () {
      final error = DomainErrorResponse(
        code: ErrorCode.INVALID_CREDENTIALS,
        message: 'wrong password',
      );
      expect(error.displayMessage, 'Invalid email or password.');
    });

    test('maps EMAIL_ALREADY_REGISTERED to user-friendly message', () {
      final error = DomainErrorResponse(
        code: ErrorCode.EMAIL_ALREADY_REGISTERED,
        message: 'email taken',
      );
      expect(
        error.displayMessage,
        'An account with this email already exists.',
      );
    });

    test('maps FORBIDDEN to user-friendly message', () {
      final error = DomainErrorResponse(
        code: ErrorCode.FORBIDDEN,
        message: 'not allowed',
      );
      expect(
        error.displayMessage,
        'You do not have permission to perform this action.',
      );
    });

    test('maps NO_DRIVERS_AVAILABLE to user-friendly message', () {
      final error = DomainErrorResponse(
        code: ErrorCode.NO_DRIVERS_AVAILABLE,
        message: 'no drivers',
      );
      expect(
        error.displayMessage,
        'No drivers available right now. Please try again.',
      );
    });

    test('maps RATE_LIMIT_EXCEEDED to user-friendly message', () {
      final error = DomainErrorResponse(
        code: ErrorCode.RATE_LIMIT_EXCEEDED,
        message: 'slow down',
      );
      expect(
        error.displayMessage,
        'Too many requests. Please wait and try again.',
      );
    });

    test('falls back to original message for unknown codes', () {
      final error = DomainErrorResponse(
        code: ErrorCode.INTERNAL_SERVER_ERROR,
        message: 'something broke',
      );
      expect(error.displayMessage, 'something broke');
    });
  });

  group('DomainUser', () {
    test('fromApi extracts fields from UserProfile', () {
      final profile = $UserProfile(
        (UserProfileBuilder b) => b
          ..id = 'user-1'
          ..name = 'Alice'
          ..email = 'alice@test.com'
          ..role = UserProfileRoleEnum.passenger
          ..createdAt = DateTime.now(),
      );

      final user = DomainUser.fromApi(profile);

      expect(user.id, 'user-1');
      expect(user.name, 'Alice');
      expect(user.email, 'alice@test.com');
      expect(user.role, 'passenger');
    });

    test('fromApi extracts driver role', () {
      final profile = $UserProfile(
        (UserProfileBuilder b) => b
          ..id = 'user-2'
          ..name = 'Bob'
          ..email = 'bob@test.com'
          ..role = UserProfileRoleEnum.driver
          ..createdAt = DateTime.now(),
      );

      final user = DomainUser.fromApi(profile);
      expect(user.role, 'driver');
    });
  });

  group('DomainDriver', () {
    test('fromApi extracts name from DriverSummary', () {
      final summary = DriverSummary((b) {
        b.id = 'driver-1';
        b.name = 'Charlie';
        b.vehicle.make = 'Toyota';
        b.vehicle.model = 'Camry';
        b.vehicle.color = 'White';
        b.vehicle.plate = 'ABC 123';
      });

      final driver = DomainDriver.fromApi(summary);

      expect(driver.id, 'driver-1');
      expect(driver.name, 'Charlie');
      expect(driver.vehicle, isNotNull);
      expect(driver.vehicle!.make, 'Toyota');
      expect(driver.vehicle!.model, 'Camry');
      expect(driver.vehicle!.color, 'White');
      expect(driver.vehicle!.plate, 'ABC 123');
    });
  });

  group('WsEvent', () {
    test('parses event from message map', () {
      final message = {
        'event': 'ride.accepted',
        'payload': <String, dynamic>{'ride_id': 'r1'},
      };

      final event = WsEvent.fromMessage(message);

      expect(event.type, 'ride.accepted');
      expect(event.payload['ride_id'], 'r1');
    });

    test('handles missing payload gracefully', () {
      final message = {'event': 'ride.cancelled'};

      final event = WsEvent.fromMessage(message);

      expect(event.type, 'ride.cancelled');
      expect(event.payload, isEmpty);
    });
  });

  group('WsEventNames', () {
    test('all expected event names are defined', () {
      expect(WsEventNames.rideAccepted, 'ride.accepted');
      expect(WsEventNames.rideDeclined, 'ride.declined');
      expect(WsEventNames.rideOfferExpired, 'ride.offer_expired');
      expect(WsEventNames.rideArrived, 'ride.arrived');
      expect(WsEventNames.rideStatusChanged, 'ride.status_changed');
      expect(WsEventNames.rideCancelled, 'ride.cancelled');
      expect(WsEventNames.driverLocationUpdated, 'driver.location_updated');
    });
  });
}
