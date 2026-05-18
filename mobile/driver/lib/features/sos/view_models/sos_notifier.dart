import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/repositories/sos_repository.dart';

import '../../../app/providers.dart';

class SosState {
  const SosState({
    this.countdownSeconds = 0,
    this.triggering = false,
    this.incident,
    this.errorMessage,
  });

  final int countdownSeconds;
  final bool triggering;
  final api.Incident? incident;
  final String? errorMessage;

  bool get isCountingDown => countdownSeconds > 0;

  SosState copyWith({
    int? countdownSeconds,
    bool? triggering,
    api.Incident? incident,
    String? errorMessage,
  }) {
    return SosState(
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      triggering: triggering ?? this.triggering,
      incident: incident ?? this.incident,
      errorMessage: errorMessage,
    );
  }
}

class SosNotifier extends Notifier<SosState> {
  Timer? _countdown;

  @override
  SosState build() {
    ref.onDispose(() => _countdown?.cancel());
    return const SosState();
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
