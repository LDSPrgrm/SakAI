import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide NearbyDriver, ServiceArea, LatLng;
import '../models/nearby_driver.dart';

/// Repository for fetching nearby drivers.
class DriverRepository {
  final SakaiApiClient _client;

  DriverRepository({SakaiApiClient? client, Interceptor? authInterceptor})
    : _client =
          client ??
          SakaiApiSupport.createClient(authInterceptor: authInterceptor);

  /// Fetches nearby drivers for all vehicle types in a single call.
  Future<Map<String, List<NearbyDriver>>> fetchNearbyDriversAll(
    LatLng location,
  ) async {
    try {
      final response = await _client.getDriverApi().getNearbyDriversAllTypes(
        lat: location.latitude,
        lng: location.longitude,
        radiusM: 5000,
      );

      final data = response.data;
      if (data == null) return {};

      final result = <String, List<NearbyDriver>>{};
      for (final entry in data.entries) {
        final driversList = entry.value;
        result[entry.key] = driversList
            .map(
              (d) => NearbyDriver(
                id: d.id,
                name: d.name,
                location: LatLng(d.location.lat, d.location.lng),
                heading: d.heading ?? 0.0,
                vehicleType: _mapVehicleType(d.vehicleType),
              ),
            )
            .toList();
      }
      return result;
    } on DioException catch (e) {
      debugPrint('[DriverRepository] DioException: ${e.response?.statusCode} ${e.message}');
      return {};
    } catch (e, st) {
      debugPrint('[DriverRepository] Unexpected error: $e\n$st');
      return {};
    }
  }

  VehicleType _mapVehicleType(NearbyDriverVehicleTypeEnum? type) {
    if (type == null) return VehicleType.car;
    switch (type) {
      case NearbyDriverVehicleTypeEnum.motorcycle:
        return VehicleType.motorcycle;
      case NearbyDriverVehicleTypeEnum.tricycle:
        return VehicleType.tricycle;
      case NearbyDriverVehicleTypeEnum.car:
      default:
        return VehicleType.car;
    }
  }
}
