import '../models/ride_detail.dart';
import '../models/ride_history_item.dart';

/// Abstract repository interface for ride history operations.
abstract class RideHistoryRepository {
  /// Fetch a paginated list of the user's rides.
  /// [page] is 1-based, [limit] defaults to 20.
  /// [status] optional filter (e.g. 'completed', 'cancelled').
  Future<List<RideHistoryItem>> getRideHistory({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// Returns whether there are more pages available.
  bool get hasMore;

  /// Fetch full detail for a single ride.
  Future<RideDetail> getRideDetail(String rideId);
}
