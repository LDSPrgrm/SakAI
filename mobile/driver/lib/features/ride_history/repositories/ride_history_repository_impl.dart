import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:driver/features/ride_history/repositories/ride_history_repository.dart';

class RideHistoryRepositoryImpl implements RideHistoryRepository {
  final api.DriverApi _driverApi;

  RideHistoryRepositoryImpl(this._driverApi);

  @override
  Future<List<api.RideResponse>> getRideHistory({
    int? page,
    int? limit,
    String? status,
  }) async {
    try {
      final response = await _driverApi.adminListDriverRides(
        page: page,
        limit: limit,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!.rides?.toList() ?? [];
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}
