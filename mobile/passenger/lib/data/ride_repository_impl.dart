import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../domain/ride_exception.dart';
import '../domain/ride_repository.dart';

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
  }) async {
    try {
      final body = RideRequestBody((b) => b
        ..origin.lat = origin.lat
        ..origin.lng = origin.lng
        ..destination.lat = destination.lat
        ..destination.lng = destination.lng
        ..originAddress = origin.address.isEmpty ? null : origin.address
        ..destinationAddress =
            destination.address.isEmpty ? null : destination.address
        ..notes = notes);

      final response = await _client.getRidesApi().rideRequest(
            idempotencyKey: idempotencyKey,
            rideRequestBody: body,
          );

      final data = response.data;
      if (data == null) {
        throw const RideException(userMessage: 'Empty response from server.');
      }
      return _toEntity(data);
    } on DioException catch (e) {
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
  Future<void> cancelRide(String rideId) async {
    try {
      await _client.getRidesApi().rideCancel(rideId: rideId);
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
      driverVehicle = '${v.make} ${v.model} · ${v.plate} · ${v.color}';
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
        final err = standardSerializers.deserialize(
          data,
          specifiedType: const FullType(ErrorResponse),
        ) as ErrorResponse;
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
      return const RideException(userMessage: 'Connection timed out. Try again.');
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
      default:
        return 'Ride request failed. Please try again.';
    }
  }
}
