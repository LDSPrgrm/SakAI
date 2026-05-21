import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';

/// Side-effect runner used when a passenger SOS lands on this driver's
/// device. Defaults to platform haptic + alert click; swappable in tests
/// so the assertion can verify the trigger fired without depending on
/// real platform plugins.
typedef SosCounterpartAlert = Future<void> Function();

Future<void> _defaultCounterpartAlert() async {
  // Heavy haptic to break the driver out of map/navigation focus, then a
  // short system click. iOS + Android both surface SystemSoundType.alert
  // without requiring an explicit audio asset, which keeps this gated by
  // the OS volume profile (i.e. silent mode wins).
  await HapticFeedback.heavyImpact();
  await SystemSound.play(SystemSoundType.alert);
}

class SosState {
  const SosState({
    this.countdownSeconds = 0,
    this.triggering = false,
    this.incident,
    this.errorMessage,
    this.ui = SosUiState.idle,
  });

  final int countdownSeconds;
  final bool triggering;
  final api.Incident? incident;
  final String? errorMessage;

  /// Lifecycle UI state driven by WS events. Updates after the local
  /// trigger flow (which uses the REST response above) once the matching
  /// `ride.sos_triggered` / `incident.assigned` / `incident.resolved`
  /// arrives on the bus. Drives [SosBanner].
  final SosUiState ui;

  bool get isCountingDown => countdownSeconds > 0;

  SosState copyWith({
    int? countdownSeconds,
    bool? triggering,
    api.Incident? incident,
    String? errorMessage,
    SosUiState? ui,
  }) {
    return SosState(
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      triggering: triggering ?? this.triggering,
      incident: incident ?? this.incident,
      errorMessage: errorMessage,
      ui: ui ?? this.ui,
    );
  }
}

// OUTSTANDING (MOB-P6 driver parity with passenger):
//   - Driver settings screen does NOT yet expose the SOS privacy opt-ins
//     that the passenger app now has (ambient audio / live location /
//     scene photo). Mirror sos_safety_prefs.dart on the driver side and
//     gate the same data flows behind it.
//   - Counterpart-SOS banner triggered by passenger SOS lands via the
//     WS handlers below; haptic + sound feedback per RFC §P6 still
//     pending (MOB-P6.2).

class SosNotifier extends Notifier<SosState> {
  SosNotifier({SosCounterpartAlert? counterpartAlert})
      : _counterpartAlert = counterpartAlert ?? _defaultCounterpartAlert;

  final SosCounterpartAlert _counterpartAlert;
  Timer? _countdown;
  WsDispatcher? _dispatcher;
  final List<void Function()> _wsDisposers = [];

  @override
  SosState build() {
    _attachWsListeners();
    ref.onDispose(() {
      _countdown?.cancel();
      for (final d in _wsDisposers) {
        d();
      }
      _wsDisposers.clear();
      _dispatcher?.dispose();
      _dispatcher = null;
    });
    return const SosState();
  }

  void _attachWsListeners() {
    final dispatcher = WsDispatcher(ref.read(wsClientProvider));
    _dispatcher = dispatcher;
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.rideSosTriggered,
      (p) {
        final wasActive = state.ui.active;
        state = state.copyWith(
          ui: state.ui.withTrigger(
            incidentId: p['incident_id'] as String?,
            triggeredBy: p['triggered_by'] as String?,
            reason: p['reason'] as String?,
          ),
        );
        // Fire haptic + alert sound exactly once per SOS — only on the
        // OFF→ON edge. Re-applied triggers (e.g. reconnect replay) must
        // NOT re-buzz the device.
        if (!wasActive && state.ui.active) {
          unawaited(_counterpartAlert());
        }
      },
    ));
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.incidentAssigned,
      (p) => state =
          state.copyWith(ui: state.ui.withAssignee(p['assignee_name'] as String?)),
    ));
    _wsDisposers.add(dispatcher.on<BuiltMap<String, Object?>>(
      WsEventType.incidentResolved,
      (_) => state = state.copyWith(ui: state.ui.withResolved()),
    ));
  }

  SOSRepository get _repo => ref.read(sosRepositoryProvider);

  /// Start a 5-second countdown before triggering. User can cancel during.
  void startCountdown(String rideId, {String? reason}) {
    _countdown?.cancel();
    state = state.copyWith(countdownSeconds: 5, errorMessage: null);
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final next = state.countdownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(countdownSeconds: 0);
        await _trigger(rideId, reason: reason);
      } else {
        state = state.copyWith(countdownSeconds: next);
      }
    });
  }

  void cancelCountdown() {
    _countdown?.cancel();
    state = state.copyWith(countdownSeconds: 0);
  }

  Future<void> _trigger(String rideId, {String? reason}) async {
    state = state.copyWith(triggering: true, errorMessage: null);
    try {
      final incident = await _repo.triggerSOS(rideId, reason: reason);
      state = state.copyWith(triggering: false, incident: incident);
    } catch (e) {
      state = state.copyWith(triggering: false, errorMessage: e.toString());
    }
  }
}

final sosNotifierProvider = NotifierProvider<SosNotifier, SosState>(
  SosNotifier.new,
);
