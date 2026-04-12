import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_method.dart';
import '../repositories/payment_method_repository.dart';
import 'payment_methods_list_view_model.dart';

/// State of the add payment method operation.
enum AddPaymentMethodStatus { initial, adding, success, error }

class AddPaymentMethodState {
  const AddPaymentMethodState({
    this.status = AddPaymentMethodStatus.initial,
    this.selectedType = DomainPaymentMethodType.card,
    this.cardNumber = '',
    this.expiryMonth = '',
    this.expiryYear = '',
    this.cvv = '',
    this.selectedProvider = '',
    this.eWalletAccountId = '',
    this.setAsDefault = false,
    this.errorMessage,
    this.addedMethod,
  });

  final AddPaymentMethodStatus status;
  final DomainPaymentMethodType selectedType;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String selectedProvider;
  final String eWalletAccountId;
  final bool setAsDefault;
  final String? errorMessage;
  final PaymentMethodModel? addedMethod;

  AddPaymentMethodState copyWith({
    AddPaymentMethodStatus? status,
    DomainPaymentMethodType? selectedType,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    String? selectedProvider,
    String? eWalletAccountId,
    bool? setAsDefault,
    String? errorMessage,
    PaymentMethodModel? addedMethod,
  }) {
    return AddPaymentMethodState(
      status: status ?? this.status,
      selectedType: selectedType ?? this.selectedType,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      eWalletAccountId: eWalletAccountId ?? this.eWalletAccountId,
      setAsDefault: setAsDefault ?? this.setAsDefault,
      errorMessage: errorMessage, // Preserve null unless explicitly set
      addedMethod: addedMethod,
    );
  }

  /// Validation error for the current form state. Returns null if valid.
  String? validate() {
    switch (selectedType) {
      case DomainPaymentMethodType.card:
        return _validateCard();
      case DomainPaymentMethodType.eWallet:
        return _validateEWallet();
      case DomainPaymentMethodType.cash:
        return null; // Cash requires no additional fields
    }
  }

  String? _validateCard() {
    final cardError = PaymentValidation.validateCardNumber(cardNumber);
    if (cardError != null) return cardError;

    final monthError = PaymentValidation.validateExpiryMonth(expiryMonth);
    if (monthError != null) return monthError;

    final yearError = PaymentValidation.validateExpiryYear(expiryYear);
    if (yearError != null) return yearError;

    return null;
  }

  String? _validateEWallet() {
    if (selectedProvider.isEmpty) {
      return 'Please select a provider';
    }
    return PaymentValidation.validateEWalletAccountId(eWalletAccountId);
  }

  /// Returns a formatted card number (digits only).
  String get _cleanCardNumber => cardNumber.replaceAll(RegExp(r'\s'), '');
}

/// Supported e-wallet providers.
class EWalletProviders {
  static const String gcash = 'GCash';
  static const String payMaya = 'PayMaya';
  static const String grabPay = 'GrabPay';

  static const List<String> all = [gcash, payMaya, grabPay];
}

/// Notifier for the add payment method screen.
class AddPaymentMethodNotifier extends Notifier<AddPaymentMethodState> {
  @override
  AddPaymentMethodState build() => const AddPaymentMethodState();

  PaymentMethodRepository get _repository =>
      ref.read(paymentMethodRepositoryProvider);

  /// Sets the selected payment method type.
  void selectType(DomainPaymentMethodType type) {
    state = state.copyWith(selectedType: type, errorMessage: null);
  }

  /// Updates the card number field.
  void updateCardNumber(String value) {
    // Only allow digits and spaces, format in groups of 4
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    final formatted = _formatCardNumber(digits);
    state = state.copyWith(cardNumber: formatted, errorMessage: null);
  }

  /// Updates the expiry month field.
  void updateExpiryMonth(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length <= 2) {
      state = state.copyWith(expiryMonth: digits, errorMessage: null);
    }
  }

  /// Updates the expiry year field.
  void updateExpiryYear(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length <= 2) {
      state = state.copyWith(expiryYear: digits, errorMessage: null);
    }
  }

  /// Updates the CVV field.
  void updateCVV(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length <= 4) {
      state = state.copyWith(cvv: digits, errorMessage: null);
    }
  }

  /// Updates the selected e-wallet provider.
  void selectProvider(String provider) {
    state = state.copyWith(selectedProvider: provider, errorMessage: null);
  }

  /// Updates the e-wallet account ID field.
  void updateEWalletAccountId(String value) {
    state = state.copyWith(eWalletAccountId: value, errorMessage: null);
  }

  /// Toggles the set-as-default checkbox.
  void toggleSetAsDefault(bool value) {
    state = state.copyWith(setAsDefault: value);
  }

  /// Validates the current form. Returns true if valid.
  bool validate() {
    final error = state.validate();
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return false;
    }
    return true;
  }

  /// Adds the payment method.
  Future<bool> addPaymentMethod() async {
    if (!validate()) return false;

    state = state.copyWith(
      status: AddPaymentMethodStatus.adding,
      errorMessage: null,
    );

    try {
      PaymentMethodModel addedMethod;

      switch (state.selectedType) {
        case DomainPaymentMethodType.card:
          // Stub: In production, integrate Stripe SDK to tokenize card details.
          // The cardToken would come from Stripe's paymentSheet or CardField.
          final cardToken = await _stubTokenizeCard();
          addedMethod = await _repository.addPaymentMethod(
            type: DomainPaymentMethodType.card,
            cardToken: cardToken,
            setAsDefault: state.setAsDefault,
          );
          break;

        case DomainPaymentMethodType.eWallet:
          // Stub: In production, integrate provider SDK for OAuth/token flow.
          addedMethod = await _repository.addPaymentMethod(
            type: DomainPaymentMethodType.eWallet,
            provider: state.selectedProvider,
            accountId: state.eWalletAccountId,
            setAsDefault: state.setAsDefault,
          );
          break;

        case DomainPaymentMethodType.cash:
          addedMethod = await _repository.addPaymentMethod(
            type: DomainPaymentMethodType.cash,
            setAsDefault: state.setAsDefault,
          );
          break;
      }

      state = state.copyWith(
        status: AddPaymentMethodStatus.success,
        addedMethod: addedMethod,
      );
      return true;
    } on PaymentMethodError catch (e) {
      debugPrint(
        '[AddPaymentMethodNotifier] Error adding method: ${e.message}',
      );
      state = state.copyWith(
        status: AddPaymentMethodStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('[AddPaymentMethodNotifier] Unexpected error: $e');
      state = state.copyWith(
        status: AddPaymentMethodStatus.error,
        errorMessage: 'Failed to add payment method',
      );
      return false;
    }
  }

  /// Resets the form to initial state.
  void reset() {
    state = const AddPaymentMethodState();
  }

  /// Formats a card number string with spaces every 4 digits.
  String _formatCardNumber(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Stub: Simulates card tokenization via Stripe.
  /// Replace with actual Stripe SDK integration in production.
  Future<String> _stubTokenizeCard() async {
    // In production:
    // 1. Use Stripe's paymentSheet or CardField to collect card details
    // 2. Call stripe.createPaymentMethod() to get a token
    // 3. Return the token ID
    await Future.delayed(const Duration(seconds: 1));
    return 'tok_stub_${state._cleanCardNumber.substring(state._cleanCardNumber.length - 4)}';
  }
}

/// Riverpod provider for the AddPaymentMethodNotifier.
final addPaymentMethodProvider =
    NotifierProvider<AddPaymentMethodNotifier, AddPaymentMethodState>(
      AddPaymentMethodNotifier.new,
    );
