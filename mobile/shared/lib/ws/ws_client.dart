import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../api/sakai_api_support.dart';
import 'ws_events.dart';

final _log = Logger('WsClient');

/// Default client-side heartbeat cadence. Sends a JSON ping every
/// [_defaultHeartbeatInterval] to keep cellular NAT alive; if no inbound
/// message arrives within [_defaultWatchdogTimeout] the connection is forced
/// to reconnect even if the OS TCP layer hasn't yet noticed the disconnect.
/// Tests may override these via the [WsClient] constructor.
const _defaultHeartbeatInterval = Duration(seconds: 20);
const _defaultWatchdogTimeout = Duration(seconds: 45);

/// Persistence contract for the last applied `event_id`. The WsClient uses
/// it to send `replay.request` on reconnect so the server can drain any
/// envelopes the client missed during the disconnect.
///
/// Implementations are expected to be per-user — callers wire the right
/// instance through the WsClient constructor when the user logs in.
abstract class WsCursorStorage {
  Future<String?> read();
  Future<void> write(String eventId);
  Future<void> clear();
}

/// In-memory [WsCursorStorage] for tests and apps that don't yet persist.
class InMemoryWsCursorStorage implements WsCursorStorage {
  String? _id;
  @override
  Future<String?> read() async => _id;
  @override
  Future<void> write(String eventId) async => _id = eventId;
  @override
  Future<void> clear() async => _id = null;
}

/// WebSocket client with auto-reconnect, state resync, and client-side
/// heartbeat. The constructor takes the negotiated subprotocol list from
/// [WsSubprotocols]; the server picks the first match.
class WsClient {
  WsClient({
    Duration? heartbeatInterval,
    Duration? watchdogTimeout,
    WsCursorStorage? cursorStorage,
  })  : _heartbeatInterval = heartbeatInterval ?? _defaultHeartbeatInterval,
        _watchdogTimeout = watchdogTimeout ?? _defaultWatchdogTimeout,
        _cursorStorage = cursorStorage;

  final Duration _heartbeatInterval;
  final Duration _watchdogTimeout;
  final WsCursorStorage? _cursorStorage;

  /// Ring buffer of event_ids the dispatcher has already surfaced. New
  /// frames whose event_id appears here are ACKed but NOT re-emitted,
  /// so handlers run exactly-once even though the wire is at-least-once.
  static const int _dedupCapacity = 128;
  final _seenEventIds = <String>{};
  final _seenOrder = <String>[];

  WebSocketChannel? _channel;
  final _eventController = StreamController<WsEvent>.broadcast();
  final _malformedController =
      StreamController<WsMalformedEvent>.broadcast();
  bool _isConnected = false;
  bool _explicitlyDisconnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _watchdogTimer;
  VoidCallback? _onResync;
  String? _negotiatedProtocol;

  Stream<WsEvent> get events => _eventController.stream;

  /// Stream of frames that could NOT be parsed into a [WsEvent]. Apps wire
  /// this to telemetry (Sentry, analytics) so silent parse failures
  /// surface in monitoring instead of vanishing.
  Stream<WsMalformedEvent> get malformed => _malformedController.stream;

  bool get isConnected => _isConnected;

  /// Subprotocol selected by the server during the last connect handshake.
  /// One of [WsSubprotocols.v1], [WsSubprotocols.v2], or null if the server
  /// didn't pick a protocol (pre-v2 server behaviour).
  String? get negotiatedProtocol => _negotiatedProtocol;

  /// True when the server negotiated [WsSubprotocols.v2].
  bool get isV2 => _negotiatedProtocol == WsSubprotocols.v2;

  /// Callback fired on reconnect to resync state (should call GET /rides/active).
  set onResync(VoidCallback cb) => _onResync = cb;

  Future<void> connect({String? baseUrl, String? accessToken}) async {
    if (_isConnected) await disconnect();
    _explicitlyDisconnected = false;

    final uri = SakaiApiEndpoints.webSocketUri(
      baseUrl ?? SakaiApiEndpoints.defaultRestBaseUrl,
      accessToken ?? '',
    );

    debugPrint('[WS] Connecting to $uri (proposing: ${WsSubprotocols.all})');

    try {
      _channel = WebSocketChannel.connect(uri, protocols: WsSubprotocols.all);
      // ready resolves once the WS handshake completes; only then is the
      // negotiated subprotocol observable on the channel.
      await _channel!.ready;
      _negotiatedProtocol = _channel!.protocol;

      _channel!.stream.listen(
        (data) {
          _kickWatchdog();
          final raw = data is String ? data : data.toString();
          try {
            final message = jsonDecode(raw) as Map<String, dynamic>;
            final event = WsEvent.fromMessage(message);
            final isDuplicate = _markSeen(event.eventId);
            if (!isDuplicate) {
              _eventController.add(event);
              _recordEventId(event.eventId);
            }
            // ACK is sent for every ack_required envelope — even duplicates —
            // so the server stops retrying immediately.
            _maybeAck(event);
          } catch (e, st) {
            _log.warning('parse failed: $e', e, st);
            _malformedController.add(
              WsMalformedEvent(
                rawPayload: raw,
                reason: 'parse: ${e.runtimeType}',
                error: e,
              ),
            );
          }
        },
        onError: (error) {
          debugPrint('[WS] Stream error: $error');
          _scheduleReconnect(baseUrl: baseUrl, accessToken: accessToken);
        },
        onDone: () {
          debugPrint('[WS] Connection closed');
          _scheduleReconnect(baseUrl: baseUrl, accessToken: accessToken);
        },
        cancelOnError: false,
      );

      // Connection established successfully - reset reconnect attempts
      _isConnected = true;
      _reconnectAttempts = 0;
      _startHeartbeat(baseUrl: baseUrl, accessToken: accessToken);
      // Ask the server to drain anything we missed since [_lastEventId].
      // Empty/null cursor on a v2 conn still triggers a replay path on the
      // server side (full stream up to retention) — caller may prefer to
      // attach cursorStorage only after onboarding completes.
      unawaited(_requestReplay());
    } catch (e) {
      debugPrint('[WS] Connect failed: $e');
      _scheduleReconnect(baseUrl: baseUrl, accessToken: accessToken);
    }
  }

