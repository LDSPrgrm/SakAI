import 'dart:convert';
import 'dart:io';

/// Driver-side mirror of the passenger E2ESeedClient. Same endpoint, same
/// response shape — kept duplicated rather than shared so the driver
/// integration test stays self-contained (no cross-app harness import).
class E2ESeedClient {
  E2ESeedClient({required this.apiUrl, required this.seedToken});

  final String apiUrl;
  final String seedToken;

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
