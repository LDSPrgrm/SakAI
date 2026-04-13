import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  final SakaiApiClient _apiClient;

  DriverRepositoryImpl(this._apiClient);

  @override
  Future<void> goOnline() async {
    try {
      debugPrint('[DRIVER_REPO] Calling PUT /driver/status → online');
      final request = DriverStatusRequest(
        (b) => b..status = DriverStatusRequestStatusEnum.online,
      );
      await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
      debugPrint('[DRIVER_REPO] goOnline success');
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails.
      if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 200 &&
          e.response!.statusCode! < 300) {
        debugPrint('[DRIVER_REPO] goOnline success (2xx, body parse issue)');
        return;
      }
      debugPrint(
        '[DRIVER_REPO] goOnline failed: ${e.response?.statusCode} ${e.message}',
      );
      throw _fromDio(e);
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      debugPrint('[DRIVER_REPO] Calling PUT /driver/status → offline');
      final request = DriverStatusRequest(
        (b) => b..status = DriverStatusRequestStatusEnum.offline,
      );
      await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
      debugPrint('[DRIVER_REPO] goOffline success');
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails.
      if (e.response?.statusCode != null &&
          e.response!.statusCode! >= 200 &&
          e.response!.statusCode! < 300) {
        debugPrint('[DRIVER_REPO] goOffline success (2xx, body parse issue)');
        return;
      }
      debugPrint(
        '[DRIVER_REPO] goOffline failed: ${e.response?.statusCode} ${e.message}',
      );
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
      debugPrint(
        '[DRIVER_REPO] updateLocation failed: ${e.response?.statusCode} ${e.message}',
      );
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
