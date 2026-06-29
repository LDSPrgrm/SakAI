/// Lightweight telemetry sink for WebSocket malformed-event observability.
///
/// Apps install a sink (Sentry breadcrumb, analytics counter, console
/// logger, etc.) by overriding [wsTelemetryProvider] in their root
/// `ProviderScope`. The dispatcher feeds malformed events into the sink;
/// the sink chooses what to do with them.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ws_dispatcher.dart';
import 'ws_events.dart';

/// A sink for WebSocket telemetry events. The default implementation is
/// a [_NoopWsTelemetry] which counts malformed events but does no I/O.
abstract class WsTelemetry {
  void recordMalformed(WsMalformedEvent event);
  int get malformedCount;
}

class _NoopWsTelemetry implements WsTelemetry {
  int _count = 0;
  @override
  void recordMalformed(WsMalformedEvent _) {
    _count++;
  }

  @override
  int get malformedCount => _count;
}

/// Override this provider at the root of the app to plug in a Sentry /
/// analytics sink:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     wsTelemetryProvider.overrideWithValue(MySentryWsSink()),
///   ],
///   child: MyApp(),
/// );
/// ```
final wsTelemetryProvider = Provider<WsTelemetry>((ref) => _NoopWsTelemetry());

/// Wires the dispatcher's `malformed` stream into [WsTelemetry]. Hosts
/// must keep this provider alive (e.g., `ref.listen(wsTelemetryWirerProvider, (_, __) {})`)
/// for telemetry to flow.
final wsTelemetryWirerProvider = Provider<StreamSubscription<WsMalformedEvent>?>(
  (ref) {
    final dispatcher = ref.watch(_dispatcherForTelemetry);
    if (dispatcher == null) return null;
    final telemetry = ref.watch(wsTelemetryProvider);
    final sub = dispatcher.malformed.listen(telemetry.recordMalformed);
    ref.onDispose(sub.cancel);
    return sub;
  },
);

/// Host apps override this with the live `WsDispatcher` instance. Left
/// null in the shared layer so the wirer is a no-op until apps plug it
/// in — keeps the shared lib free of app-specific Riverpod wiring.
final _dispatcherForTelemetry = Provider<WsDispatcher?>((_) => null);

/// Hook for apps to supply their dispatcher to the telemetry wirer.
/// Use a `ProviderScope` override at app startup.
final wsDispatcherForTelemetryProvider = _dispatcherForTelemetry;
