import 'package:dio/dio.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'driver_rating_repository.dart';

/// Implementation of DriverRatingRepository using the generated SakaiApiClient.
class DriverRatingRepositoryImpl implements DriverRatingRepository {
  DriverRatingRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<void> submitRating(String rideId, int stars, String? feedback) async {
    try {
      final request = SubmitRatingRequest(
        (SubmitRatingRequestBuilder b) => b
          ..stars = stars
          ..feedback = feedback,
      );
      await _client.getRidesApi().submitRating(
        rideId: rideId,
        submitRatingRequest: request,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      rethrow;
    }
  }
}
