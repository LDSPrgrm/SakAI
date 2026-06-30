import 'package:sakai_api_client/sakai_api_client.dart' as api;

abstract class RideHistoryRepository {
  Future<List<api.RideResponse>> getRideHistory({
    int? page,
    int? limit,
    String? status,
  });
}
