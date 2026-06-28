@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ws/ws_client.dart';
import 'package:sakai_shared/ws/ws_events.dart';

/// Reconnect-aware harness — exposes the most-recent socket + a stream of
/// inbound text frames so tests can assert that the client sent the
/// expected `replay.request` on reconnect.
class _ResyncHarness {
  HttpServer? _server;
  WebSocket? _socket;
  final inbound = StreamController<String>.broadcast();
  int connectCount = 0;

  String get baseUrl => 'http://localhost:${_server!.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen((request) async {
      if (request.uri.path.endsWith('/ws') &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final socket = await WebSocketTransformer.upgrade(
          request,
          protocolSelector: (offered) =>
              offered.contains(WsSubprotocols.v2)
                  ? WsSubprotocols.v2
                  : offered.first,
        );
        _socket = socket;
        connectCount++;
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

  void send(Map<String, dynamic> envelope) {
    _socket?.add(jsonEncode(envelope));
  }

  Future<void> dropClientSocket() async {
    await _socket?.close(WebSocketStatus.goingAway);
    _socket = null;
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
  group('WsClient v2 — reconnect resync', () {
    test('records last_event_id on each parsed event', () async {
      final harness = _ResyncHarness();
      await harness.start();
      final cursor = InMemoryWsCursorStorage();
      final client = WsClient(cursorStorage: cursor);

      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      await Future<void>.delayed(const Duration(milliseconds: 50));

      const eventId = '018f4e6e-8b1c-7000-a000-000000000001';
      harness.send({
        'event': WsEventNames.rideAccepted,
        'payload': {'ride_id': 'r1', 'driver_id': 'd1'},
        'timestamp': '2026-05-20T01:23:45Z',
        'event_id': eventId,
        'v': 2,
        'seq': 1,
      });
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(await cursor.read(), eventId);
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test(
      'sends replay.request with stored last_event_id on connect',
      () async {
        final harness = _ResyncHarness();
        await harness.start();
        final cursor = InMemoryWsCursorStorage();
        await cursor.write('seed-event-id-from-prior-session');

        final client = WsClient(cursorStorage: cursor);

        final inboundFrames = <Map<String, dynamic>>[];
        final sub = harness.inbound.stream.listen((raw) {
          try {
            final m = jsonDecode(raw);
            if (m is Map<String, dynamic>) inboundFrames.add(m);
          } catch (_) {}
        });

        await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final replay = inboundFrames.firstWhere(
          (m) => m['type'] == 'replay.request',
          orElse: () => <String, dynamic>{},
        );
        expect(replay, isNotEmpty,
            reason: 'replay.request was not sent on connect');
        expect(replay['last_event_id'], 'seed-event-id-from-prior-session');

        await sub.cancel();
        await client.disconnect();
        await harness.stop();
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'on server drop + reconnect, sends replay.request with most-recent event_id',
      () async {
        final harness = _ResyncHarness();
        await harness.start();
        final cursor = InMemoryWsCursorStorage();
        final client = WsClient(
          cursorStorage: cursor,
          heartbeatInterval: const Duration(seconds: 10),
          watchdogTimeout: const Duration(seconds: 10),
        );

        final inboundFrames = <Map<String, dynamic>>[];
        final sub = harness.inbound.stream.listen((raw) {
          try {
            final m = jsonDecode(raw);
            if (m is Map<String, dynamic>) inboundFrames.add(m);
          } catch (_) {}
        });

        await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        const eventId = '018f4e6e-9000-7000-a000-000000000050';
        harness.send({
          'event': WsEventNames.rideStatusChanged,
          'payload': {'ride_id': 'r1', 'status': 'arrived'},
          'timestamp': '2026-05-20T01:30:00Z',
          'event_id': eventId,
          'v': 2,
          'seq': 5,
        });
        await Future<void>.delayed(const Duration(milliseconds: 150));

        inboundFrames.clear();
        await harness.dropClientSocket();
        // Backoff is at least 1s on first retry; give it room.
        await Future<void>.delayed(const Duration(seconds: 3));

        expect(harness.connectCount, greaterThanOrEqualTo(2),
            reason: 'client did not reconnect after server drop');
        final replay = inboundFrames.firstWhere(
          (m) => m['type'] == 'replay.request',
          orElse: () => <String, dynamic>{},
        );
        expect(replay['last_event_id'], eventId);

        await sub.cancel();
        await client.disconnect();
        await harness.stop();
      },
      timeout: const Timeout(Duration(seconds: 20)),
    );

    test(
      'ride.state_sync routes through dispatcher and surfaces on events stream',
      () async {
        final harness = _ResyncHarness();
        await harness.start();
        final client = WsClient();
        final events = <WsEvent>[];
        final sub = client.events.listen(events.add);

        await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
        await Future<void>.delayed(const Duration(milliseconds: 50));

        harness.send({
          'event': WsEventNames.rideStateSync,
          'payload': {
            'has_active_ride': true,
            'ride_id': 'ride-xyz',
            'status': 'accepted',
          },
          'timestamp': '2026-05-20T01:40:00Z',
          'event_id': '018f4e6e-aaaa-7000-a000-000000000001',
          'v': 2,
          'seq': 99,
        });

        await Future<void>.delayed(const Duration(milliseconds: 150));
        final stateSync = events.firstWhere(
          (e) => e.type == WsEventNames.rideStateSync,
          orElse: () => WsEvent(type: '', payload: {}),
        );
        expect(stateSync.type, WsEventNames.rideStateSync);
        expect(stateSync.payload['has_active_ride'], true);
        expect(stateSync.payload['ride_id'], 'ride-xyz');

        await sub.cancel();
        await client.disconnect();
        await harness.stop();
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}
