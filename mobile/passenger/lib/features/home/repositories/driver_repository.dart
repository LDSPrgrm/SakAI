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
      final resp = await _client.dio.get(
        '/drivers/nearby/all',
        queryParameters: {
          'lat': location.latitude,
          'lng': location.longitude,
          'radius_m': 5000,
        },
      );

      final data = resp.data;
      if (data == null) return {};

      final outer = data is Map<String, dynamic> ? data['data'] : null;
      if (outer is! Map<String, dynamic>) return {};

      final result = <String, List<NearbyDriver>>{};
      for (final entry in outer.entries) {
        final driversList = entry.value is List ? entry.value as List : [];
        result[entry.key] = driversList.map((d) {
          final m = d as Map<String, dynamic>;
          final loc = m['location'] as Map<String, dynamic>? ?? {};
          return NearbyDriver(
            id: m['id'] as String? ?? '',
            name: m['name'] as String? ?? 'Driver',
            location: LatLng(
              (loc['lat'] as num?)?.toDouble() ?? 0.0,
              (loc['lng'] as num?)?.toDouble() ?? 0.0,
            ),
            heading: (m['heading'] as num?)?.toDouble() ?? 0.0,
            vehicleType: _parseVehicleType(m['vehicle_type']),
          );
        }).toList();
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