  /// Sends a `replay.request` frame using the last persisted event_id (if
  /// any). No-op when no cursor storage is wired or when the underlying
  /// channel went away between connect and this microtask.
  Future<void> _requestReplay() async {
    final storage = _cursorStorage;
    if (storage == null) return;
    final cursor = await storage.read();
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({
        'type': 'replay.request',
        if (cursor != null && cursor.isNotEmpty) 'last_event_id': cursor,
      }));
    } catch (e) {
      debugPrint('[WS] replay.request send failed: $e');
    }
  }

  /// Records the event_id of the just-parsed envelope to persistent storage
  /// so the next reconnect can resume from it. Failures are swallowed — the
  /// next ride.state_sync (or fresh REST refetch) heals state.
  void _recordEventId(String? eventId) {
    if (eventId == null || eventId.isEmpty) return;
    final storage = _cursorStorage;
    if (storage == null) return;
    unawaited(storage.write(eventId).catchError((e, st) {
      _log.warning('cursor persist failed: $e', e, st);
    }));
  }

  /// Returns true if [eventId] was already surfaced on this connection.
  /// Maintains a bounded LRU so memory stays flat on long sessions.
  bool _markSeen(String? eventId) {
    if (eventId == null || eventId.isEmpty) return false;
    if (_seenEventIds.contains(eventId)) return true;
    _seenEventIds.add(eventId);
    _seenOrder.add(eventId);
    if (_seenOrder.length > _dedupCapacity) {
      final evicted = _seenOrder.removeAt(0);
      _seenEventIds.remove(evicted);
    }
    return false;
  }

  /// Emits {type:"ack", event_id} when the envelope demands acknowledgement.
  /// Server-side AckTracker drops the pending entry; without this, critical
  /// events would retransmit up to four times before failing.
  void _maybeAck(WsEvent event) {
    if (event.ackRequired != true) return;
    final eventId = event.eventId;
    if (eventId == null || eventId.isEmpty) return;
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode({'type': 'ack', 'event_id': eventId}));
    } catch (e) {
      debugPrint('[WS] ack send failed: $e');
    }
  }

  Future<void> disconnect() async {
    _explicitlyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    _reconnectAttempts = 0;
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _isConnected = false;
    _negotiatedProtocol = null;
    _seenEventIds.clear();
    _seenOrder.clear();
  }

  /// Start the dual-timer heartbeat: outbound JSON ping every 20s to keep
  /// the connection live across NAT timeouts, and a watchdog that forces
  /// reconnect if no inbound frame arrives within 45s. The watchdog catches
  /// the case where the TCP layer hasn't yet detected a dead peer.
  void _startHeartbeat({String? baseUrl, String? accessToken}) {
    _heartbeatTimer?.cancel();
    _watchdogTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      final ch = _channel;
      if (ch == null) return;
      try {
        ch.sink.add(jsonEncode({'type': 'ping'}));
      } catch (e) {
        debugPrint('[WS] heartbeat send failed: $e');
      }
    });
    _kickWatchdog(baseUrl: baseUrl, accessToken: accessToken);
  }

  /// Reset the 45s watchdog. Called on every received frame and at connect.
  void _kickWatchdog({String? baseUrl, String? accessToken}) {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(_watchdogTimeout, () {
      debugPrint('[WS] watchdog tripped — no inbound for $_watchdogTimeout');
      _scheduleReconnect(baseUrl: baseUrl, accessToken: accessToken);
    });
  }

  void _scheduleReconnect({String? baseUrl, String? accessToken}) {
    _isConnected = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _watchdogTimer?.cancel();
    _watchdogTimer = null;
    if (_explicitlyDisconnected) return; // Caller asked us to stop.
    if (_reconnectAttempts >= 10) return; // Give up after 10 attempts.

    final delaySeconds = _backoffDuration();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      _onResync?.call();
      connect(baseUrl: baseUrl, accessToken: accessToken);
    });
  }

  int _backoffDuration() {
    // Exponential backoff: 1, 2, 4, 8, 16, max 30 with ±25% jitter.
    final base = min(1 << _reconnectAttempts, 30);
    final jitter = base * 0.25;
    _reconnectAttempts++;
    return (base + (Random().nextDouble() * 2 - 1) * jitter).round().clamp(
      1,
      30,
    );
  }
}

typedef VoidCallback = void Function();
