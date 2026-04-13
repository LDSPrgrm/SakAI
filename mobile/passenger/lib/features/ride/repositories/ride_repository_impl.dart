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
          ..rideType = rideTypeEnum
          ..paymentMethod = paymentMethodEnum,
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
      debugPrint('[RIDE_REPO] Response data: ${e.response?.data}');
      // 2xx = success even if body parsing fails (generated client bug).
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          debugPrint('[RIDE_REPO] Ride created via fallback');
          return _entityFromJson(data);
        }
      }
      throw _fromDio(e);
    }
  }

  /// Manually parses a raw JSON map into a [RideEntity].
  RideEntity _entityFromJson(Map<String, dynamic> json) {
    final originData = json['origin'] as Map<String, dynamic>;
    final destData = json['destination'] as Map<String, dynamic>;
    final driverData = json['driver'] as Map<String, dynamic>?;

    String? driverVehicle;
    if (driverData != null) {
      final v = driverData['vehicle'] as Map<String, dynamic>?;
      if (v != null) {
        driverVehicle =
            '${v['make']} ${v['model']} · ${v['plate']} · ${v['color']}';
      }
    }

    return RideEntity(
      id: json['id'] as String,
      status: RideState.fromString(json['status'] as String),
      origin: RideLocation(
        lat: (originData['lat'] as num).toDouble(),
        lng: (originData['lng'] as num).toDouble(),
        address: json['origin_address'] as String? ?? '',
      ),
      destination: RideLocation(
        lat: (destData['lat'] as num).toDouble(),
        lng: (destData['lng'] as num).toDouble(),
        address: json['destination_address'] as String? ?? '',
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      driverName: driverData?['name'] as String?,
      driverVehicle: driverVehicle,
      cancelledBy: null,
    );
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
      // 2xx = success even if body parsing fails (generated client bug).
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) return _entityFromJson(data);
      }
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
      // Send cancellation request with reason_code and reason_text directly
      // using Dio to bypass stale generated CancelRequest model
      final dio = _client.dio;
      final response = await dio.post(
        '/rides/$rideId/cancel',
        data: <String, dynamic>{
          'reason_code': reasonCode,
          // ignore: use_null_aware_elements
          if (reasonText != null) 'reason_text': reasonText,
        },
      );
      debugPrint(
        '[RIDE_REPO] Cancel ride succeeded (HTTP ${response.statusCode})',
      );
      if (response.data != null) {
        debugPrint(
          '[RIDE_REPO] Cancelled ride status: ${response.data['status']}',
        );
      }
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails (generated client bug).
      if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 200 &&
          e.response!.statusCode! < 300) {
        debugPrint(
          '[RIDE_REPO] Cancel ride succeeded (2xx, parsing error ignored)',
        );
        return;
      }
      debugPrint(
        '[RIDE_REPO] Cancel ride failed (Dio): ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.data != null) {
        debugPrint('[RIDE_REPO] Error body: ${e.response?.data}');
      }
      throw _fromDio(e);
    } catch (e, st) {
      debugPrint('[RIDE_REPO] Cancel ride failed (Unexpected): $e');
      debugPrint('[RIDE_REPO] Stack: $st');
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Mapping helpers
  // -------------------------------------------------------------------------

  /// Manually parses a raw JSON map into a [RideResponse] when the
  /// generated client fails to deserialize 2xx responses.
  // ignore: unused_element
  RideResponse _parseRideResponse(Map<String, dynamic> json) {
    return $RideResponse((b) {
      b.id = json['id'] as String;

      final statusStr = json['status'] as String;
      try {
        b.status = RideStatus.valueOf(statusStr);
      } catch (_) {
        b.status = RideStatus.requested;
      }

      final originData = json['origin'] as Map<String, dynamic>;
      b.origin.lat = (originData['lat'] as num).toDouble();
      b.origin.lng = (originData['lng'] as num).toDouble();

      final destData = json['destination'] as Map<String, dynamic>;
      b.destination.lat = (destData['lat'] as num).toDouble();
      b.destination.lng = (destData['lng'] as num).toDouble();

      b.originAddress = json['origin_address'] as String?;
      b.destinationAddress = json['destination_address'] as String?;
      b.createdAt = DateTime.parse(json['created_at'] as String);
      b.updatedAt = DateTime.parse(json['updated_at'] as String);

      // Passenger is required by the schema but may be missing in 2xx responses
      final passengerData = json['passenger'] as Map<String, dynamic>?;
      b.passenger = $UserProfile((pb) {
        pb.id = passengerData != null ? passengerData['id'] as String : '';
        pb.name = passengerData != null
            ? (passengerData['name'] as String? ?? '')
            : '';
      });
    });
  }

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
