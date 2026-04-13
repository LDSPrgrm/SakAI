/// Abstract repository interface for driver rating operations.
abstract class DriverRatingRepository {
  Future<void> submitRating(String rideId, int stars, String? feedback);
}
