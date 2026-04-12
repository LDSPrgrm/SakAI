import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final SakaiApiClient _apiClient;

  DriverRepositoryImpl(this._apiClient);

  @override
  Future<void> goOnline() async {
    try {
      final request = DriverStatusRequest(
        (b) => b..status = DriverStatusRequestStatusEnum.online,
      );
      await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      final request = DriverStatusRequest(
        (b) => b..status = DriverStatusRequestStatusEnum.offline,
      );
      await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> updateLocation(double lat, double lng, {double? heading}) async {
    try {
      final location = LatLng(
        (b) => b
          ..lat = lat
          ..lng = lng,
      );

      final request = LocationUpdateRequest((b) {
        b.location.replace(location);
        if (heading != null) {
          b.heading = heading;
        }
      });
      await _apiClient.getDriverApi().driverUpdateLocation(
        locationUpdateRequest: request,
      );
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<RideResponse?> getIncomingRide() async {
    try {
      final response = await _apiClient.getDriverApi().driverGetIncomingRide();
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _fromDio(e);
    } catch (_) {
      return null;
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
