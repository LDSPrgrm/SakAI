import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide NearbyDriver, ServiceArea, LatLng;
import '../models/nearby_driver.dart';

/// Repository for fetching nearby drivers.
///
/// Uses raw Dio for HTTP transport (avoids built_value deserialization issues).
class DriverRepository {
  final SakaiApiClient _client;

  DriverRepository({SakaiApiClient? client, Interceptor? authInterceptor})
    : _client =
          client ??
          SakaiApiSupport.createClient(authInterceptor: authInterceptor);

  /// Fetches nearby drivers for all vehicle types in a single call.
  /// Returns a map of ride type → driver list.
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
                vehicleType: _parseVehicleType(d.vehicleType.toString()),
              ),
            )
            .toList();
      }

      final total = result.values.fold<int>(0, (a, b) => a + b.length);
      debugPrint(
        '[DriverRepository] Fetched $total nearby drivers (car=${result['car']?.length ?? 0}, '
        'motorcycle=${result['motorcycle']?.length ?? 0}, tricycle=${result['tricycle']?.length ?? 0})',
      );
      return result;
    } catch (e, st) {
      debugPrint('DriverRepository.fetchNearbyDriversAll error: $e');
      debugPrint('$st');
      return {};
    }
  }

  VehicleType _parseVehicleType(dynamic raw) {
    if (raw == null) return VehicleType.car;
    final s = raw.toString().toLowerCase();
    if (s.contains('motorcycle')) return VehicleType.motorcycle;
    if (s.contains('tricycle')) return VehicleType.tricycle;
    return VehicleType.car;
  }
}
