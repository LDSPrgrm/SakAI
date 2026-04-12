import '../models/ride_receipt.dart';

/// Abstract repository interface for receipt operations.
abstract class ReceiptRepository {
  /// Fetch the payment receipt for a completed ride.
  Future<RideReceipt> getReceipt(String rideId);
}
