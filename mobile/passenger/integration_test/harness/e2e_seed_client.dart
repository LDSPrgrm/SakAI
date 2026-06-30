import 'dart:convert';
import 'dart:io';

/// One-shot client for the backend's POST /api/e2e/seed endpoint. The
/// endpoint exists only when the deploy sets E2E_ENABLED=true and
/// E2E_SEED_TOKEN matches the value we send here — both passed in via
/// --dart-define from the integration test runner.
///
/// Returns the fixture bundle the test then uses to drive a deterministic
/// passenger + driver + ride. Throws if the endpoint is disabled, the
/// token is wrong, or the network call fails — caller is expected to
/// surface that as a test fatal rather than a flaky skip.
class E2ESeedClient {
  E2ESeedClient({required this.apiUrl, required this.seedToken});

  final String apiUrl;
  final String seedToken;

  /// Posts to /api/e2e/seed and parses the response. Uses dart:io directly
  /// (not dio) so the harness has zero shared state with the app under
  /// test — we don't want auth interceptors or retry logic mutating the
  /// seed call.
  Future<E2ESeedFixture> seed() async {
    final uri = Uri.parse('$apiUrl/api/e2e/seed');
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $seedToken');
      req.headers.contentType = ContentType.json;
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        throw StateError('seed endpoint returned ${res.statusCode}: $body');
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      return E2ESeedFixture.fromJson(json);
    } finally {
      client.close(force: true);
    }
  }
}

class E2ESeedFixture {
  const E2ESeedFixture({
    required this.passengerId,
    required this.passengerJwt,
    required this.passengerEmail,
    required this.driverId,
    required this.driverJwt,
    required this.driverEmail,
    required this.rideId,
  });

  final String passengerId;
  final String passengerJwt;
  final String passengerEmail;
  final String driverId;
  final String driverJwt;
  final String driverEmail;
  final String rideId;

  factory E2ESeedFixture.fromJson(Map<String, dynamic> json) {
    return E2ESeedFixture(
      passengerId: json['passenger_id'] as String,
      passengerJwt: json['passenger_jwt'] as String,
      passengerEmail: json['passenger_email'] as String,
      driverId: json['driver_id'] as String,
      driverJwt: json['driver_jwt'] as String,
      driverEmail: json['driver_email'] as String,
      rideId: json['ride_id'] as String,
    );
  }
}
