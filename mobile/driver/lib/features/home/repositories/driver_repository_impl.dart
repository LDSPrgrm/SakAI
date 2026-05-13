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
      debugPrint('[DRIVER_REPO] Request: $request');
      final response = await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
      debugPrint('[DRIVER_REPO] goOnline success: ${response.data}');
    } on DioException catch (e) {
      debugPrint('[DRIVER_REPO] goOnline DioException: ${e.response?.statusCode}');
      debugPrint('[DRIVER_REPO] Message: ${e.message}');
      debugPrint('[DRIVER_REPO] Error type: ${e.type}');
      debugPrint('[DRIVER_REPO] Error details: ${e.error}');
      debugPrint('[DRIVER_REPO] Response data: ${e.response?.data}');
      throw _fromDio(e);
    } catch (e, stack) {
      debugPrint('[DRIVER_REPO] goOnline unexpected error: $e');
      debugPrint('[DRIVER_REPO] Stacktrace: $stack');
      rethrow;
    }
  }

  @override
  Future<void> goOffline() async {
    try {
      debugPrint('[DRIVER_REPO] Calling PUT /driver/status → offline');
      final request = DriverStatusRequest(
        (b) => b..status = DriverStatusRequestStatusEnum.offline,
      );
      debugPrint('[DRIVER_REPO] Request: $request');
      final response = await _apiClient.getDriverApi().driverSetStatus(
        driverStatusRequest: request,
      );
      debugPrint('[DRIVER_REPO] goOffline success: ${response.data}');
    } on DioException catch (e) {
      debugPrint('[DRIVER_REPO] goOffline DioException: ${e.response?.statusCode}');
      debugPrint('[DRIVER_REPO] Message: ${e.message}');
      debugPrint('[DRIVER_REPO] Error details: ${e.error}');
      debugPrint('[DRIVER_REPO] Response data: ${e.response?.data}');
      throw _fromDio(e);
    } catch (e, stack) {
      debugPrint('[DRIVER_REPO] goOffline unexpected error: $e');
      debugPrint('[DRIVER_REPO] Stacktrace: $stack');
      rethrow;
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
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as String?;
      final message = data['message'] as String?;
      if (code == 'DRIVER_HAS_ACTIVE_RIDE') {
        return Exception(
          'Cannot go offline — you have an active ride. Complete or cancel it first.',
        );
      }
      if (message != null && message.isNotEmpty) {
        return Exception(message);
      }
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return Exception('No connection. Check network or server URL.');
    }
    return Exception(e.message ?? 'Something went wrong. Try again.');
  }
}
