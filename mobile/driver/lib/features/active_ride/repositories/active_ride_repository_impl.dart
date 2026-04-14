import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'active_ride_repository.dart';

export 'package:sakai_api_client/sakai_api_client.dart' show LatLng;

/// Implementation of [ActiveRideRepository] using the generated API client.
class ActiveRideRepositoryImpl implements ActiveRideRepository {
  final SakaiApiClient _apiClient;

  ActiveRideRepositoryImpl(this._apiClient);

  @override
  Future<RideResponse?> getActiveRide() async {
    try {
      final response = await _apiClient.getRidesApi().rideGetActive();
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      // 2xx = success even if body parsing fails.
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return _rideFromJson(data);
        }
      }
      throw _fromDio(e);
    }
  }

  @override
  Future<void> arriveAtPickup(String rideId, LatLng driverLocation) async {
    try {
      final request = RideArriveRequest((b) {
        b.driverLocation
          ..lat = driverLocation.lat
          ..lng = driverLocation.lng;
      });
      await _apiClient.getRidesApi().rideArrive(
        rideId: rideId,
        rideArriveRequest: request,
      );
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails.
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      throw _fromDio(e);
    }
  }

  @override
  Future<void> startRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideStart(rideId: rideId);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      throw _fromDio(e);
    }
  }

  @override
  Future<void> completeRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideComplete(rideId: rideId);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      throw _fromDio(e);
    }
  }

  @override
  Future<void> cancelRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideCancel(rideId: rideId);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      throw _fromDio(e);
    }
  }

  Exception _fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return Exception('No connection. Check network or server URL.');
    }
    return Exception(e.message ?? 'Something went wrong. Try again.');
  }

  // ── Fallback JSON parsing for when generated client fails on 2xx ───────

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return DateTime.now();
    }
  }

  RideResponse _rideFromJson(Map<String, dynamic> json) {
    // Parse passenger (required by OpenAPI contract)
    final passengerJson = json['passenger'] as Map<String, dynamic>?;
    final passengerRoleStr = passengerJson?['role'] as String?;
    final passengerRole = passengerRoleStr != null
        ? UserProfileRoleEnum.valueOf(passengerRoleStr)
        : UserProfileRoleEnum.passenger;

    // Parse driver (optional)
    final driverJson = json['driver'] as Map<String, dynamic>?;

    // Parse origin/destination coordinates
    final originJson = json['origin'] as Map<String, dynamic>;
    final destinationJson = json['destination'] as Map<String, dynamic>;

    return $RideResponse((b) {
      b
        ..id = json['id'] as String
        ..status = RideStatus.valueOf(json['status'] as String)
        ..passenger = $UserProfile(
          (pb) => pb
            ..id = passengerJson?['id'] as String? ?? ''
            ..name = passengerJson?['name'] as String? ?? 'Unknown'
            ..email = passengerJson?['email'] as String? ?? ''
            ..role = passengerRole
            ..createdAt = _parseDateTime(passengerJson?['created_at']),
        )
        ..driver.id = driverJson?['id'] as String? ?? ''
        ..driver.name = driverJson?['name'] as String? ?? ''
        ..origin.lat = (originJson['lat'] as num).toDouble()
        ..origin.lng = (originJson['lng'] as num).toDouble()
        ..destination.lat = (destinationJson['lat'] as num).toDouble()
        ..destination.lng = (destinationJson['lng'] as num).toDouble()
        ..originAddress = json['origin_address'] as String?
        ..destinationAddress = json['destination_address'] as String?
        ..createdAt = DateTime.parse(json['created_at'] as String)
        ..updatedAt = DateTime.parse(json['updated_at'] as String);

      // Vehicle is nested and optional - only set if present
      final vehicleJson = driverJson?['vehicle'] as Map<String, dynamic>?;
      if (vehicleJson != null) {
        b.driver.vehicle.replace(
          VehicleInfo(
            (vb) => vb
              ..make = vehicleJson['make'] as String?
              ..model = vehicleJson['model'] as String?
              ..color = vehicleJson['color'] as String?
              ..plate = vehicleJson['plate'] as String?,
          ),
        );
      }
    });
  }
}
