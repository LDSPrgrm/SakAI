import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../api/sakai_api_support.dart';
import 'ws_events.dart';

/// WebSocket client with auto-reconnect and state resync.
class WsClient {
  WebSocketChannel? _channel;
  final _eventController = StreamController<WsEvent>.broadcast();
  bool _isConnected = false;
  bool _explicitlyDisconnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  VoidCallback? _onResync;

  Stream<WsEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  /// Callback fired on reconnect to resync state (should call GET /rides/active).
  set onResync(VoidCallback cb) => _onResync = cb;

  Future<void> connect({String? baseUrl, String? accessToken}) async {
    if (_isConnected) await disconnect();
    _explicitlyDisconnected = false;

    final uri = SakaiApiEndpoints.webSocketUri(
      baseUrl ?? SakaiApiEndpoints.defaultRestBaseUrl,
      accessToken ?? '',
    );

    debugPrint('[WS] Connecting to $uri');

    try {
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            _eventController.add(WsEvent.fromMessage(message));
          } catch (_) {
            // Ignore malformed messages.
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
    } catch (e) {
      debugPrint('[WS] Connect failed: $e');
      _scheduleReconnect(baseUrl: baseUrl, accessToken: accessToken);
    }
  }

  Future<void> disconnect() async {
    _explicitlyDisconnected = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    await _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    _isConnected = false;
  }

  void _scheduleReconnect({String? baseUrl, String? accessToken}) {
    _isConnected = false;
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
