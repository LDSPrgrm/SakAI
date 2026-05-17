import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'otp_repository.dart';

class OtpState {
  const OtpState({
    this.busy = false,
    this.challengeId,
    this.errorMessage,
    this.verified = false,
    this.resendCooldownSeconds = 0,
  });

  final bool busy;
  final String? challengeId;
  final String? errorMessage;
  final bool verified;
  final int resendCooldownSeconds;

  OtpState copyWith({
    bool? busy,
    String? challengeId,
    String? errorMessage,
    bool? verified,
    int? resendCooldownSeconds,
  }) {
    return OtpState(
      busy: busy ?? this.busy,
      challengeId: challengeId ?? this.challengeId,
      errorMessage: errorMessage,
      verified: verified ?? this.verified,
      resendCooldownSeconds:
          resendCooldownSeconds ?? this.resendCooldownSeconds,
    );
  }
}

/// Canonical OTP repository provider. Default throws — each app's root
/// `ProviderScope` must override it with a concrete impl that talks to its
/// `SakaiApiClient`.
final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  throw UnimplementedError(
    'otpRepositoryProvider not overridden. Each app must override it in main.dart',
  );
});

class OtpNotifier extends Notifier<OtpState> {
  Timer? _cooldownTimer;

  @override
  OtpState build() {
    ref.onDispose(() => _cooldownTimer?.cancel());
    return const OtpState();
  }

  OtpRepository get _repo => ref.read(otpRepositoryProvider);

  Future<void> sendCode(String destination) async {
    state = state.copyWith(busy: true, errorMessage: null);
    try {
      final id = await _repo.sendCode(destination: destination);
      state = state.copyWith(busy: false, challengeId: id);
      _startCooldown();
    } on UnimplementedError catch (e) {
      state = state.copyWith(
        busy: false,
        errorMessage: 'Verification not yet available. (${e.message})',
      );
    } catch (e) {
      state = state.copyWith(busy: false, errorMessage: e.toString());
    }
  }

  Future<void> verifyCode(String code) async {
    final id = state.challengeId;
    if (id == null) {
      state = state.copyWith(errorMessage: 'No verification in progress.');
      return;
    }
    state = state.copyWith(busy: true, errorMessage: null);
    try {
      await _repo.verify(challengeId: id, code: code);
      state = state.copyWith(busy: false, verified: true);
    } on UnimplementedError catch (e) {
      state = state.copyWith(
        busy: false,
        errorMessage: 'Verification not yet available. (${e.message})',
      );
    } catch (e) {
      state = state.copyWith(
        busy: false,
        errorMessage: 'Invalid or expired code. Try again.',
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    state = state.copyWith(
      resendCooldownSeconds: 30,
      errorMessage: state.errorMessage,
    );
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendCooldownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(
          resendCooldownSeconds: 0,
          errorMessage: state.errorMessage,
        );
      } else {
        state = state.copyWith(
          resendCooldownSeconds: next,
          errorMessage: state.errorMessage,
        );
      }
    });
  }
}

final otpNotifierProvider = NotifierProvider<OtpNotifier, OtpState>(
  OtpNotifier.new,
);
