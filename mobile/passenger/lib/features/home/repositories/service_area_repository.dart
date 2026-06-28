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

  Future<List<ServiceArea>> getServiceAreas() async {
    try {
      final response = await _client.getSystemApi().getServiceAreas();

      final data = response.data;
      if (data == null || data.areas == null) {
        return _defaultAreas();
      }

      return data.areas!
          .map(
            (a) => ServiceArea(
              id: a.id,
              name: a.name,
              polygon: a.boundary.polygon
                  .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
                  .toList(),
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
        polygon: const [
          LatLng(14.7, 120.9),
          LatLng(14.7, 121.1),
          LatLng(14.5, 121.1),
          LatLng(14.5, 120.9),
        ],
      ),
    ];
  }
}
