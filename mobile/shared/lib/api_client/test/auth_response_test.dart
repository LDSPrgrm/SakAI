import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for AuthResponse
void main() {
  final instance = AuthResponseBuilder();
  // TODO add properties to the builder and call build()

  group(AuthResponse, () {
    // Short-lived JWT (60 min). Include as `Authorization: Bearer <access_token>`. 
    // String accessToken
    test('to test the property `accessToken`', () async {
      // TODO
    });

    // Long-lived opaque token (30 days). Store securely (e.g., flutter_secure_storage). Use with `POST /auth/refresh` to silently obtain new access tokens. Rotated on every use — old token is invalidated. 
    // String refreshToken
    test('to test the property `refreshToken`', () async {
      // TODO
    });

    // UTC expiry of the access token. Refresh before this time.
    // DateTime accessTokenExpiresAt
    test('to test the property `accessTokenExpiresAt`', () async {
      // TODO
    });

    // UserProfile user
    test('to test the property `user`', () async {
      // TODO
    });

  });
}
