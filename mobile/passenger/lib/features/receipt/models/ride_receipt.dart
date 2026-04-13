import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart' show ReceiptResponse;

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
    this.estimatedFare,
    this.actualFare,
    this.fareBreakdown,
  });

  final String rideId;
  final String passengerName;
  final String driverName;
  final String? pickupAddress;
  final String? destinationAddress;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime? completedAt;
  final DateTime? processedAt;
  final double? estimatedFare;
  final double? actualFare;
  final Map<String, dynamic>? fareBreakdown;

  // Convenience getters for UI
  String get paymentMethodLabel => paymentMethod == 'card' ? 'Card' : 'Cash';
  String get paymentStatusLabel =>
      paymentStatus[0].toUpperCase() + paymentStatus.substring(1);
  String? get formattedDate => completedAt != null
      ? DateFormat('MMM d, yyyy • h:mm a').format(completedAt!)
      : null;
  String get totalLabel => '${formatAmount(amount)} $currency';
  String formatAmount(double value) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  factory RideReceipt.fromApiResponse(ReceiptResponse response) {
    return RideReceipt(
      rideId: response.rideId,
      passengerName: response.passengerName,
      driverName: response.driverName,
      pickupAddress: response.pickupAddress,
      destinationAddress: response.destinationAddress,
      amount: response.amount,
      currency: response.currency,
      paymentMethod: response.paymentMethod.toString(),
      paymentStatus: response.paymentStatus.toString(),
      completedAt: response.completedAt,
      processedAt: response.processedAt,
      estimatedFare: null,
      actualFare: null,
      fareBreakdown: null,
    );
  }

  /// Creates a receipt with explicit fare data (used when API response includes them).
  factory RideReceipt.withFareData({
    required String rideId,
    required String passengerName,
    required String driverName,
    String? pickupAddress,
    String? destinationAddress,
    required double amount,
    String currency = 'USD',
    required String paymentMethod,
    required String paymentStatus,
    DateTime? completedAt,
    DateTime? processedAt,
    double? estimatedFare,
    double? actualFare,
    Map<String, dynamic>? fareBreakdown,
  }) {
    return RideReceipt(
      rideId: rideId,
      passengerName: passengerName,
      driverName: driverName,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      completedAt: completedAt,
      processedAt: processedAt,
      estimatedFare: estimatedFare,
      actualFare: actualFare,
      fareBreakdown: fareBreakdown,
    );
  }

  RideReceipt copyWith({
    String? rideId,
    String? passengerName,
    String? driverName,
    String? pickupAddress,
    String? destinationAddress,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? completedAt,
    DateTime? processedAt,
    double? estimatedFare,
    double? actualFare,
    Map<String, dynamic>? fareBreakdown,
  }) {
    return RideReceipt(
      rideId: rideId ?? this.rideId,
      passengerName: passengerName ?? this.passengerName,
      driverName: driverName ?? this.driverName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      completedAt: completedAt ?? this.completedAt,
      processedAt: processedAt ?? this.processedAt,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    );
  }

  bool get hasFareBreakdown =>
      fareBreakdown != null && fareBreakdown!.isNotEmpty;
  bool get hasActualFare => actualFare != null && actualFare! > 0;
}
