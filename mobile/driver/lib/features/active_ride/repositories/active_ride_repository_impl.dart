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
  Future<void> completeRide(String rideId, LatLng driverLocation) async {
    try {
      final request = RideCompleteRequest((b) {
        b.driverLocation
          ..lat = driverLocation.lat
          ..lng = driverLocation.lng;
      });
      await _apiClient.getRidesApi().rideComplete(
        rideId: rideId,
        rideCompleteRequest: request,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> cancelRide(String rideId, {String? reasonText}) async {
    try {
      CancelRequest? body;
      if (reasonText != null && reasonText.isNotEmpty) {
        body = CancelRequest(
          (b) => b
            ..reasonCode = CancelRequestReasonCodeEnum.other
            ..reasonText = reasonText,
        );
      }
      await _apiClient.getRidesApi().rideCancel(
        rideId: rideId,
        cancelRequest: body,
      );
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
