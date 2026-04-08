import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/nearby_driver.dart';

class DriverRepository {
  final Dio _dio;

  DriverRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<NearbyDriver>> fetchNearbyDrivers(LatLng location) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'http://localhost:8081/drivers/nearby',
        queryParameters: {
          'lat': location.latitude,
          'lng': location.longitude,
          'radius': 5000, // 5km radius for display
        },
      );

      final data = response.data;
      if (data == null || data['drivers'] == null) {
        return [];
      }

      final drivers = (data['drivers'] as List)
          .map((d) => NearbyDriver.fromJson(d as Map<String, dynamic>))
          .toList();
          
      return drivers;
    } catch (e) {
      // In case of error or mock server down, return empty to not crash the UI
      return [];
    }
  }
}
