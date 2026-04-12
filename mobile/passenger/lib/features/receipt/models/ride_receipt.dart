import 'package:sakai_shared/sakai_shared.dart';

/// Domain model for a ride payment receipt.
/// Wraps the generated [ReceiptResponse] with presentation-friendly helpers.
class RideReceipt {
  RideReceipt({
    required this.rideId,
    required this.passengerName,
    required this.driverName,
    this.pickupAddress,
    this.destinationAddress,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    this.completedAt,
    this.processedAt,
  });

  factory RideReceipt.fromApiResponse(ReceiptResponse response) {
    return RideReceipt(
      rideId: response.rideId,
      passengerName: response.passengerName,
      driverName: response.driverName,
      pickupAddress: response.pickupAddress,
      destinationAddress: response.destinationAddress,
      amount: response.amount,
      currency: response.currency,
      paymentMethod: response.paymentMethod,
      paymentStatus: response.paymentStatus,
      completedAt: response.completedAt,
      processedAt: response.processedAt,
    );
  }

  final String rideId;
  final String passengerName;
  final String driverName;
  final String? pickupAddress;
  final String? destinationAddress;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime? completedAt;
  final DateTime? processedAt;

  String get currencySymbol {
    switch (currency.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '\u20AC';
      case 'GBP':
        return '\u00A3';
      case 'JPY':
        return '\u00A5';
      default:
        return currency;
    }
  }

  String formatAmount(double value) {
    return '$currencySymbol${value.toStringAsFixed(2)}';
  }

  String get totalLabel => formatAmount(amount);

  String get paymentMethodLabel {
    switch (paymentMethod.name) {
      case 'cash':
        return 'Paid in Cash';
      case 'card':
        return 'Paid by Card';
      default:
        return paymentMethod.name;
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus.name) {
      case 'completed':
        return 'Payment Complete';
      case 'pending':
        return 'Payment Pending';
      case 'failed':
        return 'Payment Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return paymentStatus.name;
    }
  }

  String? get formattedDate {
    final ts = completedAt ?? processedAt;
    if (ts == null) return null;
    return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'RideReceipt{rideId: $rideId, amount: $totalLabel, '
        'paymentMethod: $paymentMethodLabel, status: $paymentStatusLabel}';
  }
}
