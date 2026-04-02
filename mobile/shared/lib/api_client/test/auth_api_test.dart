import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';


/// tests for AuthApi
void main() {
  final instance = SakaiApiClient().getAuthApi();

  group(AuthApi, () {
    // Login and receive tokens
    //
    // Returns a short-lived access token and a long-lived refresh token.
    //
    //Future<AuthResponse> authLogin(LoginRequest loginRequest) async
    test('test authLogin', () async {
      // TODO
    });

    // Logout and invalidate tokens
    //
    // Invalidates the refresh token server-side. The access token will remain technically valid until its expiry — clients should discard it immediately. Call this on explicit user logout. 
    //
    //Future authLogout(LogoutRequest logoutRequest) async
    test('test authLogout', () async {
      // TODO
    });

    // Refresh the access token
    //
    // Exchanges a valid refresh token for a new access token (and rotated refresh token). Call this silently before the access token expires — typically at 80% of its TTL. Refresh token rotation means the old refresh token is invalidated on use. 
    //
    //Future<AuthResponse> authRefresh(RefreshRequest refreshRequest) async
    test('test authRefresh', () async {
      // TODO
    });

    // Register a new user
    //
    // Creates a passenger or driver account. Role is fixed at registration. Returns an access token and refresh token immediately — no separate login needed. 
    //
    //Future<AuthResponse> authRegister(RegisterRequest registerRequest) async
    test('test authRegister', () async {
      // TODO
    });

  });
}
