/// Domain model for a payment method in the passenger app.
/// Wraps the generated [PaymentMethodDetails] from the API client with
/// additional display helpers and validation tailored for the mobile UI.
library;

import 'package:flutter/material.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;

/// Payment method type enum with display helpers.
enum DomainPaymentMethodType {
  card('Card', 'credit_card'),
  eWallet('E-Wallet', 'account_balance_wallet'),
  cash('Cash', 'payments');

  const DomainPaymentMethodType(this.label, this.iconName);
  final String label;
  final String iconName;

  /// Convert from generated [api.PaymentMethodType] to domain enum.
  static DomainPaymentMethodType fromApi(api.PaymentMethodType apiType) {
    switch (apiType.name) {
      case 'card':
        return DomainPaymentMethodType.card;
      case 'e_wallet':
        return DomainPaymentMethodType.eWallet;
      case 'cash':
        return DomainPaymentMethodType.cash;
      default:
        return DomainPaymentMethodType.cash;
    }
  }

  /// Convert to generated [api.PaymentMethodType] for API calls.
  api.PaymentMethodType toApi() {
    switch (this) {
      case DomainPaymentMethodType.card:
        return api.PaymentMethodType.card;
      case DomainPaymentMethodType.eWallet:
        return api.PaymentMethodType.eWallet;
      case DomainPaymentMethodType.cash:
        return api.PaymentMethodType.cash;
    }
  }
}

/// Domain model for a saved payment method.
class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.type,
    required this.isDefault,
    required this.createdAt,
    this.cardDetails,
    this.eWalletDetails,
  });

  final String id;
  final DomainPaymentMethodType type;
  final bool isDefault;
  final DateTime createdAt;
  final api.CardDetails? cardDetails;
  final api.EWalletDetails? eWalletDetails;

  /// Display name for the payment method.
  /// Card: "Visa .... 1234"
  /// E-Wallet: "GCash - 09123456789"
  /// Cash: "Cash"
  String get displayName {
    switch (type) {
      case DomainPaymentMethodType.card:
        if (cardDetails != null) {
          return '${cardDetails!.brand.capitalize} .... ${cardDetails!.last4}';
        }
        return 'Card ....';
      case DomainPaymentMethodType.eWallet:
        if (eWalletDetails != null) {
          return '${eWalletDetails!.provider} - ${eWalletDetails!.accountId}';
        }
        return 'E-Wallet';
      case DomainPaymentMethodType.cash:
        return 'Cash';
    }
  }

  /// Icon data for the payment method type.
  IconData get icon {
    switch (type) {
      case DomainPaymentMethodType.card:
        return Icons.credit_card;
      case DomainPaymentMethodType.eWallet:
        return Icons.account_balance_wallet;
      case DomainPaymentMethodType.cash:
        return Icons.payments;
    }
  }

  bool get isCard => type == DomainPaymentMethodType.card;
  bool get isEWallet => type == DomainPaymentMethodType.eWallet;
  bool get isCash => type == DomainPaymentMethodType.cash;

  /// Creates a copy with the given fields replaced.
  PaymentMethodModel copyWith({
    String? id,
    DomainPaymentMethodType? type,
    bool? isDefault,
    DateTime? createdAt,
    api.CardDetails? cardDetails,
    api.EWalletDetails? eWalletDetails,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      cardDetails: cardDetails ?? this.cardDetails,
      eWalletDetails: eWalletDetails ?? this.eWalletDetails,
    );
  }

  /// Factory constructor from the generated API PaymentMethodDetails.
  factory PaymentMethodModel.fromApiPaymentMethod(
    api.PaymentMethodDetails apiMethod,
  ) {
    return PaymentMethodModel(
      id: apiMethod.id,
      type: DomainPaymentMethodType.fromApi(apiMethod.type),
      isDefault: apiMethod.isDefault,
      createdAt: apiMethod.createdAt,
      cardDetails: apiMethod.card,
      eWalletDetails: apiMethod.eWallet,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          isDefault == other.isDefault &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ isDefault.hashCode ^ createdAt.hashCode;
}

extension _StringCapitalize on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Validation helpers for payment method form fields.
class PaymentValidation {
  /// Validates card number: must be 13-19 digits.
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) {
      return 'Enter a valid card number (13-19 digits)';
    }
    return null;
  }

  /// Validates card expiry month: 1-12.
  static String? validateExpiryMonth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry month is required';
    }
    final month = int.tryParse(value.trim());
    if (month == null || month < 1 || month > 12) {
      return 'Enter a valid month (01-12)';
    }
    return null;
  }

  /// Validates card expiry year: must be current year or later.
  static String? validateExpiryYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry year is required';
    }
    final year = int.tryParse(value.trim());
    final currentYear = DateTime.now().year % 100;
    if (year == null || year < currentYear) {
      return 'Card has expired';
    }
    return null;
  }

  /// Validates e-wallet account ID: must not be empty.
  static String? validateEWalletAccountId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account ID or phone number is required';
    }
    return null;
  }

  /// Validates a card's CVV (optional for some flows, required for others).
  static String? validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(value.trim())) {
      return 'Enter a valid CVV (3-4 digits)';
    }
    return null;
  }
}
