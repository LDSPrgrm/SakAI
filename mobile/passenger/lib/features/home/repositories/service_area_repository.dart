import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/service_area.dart';

class ServiceAreaRepository {
  final Dio _dio;

  ServiceAreaRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<ServiceArea>> fetchServiceAreas() async {
    try {
      // For local development with mock server:
      // In production, this would use the real API_URL from environment
      final response = await _dio.get<Map<String, dynamic>>(
        'http://localhost:8081/service-area',
      );

      final data = response.data;
      if (data == null || data['areas'] == null) {
        return [];
      }

      final areas = (data['areas'] as List)
          .map((a) => ServiceArea.fromJson(a as Map<String, dynamic>))
          .toList();
          
      return areas;
    } catch (e) {
      // Fallback to defaults or handle error
      return [
        ServiceArea(
          id: 'default-manila',
          name: 'Metro Manila (Default)',
          center: const LatLng(14.5995, 120.9842),
          radius: 15000.0, // 15km
        ),
      ];
    }
  }
}
