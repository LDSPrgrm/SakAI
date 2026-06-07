import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:sakai_shared/sakai_shared.dart';

/// Data-layer service for converting a free-text address into a [RideLocation].
///
/// Resolution chain (first successful wins):
///   1. Google Maps Geocoding API (requires MAPS_API_KEY)
///   2. Nominatim / OpenStreetMap (free, no key needed)
///   3. Device built-in geocoder (may not work on emulators)
///
/// Usage:
/// ```dart
/// final service = GeocodingService();
/// final loc = await service.geocode('SM Mall of Asia, Pasay');
/// ```
class GeocodingService {
  GeocodingService({Dio? dio})
    : _dio = dio ?? Dio(),
      _nominatimDio = Dio(
        BaseOptions(
          baseUrl: 'https://nominatim.openstreetmap.org',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'User-Agent': 'SakAI-Passenger/1.0'},
        ),
      );

  final Dio _dio;
  final Dio _nominatimDio;

  static const _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';

  String? _apiKey;

  String get apiKey {
    _apiKey ??= const String.fromEnvironment('MAPS_API_KEY').isNotEmpty
        ? const String.fromEnvironment('MAPS_API_KEY')
        : (dotenv.env['MAPS_API_KEY'] ?? '');
    return _apiKey!;
  }

  /// Converts [query] (free-text address) to a [RideLocation].
  ///
  /// Tries Google Maps → Nominatim → Device geocoder, in that order.
  /// Throws [GeocodingException] when address cannot be resolved.
  Future<RideLocation> geocode(String query) async {
    // 1. Try Google Maps API if key is available.
    if (apiKey.isNotEmpty) {
      try {
        return await _geocodeWithGoogle(query);
      } catch (e) {
        debugPrint('[GEOCODE] Google API failed: $e, trying Nominatim');
      }
    }

    // 2. Try Nominatim (OpenStreetMap) — free, no API key.
    try {
      return await _geocodeWithNominatim(query);
    } catch (e) {
      debugPrint('[GEOCODE] Nominatim failed: $e, trying device geocoder');
    }

    // 3. Fallback to device built-in geocoder.
    return _geocodeWithDevice(query);
  }

  Future<RideLocation> _geocodeWithGoogle(String query) async {
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

      final first = (data!['results'] as List).first as Map<String, dynamic>;
      final loc =
          (first['geometry'] as Map<String, dynamic>)['location']
              as Map<String, dynamic>;
      final formattedAddress = first['formatted_address'] as String? ?? query;

      return RideLocation(
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
        address: formattedAddress,
      );
    } on DioException catch (e) {
      throw GeocodingException(_fromDio(e));
    }
  }

  Future<RideLocation> _geocodeWithNominatim(String query) async {
    debugPrint('[GEOCODE] Using Nominatim for: $query');
    final response = await _nominatimDio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': 1,
        'addressdetails': 1,
      },
    );

    final results = response.data;
    if (results == null || results.isEmpty) {
      throw const GeocodingException(
        'Address not found. Try being more specific.',
      );
    }

    final first = results.first as Map<String, dynamic>;
    final lat = double.parse(first['lat'] as String);
    final lng = double.parse(first['lon'] as String);
    final address = first['display_name'] as String? ?? query;

    debugPrint('[GEOCODE] Nominatim found: $address ($lat, $lng)');
    return RideLocation(lat: lat, lng: lng, address: address);
  }

  Future<RideLocation> _geocodeWithDevice(String query) async {
    try {
      debugPrint('[GEOCODE] Using device geocoder for: $query');
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) {
        throw const GeocodingException(
          'Address not found. Try being more specific.',
        );
      }
      final loc = locations.first;
      final placemarks = await geocoding.placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final address = p == null
          ? query
          : [
              p.street,
              p.subLocality,
              p.locality,
            ].where((s) => s != null && s.isNotEmpty).join(', ');

      debugPrint(
        '[GEOCODE] Device geocoder found: $address (${loc.latitude}, ${loc.longitude})',
      );
      return RideLocation(
        lat: loc.latitude,
        lng: loc.longitude,
        address: address,
      );
    } on PlatformException {
      throw const GeocodingException(
        'Address not found. Try being more specific.',
      );
    } catch (e) {
      throw GeocodingException('Could not look up that address: $e');
    }
  }

  /// Converts [lat], [lng] coordinates to a [RideLocation].
  ///
  /// Resolution chain: Google Maps → Nominatim → Device.
  Future<RideLocation> reverseGeocode(double lat, double lng) async {
    // 1. Try Google Maps
    if (apiKey.isNotEmpty) {
      try {
        return await _reverseWithGoogle(lat, lng);
      } catch (e) {
        debugPrint('[GEOCODE] Google Reverse failed: $e, trying Nominatim');
      }
    }

    // 2. Try Nominatim
    try {
      return await _reverseWithNominatim(lat, lng);
    } catch (e) {
      debugPrint('[GEOCODE] Nominatim Reverse failed: $e, trying device');
    }

    // 3. Fallback
    return _reverseWithDevice(lat, lng);
  }

  Future<RideLocation> _reverseWithGoogle(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {'latlng': '$lat,$lng', 'key': apiKey},
      );

      final data = response.data;
      final status = data?['status'] as String?;

      if (status != 'OK' || (data?['results'] as List?)?.isEmpty != false) {
        throw const GeocodingException('Location not recognized.');
      }

      final results = data!['results'] as List;
      final first = results.first as Map<String, dynamic>;
      final formattedAddress =
          first['formatted_address'] as String? ?? 'Unknown Location';

      return RideLocation(lat: lat, lng: lng, address: formattedAddress);
    } on DioException catch (e) {
      throw GeocodingException(_fromDio(e));
    }
  }

  Future<RideLocation> _reverseWithNominatim(double lat, double lng) async {
    final response = await _nominatimDio.get<Map<String, dynamic>>(
      '/reverse',
      queryParameters: {
        'lat': lat,
        'lon': lng,
        'format': 'json',
        'addressdetails': 1,
      },
    );

    final data = response.data;
    if (data == null || data['display_name'] == null) {
      throw const GeocodingException('Location not recognized.');
    }

    return RideLocation(
      lat: lat,
      lng: lng,
      address: data['display_name'] as String,
    );
  }

  Future<RideLocation> _reverseWithDevice(double lat, double lng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) {
        throw const GeocodingException('Location not recognized.');
      }
      final p = placemarks.first;
      final address = [
        p.street,
        p.subLocality,
        p.locality,
      ].where((s) => s != null && s.isNotEmpty).join(', ');

      return RideLocation(
        lat: lat,
        lng: lng,
        address: address.isEmpty ? '($lat, $lng)' : address,
      );
    } catch (e) {
      throw GeocodingException('Could not look up that location: $e');
    }
  }

  /// Fetches place suggestions from Google Places Autocomplete API.
  /// Falls back to Nominatim search when no API key is configured,
  /// so users still get real autocomplete results worldwide.
  Future<List<String>> getSuggestions(
    String input, {
    String? location,
    double? radius,
    bool strictBounds = false,
  }) async {
    if (input.trim().isEmpty) return [];

    // No Google API key → use Nominatim for suggestions.
    if (apiKey.isEmpty) {
      return _suggestWithNominatim(input);
    }

    try {
      final queryParams = <String, dynamic>{'input': input, 'key': apiKey};

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
      return predictions.map((p) => p['description'] as String).toList();
    } catch (e) {
      debugPrint('[GEOCODE] Suggestions error: $e');
      return [];
    }
  }

  /// Uses Nominatim search to provide autocomplete suggestions without API key.
  Future<List<String>> _suggestWithNominatim(String input) async {
    try {
      debugPrint('[GEOCODE] Nominatim suggestions for: $input');
      final response = await _nominatimDio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': input,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
      );

      final results = response.data;
      if (results == null || results.isEmpty) {
        return [];
      }

      // ignore: unnecessary_cast
      return (results as List<dynamic>)
          .map((r) => r['display_name'] as String)
          .toList();
    } catch (e) {
      debugPrint('[GEOCODE] Nominatim suggestions error: $e');
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
