import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers.dart';

class DriverHomeState {
  final bool online;
  final bool loading;
  final String? errorMessage;

  const DriverHomeState({
    required this.online,
    required this.loading,
    this.errorMessage,
  });

  DriverHomeState copyWith({
    bool? online,
    bool? loading,
    String? errorMessage,
  }) {
    return DriverHomeState(
      online: online ?? this.online,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }
}

final driverHomeNotifierProvider =
    NotifierProvider<DriverHomeNotifier, DriverHomeState>(() {
      return DriverHomeNotifier();
    });

class DriverHomeNotifier extends Notifier<DriverHomeState> {
  @override
  DriverHomeState build() {
    return const DriverHomeState(online: false, loading: false);
  }

  Future<void> toggleStatus() async {
    if (state.loading) return;

    final repo = ref.read(driverRepositoryProvider);
    final targetOnline = !state.online;

    state = state.copyWith(loading: true, errorMessage: null);

    try {
      if (targetOnline) {
        await repo.goOnline();
      } else {
        await repo.goOffline();
      }
      state = state.copyWith(online: targetOnline, loading: false);
    } on Exception catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
