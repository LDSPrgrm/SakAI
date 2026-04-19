import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide NearbyDriver, ServiceArea, LatLng, VehicleType;
import '../models/service_area.dart';

/// Repository for fetching platform service areas.
///
/// Uses the generated SakaiApiClient for HTTP transport.
class ServiceAreaRepository {
  final SakaiApiClient _client;

  ServiceAreaRepository({SakaiApiClient? client, Interceptor? authInterceptor})
    : _client =
          client ??
          SakaiApiSupport.createClient(authInterceptor: authInterceptor);

  Future<List<ServiceArea>> fetchServiceAreas() async {
    try {
      final response = await _client.getSystemApi().getServiceAreas();

      final data = response.data;
      if (data == null || data.areas == null) {
        return _defaultAreas();
      }

      // The generated ServiceArea model has outdated fields (role/permission
      // schema instead of geographic area schema). After T007 (regenerate
      // Dart client), this mapping will use the correct center/radius fields.
      return data.areas!
          .map(
            (a) => ServiceArea(
              id: a.id,
              name: a.name,
              center: const LatLng(14.5995, 120.9842), // Default Manila
              radius: 15000.0,
            ),
          )
          .toList();
    } catch (e) {
      return _defaultAreas();
    }
  }

  List<ServiceArea> _defaultAreas() {
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
