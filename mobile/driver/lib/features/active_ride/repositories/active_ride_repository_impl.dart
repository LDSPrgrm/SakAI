import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'active_ride_repository.dart';

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
  Future<void> arriveAtPickup(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideArrive(rideId: rideId);
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

  RideResponse _rideFromJson(Map<String, dynamic> json) {
    return $RideResponse(
      (b) => b
        ..id = json['id'] as String
        ..status = RideStatus.valueOf(json['status'] as String)
        ..origin.replace(
          LatLng(
            (ob) => ob
              ..lat = (json['origin']['lat'] as num).toDouble()
              ..lng = (json['origin']['lng'] as num).toDouble(),
          ),
        )
        ..destination.replace(
          LatLng(
            (db) => db
              ..lat = (json['destination']['lat'] as num).toDouble()
              ..lng = (json['destination']['lng'] as num).toDouble(),
          ),
        )
        ..originAddress = json['origin_address'] as String?
        ..destinationAddress = json['destination_address'] as String?
        ..createdAt = DateTime.parse(json['created_at'] as String)
        ..updatedAt = DateTime.parse(json['updated_at'] as String),
    );
  }
}
