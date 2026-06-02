import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Calls the Google Directions API and returns a decoded polyline.
///
/// Decodes the `overview_polyline` using Google's encoded polyline
/// algorithm so callers receive a ready-to-use `List<LatLng>`.
class DirectionsService {
  DirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Returns the decoded route polyline between [origin] and [destination].
  ///
  /// Returns an empty list on any error so callers can fall back gracefully
  /// (e.g. draw a straight-line polyline or show nothing).
  Future<List<LatLng>> getRoutePolyline({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final apiKey = dotenv.env['MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_google_maps_api_key_here') {
      debugPrint('[DirectionsService] MAPS_API_KEY not configured, falling back to straight line');
      return _straightLine(origin, destination);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': 'driving',
          'key': apiKey,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

      final data = response.data;
      if (data == null) return _straightLine(origin, destination);

      final status = data['status'] as String?;
      if (status != 'OK') {
        debugPrint('[DirectionsService] Directions API status: $status');
        return _straightLine(origin, destination);
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return _straightLine(origin, destination);
      }

      final overviewPolyline =
          (routes.first as Map<String, dynamic>)['overview_polyline']
              as Map<String, dynamic>?;
      final encodedPoints = overviewPolyline?['points'] as String?;
      if (encodedPoints == null || encodedPoints.isEmpty) {
        return _straightLine(origin, destination);
      }

      final points = _decodePolyline(encodedPoints);
      debugPrint(
        '[DirectionsService] Route decoded: ${points.length} points',
      );
      return points;
    } on DioException catch (e) {
      debugPrint('[DirectionsService] DioException: $e');
      return _straightLine(origin, destination);
    } catch (e) {
      debugPrint('[DirectionsService] Unexpected error: $e');
      return _straightLine(origin, destination);
    }
  }

  // ---------------------------------------------------------------------------
  // Fallback
  // ---------------------------------------------------------------------------

  /// Straight-line fallback when Directions API is unavailable or not configured.
  List<LatLng> _straightLine(LatLng origin, LatLng destination) =>
      [origin, destination];

  // ---------------------------------------------------------------------------
  // Google Polyline Decoder (RFC — no third-party dependency needed)
  // ---------------------------------------------------------------------------

  /// Decodes a Google Maps encoded polyline string into a list of [LatLng].
  ///
  /// Algorithm: https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<LatLng> _decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result0 = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);
      lat += dlat;

      // Decode longitude
      shift = 0;
      result0 = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result0 |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result0 & 1) != 0 ? ~(result0 >> 1) : (result0 >> 1);
      lng += dlng;

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return result;
  }
}

/// Computes a [LatLngBounds] that fits all [points] with optional padding.
LatLngBounds boundsFromPoints(List<LatLng> points) {
  assert(points.isNotEmpty);
  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final p in points) {
    minLat = math.min(minLat, p.latitude);
    maxLat = math.max(maxLat, p.latitude);
    minLng = math.min(minLng, p.longitude);
    maxLng = math.max(maxLng, p.longitude);
  }

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}
