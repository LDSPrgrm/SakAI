@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ws/ws_client.dart';
import 'package:sakai_shared/ws/ws_events.dart';

/// Loopback WS server that records every inbound text frame and the
/// subprotocol the client proposed, so tests can assert negotiation +
/// heartbeat behaviour against real socket traffic.
class _V2Harness {
  HttpServer? _server;
  WebSocket? _socket;
  final List<String> proposed = [];
  String? selected;
  final inbound = StreamController<String>.broadcast();

  String? selectedByServer;
  String get baseUrl => 'http://localhost:${_server!.port}';

  /// [serverPicks] is the subprotocol the test server picks from the
  /// client-proposed list. Null = server doesn't pick any (v1 fallback) —
  /// achieved by not passing a protocolSelector to WebSocketTransformer.
  Future<void> start({String? serverPicks = WsSubprotocols.v2}) async {
    selectedByServer = serverPicks;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path.endsWith('/ws') &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        proposed.addAll(
          request.headers
                  .value('sec-websocket-protocol')
                  ?.split(',')
                  .map((s) => s.trim()) ??
              const <String>[],
        );
        final WebSocket socket;
        if (serverPicks != null) {
          socket = await WebSocketTransformer.upgrade(
            request,
            protocolSelector: (offered) {
              if (offered.contains(serverPicks)) {
                selected = serverPicks;
                return serverPicks;
              }
              // Test misconfiguration: serverPicks not offered. Pick first
              // to keep the connection up rather than throwing.
              selected = offered.isNotEmpty ? offered.first : null;
              return selected ?? '';
            },
          );
        } else {
          socket = await WebSocketTransformer.upgrade(request);
          final proto = socket.protocol;
          selected = (proto == null || proto.isEmpty) ? null : proto;
        }
        _socket = socket;
        socket.listen(
          (data) {
            if (data is String) inbound.add(data);
          },
          onDone: () {},
          onError: (_) {},
        );
      } else {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
      }
    });
  }

  void sendEnvelope(Map<String, dynamic> envelope) {
    _socket?.add(jsonEncode(envelope));
  }

  Future<void> stop() async {
    await inbound.close();
    try {
      await _socket?.close(WebSocketStatus.normalClosure);
    } catch (_) {}
    _socket = null;
    await _server?.close(force: true);
    _server = null;
  }
}

void main() {
  group('WsClient v2 — subprotocol negotiation', () {
    test('proposes both v2 and v1 in Sec-WebSocket-Protocol', () async {
      final harness = _V2Harness();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      // Allow the upgrade to complete and the server to record headers.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(harness.proposed, containsAll([WsSubprotocols.v2, WsSubprotocols.v1]));
      expect(client.isV2, isTrue, reason: 'server picked v2 → client.isV2 must be true');
      expect(client.negotiatedProtocol, WsSubprotocols.v2);
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('falls back gracefully when server selects no subprotocol', () async {
      final harness = _V2Harness();
      await harness.start(serverPicks: null);
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(client.isV2, isFalse);
      expect(
        client.negotiatedProtocol == null || client.negotiatedProtocol == '',
        isTrue,
        reason: 'no subprotocol selected — client.negotiatedProtocol must be null or empty',
      );
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('WsClient v2 — heartbeat + watchdog', () {
    test('sends JSON ping at heartbeat interval', () async {
      final harness = _V2Harness();
      await harness.start();
      final client = WsClient(
        heartbeatInterval: const Duration(milliseconds: 100),
        watchdogTimeout: const Duration(seconds: 5),
      );
      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');

      // Wait for at least two heartbeat ticks.
      final pings = await harness.inbound
          .stream
          .where((frame) {
            try {
              final m = jsonDecode(frame);
              return m is Map && m['type'] == 'ping';
            } catch (_) {
              return false;
            }
          })
          .take(2)
          .toList()
          .timeout(const Duration(seconds: 5));
      expect(pings.length, greaterThanOrEqualTo(2));

      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('watchdog trips and triggers reconnect when no inbound arrives', () async {
      final harness = _V2Harness();
      await harness.start();
      final client = WsClient(
        heartbeatInterval: const Duration(seconds: 5),
        watchdogTimeout: const Duration(milliseconds: 300),
      );
      var resyncCount = 0;
      client.onResync = () => resyncCount++;

      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');

      // Don't send any inbound frames. Watchdog should fire ~300ms in,
      // which triggers _scheduleReconnect → onResync. Backoff is at least
      // 1s on first retry, so wait long enough.
      await Future<void>.delayed(const Duration(seconds: 3));
      expect(resyncCount, greaterThanOrEqualTo(1));

      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 20)));
  });

  group('WsClient v2 — envelope parsing', () {
    test('surfaces v/seq/corr_id/ack_required from inbound frame', () async {
      final harness = _V2Harness();
      await harness.start();
      final client = WsClient();
      final events = <WsEvent>[];
      final sub = client.events.listen(events.add);

      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      harness.sendEnvelope({
        'event': WsEventNames.connWelcome,
        'payload': {'protocol': WsSubprotocols.v2, 'v': 2},
        'timestamp': '2026-05-20T01:23:45.000Z',
        'event_id': '018f4e6e-8b1c-7000-a000-000000000000',
        'v': 2,
        'seq': 1,
        'corr_id': 'conn-abc',
        'ack_required': false,
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events, isNotEmpty);
      final welcome = events.first;
      expect(welcome.type, WsEventNames.connWelcome);
      expect(welcome.v, 2);
      expect(welcome.seq, 1);
      expect(welcome.corrId, 'conn-abc');
      expect(welcome.ackRequired, false);

      await sub.cancel();
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('leaves v2 fields null when server sends v1-shape envelope', () async {
      final harness = _V2Harness();
      await harness.start(serverPicks: null);
      final client = WsClient();
      final events = <WsEvent>[];
      final sub = client.events.listen(events.add);

      await client.connect(baseUrl: harness.baseUrl, accessToken: 'test');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      harness.sendEnvelope({
        'event': WsEventNames.rideAccepted,
        'payload': {'ride_id': 'r1', 'driver_id': 'd1'},
        'timestamp': '2026-05-20T01:23:45Z',
        'event_id': '018f4e6e-8b1c-7000-a000-000000000001',
      });

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(events, hasLength(1));
      final ev = events.first;
      expect(ev.type, WsEventNames.rideAccepted);
      expect(ev.v, isNull);
      expect(ev.seq, isNull);
      expect(ev.corrId, isNull);
      expect(ev.ackRequired, isNull);

      await sub.cancel();
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
