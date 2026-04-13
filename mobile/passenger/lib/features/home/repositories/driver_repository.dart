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

  Future<List<NearbyDriver>> fetchNearbyDrivers(
    LatLng location, {
    String rideType = 'car',
  }) async {
    try {
      final resp = await _client.dio.get(
        '/drivers/nearby',
        queryParameters: {
          'lat': location.latitude,
          'lng': location.longitude,
          'ride_type': rideType,
          'radius_m': 5000,
        },
      );

      final data = resp.data;
      debugPrint(
        '[DriverRepository] rideType=$rideType, response type: ${data.runtimeType}',
      );

      if (data == null) {
        return [];
      }

      // Backend returns: { "data": [ {...driver...}, ... ] }
      // where "data" is a list of NearbyDriver structs
      List<dynamic>? driversList;

      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is List) {
          driversList = inner;
        } else if (inner is Map<String, dynamic> && inner['drivers'] is List) {
          driversList = inner['drivers'] as List;
        }
      } else if (data is List) {
        driversList = data;
      }

      if (driversList == null || driversList.isEmpty) {
        debugPrint('[DriverRepository] rideType=$rideType, 0 drivers');
        return [];
      }

      debugPrint(
        '[DriverRepository] rideType=$rideType, found ${driversList.length} drivers',
      );

      return driversList.map((d) {
        final m = d as Map<String, dynamic>;
        // The backend NearbyDriver now has: id, name, vehicle_make, vehicle_model,
        // vehicle_plate, vehicle_type, rating, distance_m, location (lat/lng), heading
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
    } catch (e, st) {
      debugPrint('DriverRepository.fetchNearbyDrivers error: $e');
      debugPrint('$st');
      return [];
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
