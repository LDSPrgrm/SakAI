@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ws/ws_client.dart';

/// Spins up an HttpServer on a random localhost port that upgrades incoming
/// requests to WebSockets.
class _WsServerHarness {
  HttpServer? _server;
  final List<WebSocket> _allSockets = [];

  String get baseUrl => 'http://localhost:${_server!.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path.endsWith('/ws') &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        _allSockets.add(socket);
        socket.listen((_) {}, onDone: () {}, onError: (_) {});
      } else {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
      }
    });
  }

  Future<void> stop() async {
    for (final s in _allSockets) {
      try {
        await s.close(WebSocketStatus.normalClosure);
      } catch (_) {}
    }
    _allSockets.clear();
    await _server?.close(force: true);
    _server = null;
  }
}

void main() {
  group('WsClient resilience', () {
    test('connects against loopback WS server', () async {
      final harness = _WsServerHarness();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      expect(client.isConnected, isTrue);
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('disconnect() suppresses subsequent reconnect attempts', () async {
      final harness = _WsServerHarness();
      await harness.start();
      final client = WsClient();
      var resyncCount = 0;
      client.onResync = () => resyncCount++;

      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      await client.disconnect();
      await harness.stop();

      // disconnect() should set _explicitlyDisconnected so the listener's
      // onDone path bails out of _scheduleReconnect — onResync must NOT fire.
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(resyncCount, 0);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('onResync callback is replaceable', () {
      final client = WsClient();
      var calls = 0;
      client.onResync = () => calls++;
      // The setter exists and accepts replacements; production notifiers
      // rely on this contract to wire their refetch logic.
      client.onResync = () => calls += 10;
      expect(calls, 0);
    });

    test('events stream is broadcast (multiple listeners allowed)', () async {
      final client = WsClient();
      // Even before connect(), `events` should be a broadcast stream.
      final sub1 = client.events.listen((_) {});
      final sub2 = client.events.listen((_) {});
      await sub1.cancel();
      await sub2.cancel();
    });
  });
}
