import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/ride_exception.dart';
import 'ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  RideRepositoryImpl(this._client);

  final SakaiApiClient _client;

  // -------------------------------------------------------------------------
  // RideRepository implementation
  // -------------------------------------------------------------------------

  @override
  Future<RideEntity> requestRide({
    required RideLocation origin,
    required RideLocation destination,
    String? notes,
    required String idempotencyKey,
    VehicleType? rideType,
    String? paymentMethod,
  }) async {
    try {
      debugPrint(
        '[RIDE_REPO] Requesting ride: origin=$origin, destination=$destination, rideType=$rideType',
      );

      // Map VehicleType domain enum to generated API enum
      RideRequestBodyRideTypeEnum? rideTypeEnum;
      if (rideType != null) {
        try {
          rideTypeEnum = RideRequestBodyRideTypeEnum.valueOf(rideType.name);
        } catch (_) {
          rideTypeEnum = RideRequestBodyRideTypeEnum.car;
        }
      }

      // Map string paymentMethod to generated enum
      RideRequestBodyPaymentMethodEnum? paymentMethodEnum;
      if (paymentMethod != null) {
        try {
          paymentMethodEnum = RideRequestBodyPaymentMethodEnum.valueOf(
            paymentMethod,
          );
        } catch (_) {
          paymentMethodEnum = RideRequestBodyPaymentMethodEnum.cash;
        }
      }

      final body = RideRequestBody(
        (b) => b
          ..origin.lat = origin.lat
          ..origin.lng = origin.lng
          ..destination.lat = destination.lat
          ..destination.lng = destination.lng
          ..originAddress = origin.address.isEmpty ? null : origin.address
          ..destinationAddress = destination.address.isEmpty
              ? null
              : destination.address
          ..notes = notes
          ..rideType = rideTypeEnum ?? RideRequestBodyRideTypeEnum.car
          ..paymentMethod =
              paymentMethodEnum ?? RideRequestBodyPaymentMethodEnum.cash,
      );

      debugPrint(
        '[RIDE_REPO] Body: originAddress=${body.originAddress}, destinationAddress=${body.destinationAddress}',
      );

      final response = await _client.getRidesApi().rideRequest(
        idempotencyKey: idempotencyKey,
        rideRequestBody: body,
      );

      final data = response.data;
      if (data == null) {
        throw const RideException(userMessage: 'Empty response from server.');
      }
      debugPrint(
        '[RIDE_REPO] Ride created: ${data.id}, status=${data.status.name}',
      );
      return _toEntity(data);
    } on DioException catch (e) {
      debugPrint(
        '[RIDE_REPO] DioException: ${e.response?.statusCode} ${e.message}',
      );
      throw _fromDio(e);
    }
  }

  @override
  Future<RideEntity?> getActiveRide() async {
    try {
      final response = await _client.getRidesApi().rideGetActive();
      final data = response.data;
      if (data == null) return null;
      return _toEntity(data);
    } on DioException catch (e) {
      // 404 = no active ride — not an error condition
      if (e.response?.statusCode == 404) return null;
      throw _fromDio(e);
    }
  }

  @override
  Future<void> cancelRide(
    String rideId, {
    String? reasonCode,
    String? reasonText,
  }) async {
    debugPrint('[RIDE_REPO] Cancelling ride: $rideId, reasonCode: $reasonCode');
    try {
      CancelRequestReasonCodeEnum code;
      try {
        code = CancelRequestReasonCodeEnum.valueOf(reasonCode ?? 'other');
      } catch (_) {
        code = CancelRequestReasonCodeEnum.other;
      }

      await _client.getRidesApi().rideCancel(
        rideId: rideId,
        cancelRequest: CancelRequest(
          (b) => b
            ..reasonCode = code
            ..reasonText = reasonText,
        ),
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  // -------------------------------------------------------------------------
  // Mapping helpers
  // -------------------------------------------------------------------------
  RideEntity _toEntity(RideResponse r) {
    final driver = r.driver;
    String? driverVehicle;
    if (driver != null) {
      final v = driver.vehicle;
      if (v != null) {
        driverVehicle = '${v.make} ${v.model} · ${v.plate} · ${v.color}';
      }
    }

    return RideEntity(
      id: r.id,
      status: RideState.fromString(r.status.name),
      origin: RideLocation(
        lat: r.origin.lat,
        lng: r.origin.lng,
        address: r.originAddress ?? '',
      ),
      destination: RideLocation(
        lat: r.destination.lat,
        lng: r.destination.lng,
        address: r.destinationAddress ?? '',
      ),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      driverName: driver?.name,
      driverVehicle: driverVehicle,
      cancelledBy: r.cancelledBy?.name,
    );
  }

  RideException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return RideException(
          machineCode: err.code.name,
          userMessage: _friendlyMessage(err.code),
        );
      } catch (_) {
        /* fall through */
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const RideException(
        userMessage: 'Connection timed out. Try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const RideException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }
    return RideException(
      userMessage: e.message ?? 'Something went wrong. Try again.',
    );
  }

  String _friendlyMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.NO_DRIVERS_AVAILABLE:
        return 'No drivers are available right now. Try again in a moment.';
      case ErrorCode.PASSENGER_HAS_ACTIVE_RIDE:
        return 'You already have an active ride.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many requests. Please wait a moment.';
      case ErrorCode.RIDE_INVALID_STATE_TRANSITION:
        return 'This ride cannot be cancelled. It may already be completed or cancelled.';
      default:
        return 'Ride request failed. Please try again.';
    }
  }
}
