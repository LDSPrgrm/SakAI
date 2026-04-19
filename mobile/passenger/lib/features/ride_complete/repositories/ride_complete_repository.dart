import 'package:sakai_shared/sakai_shared.dart';

/// Abstract repository interface for ride completion operations.
abstract class RideCompleteRepository {
  Future<RideResponse> getRideDetails(String rideId);
  Future<void> submitRating(String rideId, int stars, String? feedback);
  Future<void> addTip(String rideId, double tipAmount);
  Future<ReceiptResponse?> getReceipt(String rideId);
}
