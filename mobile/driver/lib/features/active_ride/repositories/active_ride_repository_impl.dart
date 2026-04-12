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
      throw _fromDio(e);
    }
  }

  @override
  Future<void> arriveAtPickup(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideArrive(rideId: rideId);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> startRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideStart(rideId: rideId);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> completeRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideComplete(rideId: rideId);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> cancelRide(String rideId) async {
    try {
      await _apiClient.getRidesApi().rideCancel(rideId: rideId);
    } on DioException catch (e) {
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
}
