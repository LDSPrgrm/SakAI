import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for WsEventConnWelcome
void main() {
  final instance = WsEventConnWelcomeBuilder();
  // TODO add properties to the builder and call build()

  group(WsEventConnWelcome, () {
    // Negotiated WebSocket subprotocol. Empty string for v1 clients, `\"sakai.v2\"` for v2. 
    // String protocol
    test('to test the property `protocol`', () async {
      // TODO
    });

    // Envelope protocol version supported by the server.
    // int v
    test('to test the property `v`', () async {
      // TODO
    });

  });
}
