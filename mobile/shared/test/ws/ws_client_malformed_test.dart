@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ws/ws_client.dart';

/// HTTP server that upgrades to a WebSocket and lets the test pump arbitrary
/// frames at the client.
class _ControllableServer {
  HttpServer? _server;
  final _socketReady = Completer<WebSocket>();

  String get baseUrl => 'http://localhost:${_server!.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path.endsWith('/ws') &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(request);
        if (!_socketReady.isCompleted) _socketReady.complete(socket);
      }
    });
  }

  Future<WebSocket> socket() => _socketReady.future;

  Future<void> stop() async {
    final s = await _socketReady.future.timeout(
      const Duration(milliseconds: 200),
      onTimeout: () => throw StateError('no socket'),
    );
    try {
      await s.close(WebSocketStatus.normalClosure);
    } catch (_) {}
    await _server?.close(force: true);
    _server = null;
  }
}

void main() {
  group('WsClient malformed stream', () {
    test('non-JSON frame surfaces on malformed stream', () async {
      final harness = _ControllableServer();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      final server = await harness.socket();

      final malformed = client.malformed.first;

      server.add('{not json');

      final event = await malformed.timeout(const Duration(seconds: 2));
      expect(event.rawPayload, '{not json');
      expect(event.reason, contains('parse'));

      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('valid event does NOT push to malformed stream', () async {
      final harness = _ControllableServer();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      final server = await harness.socket();

      var malformedCount = 0;
      final sub = client.malformed.listen((_) => malformedCount++);

      server.add('{"event":"ride.accepted","payload":{"ride_id":"r1"}}');

      // Allow the frame to flow through.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(malformedCount, 0);

      await sub.cancel();
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
