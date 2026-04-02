import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';


/// tests for UsersApi
void main() {
  final instance = SakaiApiClient().getUsersApi();

  group(UsersApi, () {
    // Get the authenticated user's profile
    //
    // Returns the current user's profile based on the bearer token. Call this on app cold-start after restoring a stored token to re-hydrate session state. For drivers, includes vehicle information. 
    //
    //Future<UserProfile> usersGetMe() async
    test('test usersGetMe', () async {
      // TODO
    });

  });
}
