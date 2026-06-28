@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/ws/ws_client.dart';
import 'package:sakai_shared/ws/ws_events.dart';

class _AckHarness {
  HttpServer? _server;
  WebSocket? _socket;
  final inbound = StreamController<String>.broadcast();

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

Future<Map<String, dynamic>?> waitForFrame(
  Stream<String> stream,
  bool Function(Map<String, dynamic>) match, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final c = Completer<Map<String, dynamic>?>();
  late StreamSubscription<String> sub;
  sub = stream.listen((raw) {
    try {
      final m = jsonDecode(raw);
      if (m is Map<String, dynamic> && match(m) && !c.isCompleted) {
        c.complete(m);
        sub.cancel();
      }
    } catch (_) {}
  });
  Timer(timeout, () {
    if (!c.isCompleted) {
      c.complete(null);
      sub.cancel();
    }
  });
  return c.future;
}

void main() {
  group('WsClient v2 — ack + dedup', () {
    test('emits ack when server sends ack_required:true', () async {
      final harness = _AckHarness();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      await Future<void>.delayed(const Duration(milliseconds: 60));

      const eventId = '018f4e6e-aaaa-7000-a000-000000000099';
      harness.send({
        'event': WsEventNames.rideAccepted,
        'payload': {'ride_id': 'r1', 'driver_id': 'd1'},
        'timestamp': '2026-05-20T01:23:45Z',
        'event_id': eventId,
        'v': 2,
        'seq': 1,
        'ack_required': true,
      });

      final ack = await waitForFrame(
        harness.inbound.stream,
        (m) => m['type'] == 'ack',
      );
      expect(ack, isNotNull, reason: 'client did not emit ack');
      expect(ack!['event_id'], eventId);

      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('does not emit ack when ack_required is false/absent', () async {
      final harness = _AckHarness();
      await harness.start();
      final client = WsClient();
      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      await Future<void>.delayed(const Duration(milliseconds: 60));

      harness.send({
        'event': WsEventNames.driverLocationUpdated,
        'payload': {'ride_id': 'r1', 'location': {'lat': 1.0, 'lng': 2.0}},
        'timestamp': '2026-05-20T01:23:45Z',
        'event_id': '018f4e6e-bbbb-7000-a000-000000000001',
        'v': 2,
        'seq': 1,
      });

      // No ack frame expected; cap wait short.
      final ack = await waitForFrame(
        harness.inbound.stream,
        (m) => m['type'] == 'ack',
        timeout: const Duration(milliseconds: 300),
      );
      expect(ack, isNull, reason: 'ack should not be sent for non-critical event');

      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('duplicate event_id is acked but suppressed from event stream', () async {
      final harness = _AckHarness();
      await harness.start();
      final client = WsClient();
      final events = <WsEvent>[];
      final sub = client.events.listen(events.add);

      await client.connect(baseUrl: harness.baseUrl, accessToken: 't');
      await Future<void>.delayed(const Duration(milliseconds: 60));

      const eventId = '018f4e6e-cccc-7000-a000-000000000111';
      final frame = {
        'event': WsEventNames.rideCancelled,
        'payload': {'ride_id': 'r1', 'cancelled_by': 'passenger'},
        'timestamp': '2026-05-20T01:23:45Z',
        'event_id': eventId,
        'v': 2,
        'seq': 1,
        'ack_required': true,
      };

      final ackFrames = <Map<String, dynamic>>[];
      final ackSub = harness.inbound.stream.listen((raw) {
        try {
          final m = jsonDecode(raw);
          if (m is Map<String, dynamic> && m['type'] == 'ack') {
            ackFrames.add(m);
          }
        } catch (_) {}
      });

      harness.send(frame);
      harness.send(frame); // duplicate
      await Future<void>.delayed(const Duration(milliseconds: 250));

      final cancelledEvents =
          events.where((e) => e.eventId == eventId).toList();
      expect(cancelledEvents, hasLength(1),
          reason: 'duplicate must not reach event stream twice');
      expect(ackFrames.length, greaterThanOrEqualTo(2),
          reason: 'each receive must ack regardless of dedup');

      await ackSub.cancel();
      await sub.cancel();
      await client.disconnect();
      await harness.stop();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
