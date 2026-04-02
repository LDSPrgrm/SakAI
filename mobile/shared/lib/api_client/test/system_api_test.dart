import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';


/// tests for SystemApi
void main() {
  final instance = SakaiApiClient().getSystemApi();

  group(SystemApi, () {
    // Health check
    //
    // Returns server health. Used by Docker health checks, load balancers, and CI smoke tests. Does not require authentication. 
    //
    //Future<HealthResponse> healthCheck() async
    test('test healthCheck', () async {
      // TODO
    });

  });
}
