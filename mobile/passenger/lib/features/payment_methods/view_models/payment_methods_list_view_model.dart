import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import '../../../app/providers.dart';

/// State of the payment methods list.
enum PaymentMethodsStatus { initial, loading, loaded, error }

class PaymentMethodsListState {
  const PaymentMethodsListState({
    this.status = PaymentMethodsStatus.initial,
    this.methods = const [],
    this.errorMessage,
    this.lastRemovedMethod,
  });

  final PaymentMethodsStatus status;
  final List<PaymentMethodModel> methods;
  final String? errorMessage;
  final PaymentMethodModel? lastRemovedMethod;

  PaymentMethodsListState copyWith({
    PaymentMethodsStatus? status,
    List<PaymentMethodModel>? methods,
    String? errorMessage,
    PaymentMethodModel? lastRemovedMethod,
  }) {
    return PaymentMethodsListState(
      status: status ?? this.status,
      methods: methods ?? this.methods,
      errorMessage: errorMessage,
      lastRemovedMethod: lastRemovedMethod,
    );
  }

  /// Returns the list with the default method first.
  List<PaymentMethodModel> get sortedMethods {
    final sorted = [...methods];
    sorted.sort((a, b) {
      if (a.isDefault) return -1;
      if (b.isDefault) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }
}

/// Riverpod provider for the PaymentMethodRepository.
final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((
  ref,
) {
  return PaymentMethodRepositoryImpl(ref.watch(apiClientProvider));
});

/// Notifier for the payment methods list screen.
class PaymentMethodsListNotifier extends Notifier<PaymentMethodsListState> {
  @override
  PaymentMethodsListState build() => const PaymentMethodsListState();

  PaymentMethodRepository get _repository =>
      ref.read(paymentMethodRepositoryProvider);

  /// Loads the list of payment methods.
  Future<void> loadMethods() async {
    state = const PaymentMethodsListState(status: PaymentMethodsStatus.loading);

    try {
      final methods = await _repository.getPaymentMethods();
      state = PaymentMethodsListState(
        status: PaymentMethodsStatus.loaded,
        methods: methods,
      );
    } on PaymentMethodError catch (e) {
      debugPrint(
        '[PaymentMethodsListNotifier] Error loading methods: ${e.message}',
      );
      state = PaymentMethodsListState(
        status: PaymentMethodsStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      debugPrint('[PaymentMethodsListNotifier] Unexpected error: $e');
      state = const PaymentMethodsListState(
        status: PaymentMethodsStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Removes a payment method by ID.
  Future<bool> removeMethod(String methodId) async {
    try {
      final removedMethod = state.methods.firstWhere(
        (m) => m.id == methodId,
        orElse: () => PaymentMethodModel(
          id: '',
          type: DomainPaymentMethodType.cash,
          isDefault: false,
          createdAt: DateTime.now(),
        ),
      );

      await _repository.removePaymentMethod(methodId);

      // Update state immediately with the removed method removed from list
      final updatedMethods = state.methods
          .where((m) => m.id != methodId)
          .toList();

      state = state.copyWith(
        status: PaymentMethodsStatus.loaded,
        methods: updatedMethods,
        lastRemovedMethod: removedMethod,
      );

      return true;
    } on PaymentMethodError catch (e) {
      debugPrint(
        '[PaymentMethodsListNotifier] Error removing method: ${e.message}',
      );
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      debugPrint('[PaymentMethodsListNotifier] Unexpected error: $e');
      state = state.copyWith(errorMessage: 'Failed to remove payment method');
      return false;
    }
  }

  /// Sets a payment method as the default.
  Future<bool> setDefault(String methodId) async {
    try {
      await _repository.setAsDefault(methodId);

      // Update the state to reflect the new default
      final updatedMethods = state.methods.map((m) {
        if (m.id == methodId) {
          return m.copyWith(isDefault: true);
        }
        return m.copyWith(isDefault: false);
      }).toList();

      state = state.copyWith(methods: updatedMethods);
      return true;
    } on PaymentMethodError catch (e) {
      debugPrint(
        '[PaymentMethodsListNotifier] Error setting default: ${e.message}',
      );
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      debugPrint('[PaymentMethodsListNotifier] Unexpected error: $e');
      state = state.copyWith(
        errorMessage: 'Failed to set default payment method',
      );
      return false;
    }
  }

  /// Refreshes the payment methods list.
  Future<void> refresh() async {
    await loadMethods();
  }

  /// Clears the last removed method (for UI cleanup).
  void clearLastRemovedMethod() {
    state = state.copyWith(lastRemovedMethod: null);
  }
}

/// Riverpod provider for the PaymentMethodsListNotifier.
final paymentMethodsListProvider =
    NotifierProvider<PaymentMethodsListNotifier, PaymentMethodsListState>(
      PaymentMethodsListNotifier.new,
    );
