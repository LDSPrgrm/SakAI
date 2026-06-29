import 'package:sakai_api_client/sakai_api_client.dart';
import '../models/session_earnings.dart';

abstract class EarningsRepository {
  Future<SessionEarnings> getEarnings({
    DateTime? from,
    DateTime? to,
    int page = 1,
  });
}

class EarningsRepositoryImpl implements EarningsRepository {
  final SakaiApiClient _apiClient;

  EarningsRepositoryImpl(this._apiClient);

  @override
  Future<SessionEarnings> getEarnings({
    DateTime? from,
    DateTime? to,
    int page = 1,
  }) async {
    final response = await _apiClient.getDriverApi().driverGetEarnings(
      from: from != null ? Date(from.year, from.month, from.day) : null,
      to: to != null ? Date(to.year, to.month, to.day) : null,
      page: page,
    );

    final earningsList = response.data?.data;
    if (earningsList == null) {
      return const SessionEarnings();
    }

    final breakdowns = earningsList
        .map(
          (e) => RideBreakdown(
            rideId: e.rideId,
            fare: e.fareAmount,
            tip: e.tipAmount,
            completedAt: e.completedAt,
          ),
        )
        .toList();

    // We use totalItems from pagination as completedRidesCount
    // For totalEarnings, we calculate the sum of the retrieved items on this page
    // as the API does not currently provide a global sum in this response.
    final totalEarnings = breakdowns.fold<double>(
      0.0,
      (val, e) => val + e.total,
    );

    return SessionEarnings(
      completedRidesCount: response.data?.pagination?.totalItems ?? 0,
      totalEarnings: totalEarnings,
      rideBreakdowns: breakdowns,
    );
  }
}
