import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart' show sosRepositoryProvider;

enum SupportStatus { initial, submitting, success, error }

class SupportState {
  final SupportStatus status;
  final String? error;
  final bool submitted;

  const SupportState({
    this.status = SupportStatus.initial,
    this.error,
    this.submitted = false,
  });

  SupportState copyWith({
    SupportStatus? status,
    String? error,
    bool? submitted,
    bool clearError = false,
  }) {
    return SupportState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      submitted: submitted ?? this.submitted,
    );
  }
}

final supportViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  final sosRepo = ref.watch(sosRepositoryProvider);
  return SupportViewModel(sosRepo);
});

class SupportViewModel extends ChangeNotifier {
  SupportViewModel(this._sosRepo);

  final SOSRepository _sosRepo;

  SupportState _state = const SupportState();
  SupportState get state => _state;

  String _subject = '';
  String _message = '';

  String get subject => _subject;
  String get message => _message;

  bool get isValid => _subject.trim().isNotEmpty && _message.trim().isNotEmpty;

  void updateSubject(String value) {
    _subject = value;
    notifyListeners();
  }

  void updateMessage(String value) {
    _message = value;
    notifyListeners();
  }

  Future<void> submitTicket() async {
    if (!isValid) return;

    _state = _state.copyWith(status: SupportStatus.submitting, clearError: true);
    notifyListeners();

    try {
      // Simulate sending a support ticket
      await Future.delayed(const Duration(seconds: 2));
      _state = _state.copyWith(status: SupportStatus.success, submitted: true);
      _subject = '';
      _message = '';
    } catch (e) {
      _state = _state.copyWith(
        status: SupportStatus.error,
        error: 'Failed to submit support ticket.',
      );
    }
    notifyListeners();
  }

  Future<void> triggerSOS(String rideId, String reason) async {
    _state = _state.copyWith(status: SupportStatus.submitting, clearError: true);
    notifyListeners();

    try {
      await _sosRepo.triggerSOS(rideId, reason: reason);
      _state = _state.copyWith(status: SupportStatus.success);
    } catch (e) {
      _state = _state.copyWith(
        status: SupportStatus.error,
        error: 'Failed to trigger emergency SOS.',
      );
    }
    notifyListeners();
  }

  void resetState() {
    _state = const SupportState();
    _subject = '';
    _message = '';
    notifyListeners();
  }
}
