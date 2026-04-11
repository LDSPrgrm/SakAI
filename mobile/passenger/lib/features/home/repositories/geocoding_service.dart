import 'package:dio/dio.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Data-layer service for converting a free-text address into a [RideLocation].
///
/// Pure Dart — no Flutter/widget dependencies.
///
/// Usage:
/// ```dart
/// final service = GeocodingService();
/// final loc = await service.geocode('SM Mall of Asia, Pasay');
/// ```
class GeocodingService {
  GeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  /// Converts [query] (free-text address) to a [RideLocation].
  ///
  /// Throws [GeocodingException] on:
  ///   - missing API key
  ///   - address not found
  ///   - network / timeout errors
  Future<RideLocation> geocode(String query) async {
    const apiKey = String.fromEnvironment('MAPS_API_KEY');

    if (apiKey.isEmpty) {
      throw const GeocodingException(
        'Configuration Error: Missing MAPS_API_KEY. '
        'Did you run via run-mobile.sh?',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {'address': query, 'key': apiKey},
      );

      final data = response.data;
      final status = data?['status'] as String?;

      if (status != 'OK' || (data?['results'] as List?)?.isEmpty != false) {
        throw const GeocodingException(
          'Address not found. Try being more specific.',
        );
      }

      final first =
          (data!['results'] as List).first as Map<String, dynamic>;
      final loc =
          (first['geometry'] as Map<String, dynamic>)['location']
              as Map<String, dynamic>;
      final formattedAddress =
          first['formatted_address'] as String? ?? query;

      return RideLocation(
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        address: formattedAddress,
      );
    } on DioException catch (e) {
      throw GeocodingException(_fromDio(e));
    }
  }

  /// Fetches place suggestions from Google Places Autocomplete API.
  Future<List<String>> getSuggestions(
    String input, {
    String? location,
    double? radius,
    bool strictBounds = false,
  }) async {
    const apiKey = String.fromEnvironment('MAPS_API_KEY');

    if (apiKey.isEmpty || input.trim().isEmpty) {
      return [];
    }

    try {
      final queryParams = <String, dynamic>{
        'input': input,
        'key': apiKey,
      };

      if (location != null && radius != null) {
        queryParams['location'] = location;
        queryParams['radius'] = radius.toString();
        if (strictBounds) {
          queryParams['strictbounds'] = 'true';
        }
      }

      final response = await _dio.get<Map<String, dynamic>>(
        _autocompleteUrl,
        queryParameters: queryParams,
      );

      final data = response.data;
      final status = data?['status'] as String?;

      if (status != 'OK') {
        return [];
      }

      final predictions = data!['predictions'] as List;
      return predictions
          .map((p) => p['description'] as String)
          .toList();
    } catch (e) {
      // Fail silently for suggestions
      return [];
    }
  }

  String _fromDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No connection. Check your network.';
    }
    return 'Could not look up that address. Try again.';
  }
}

/// Thrown by [GeocodingService] when geocoding fails.
class GeocodingException implements Exception {
  const GeocodingException(this.message);
  final String message;

  @override
  String toString() => 'GeocodingException: $message';
}
