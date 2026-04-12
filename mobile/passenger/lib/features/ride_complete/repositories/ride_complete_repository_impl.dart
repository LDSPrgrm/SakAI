import 'package:dio/dio.dart' show DioException;
import 'package:sakai_shared/sakai_shared.dart';

import 'ride_complete_repository.dart';

/// Implementation of RideCompleteRepository using the generated SakaiApiClient.
class RideCompleteRepositoryImpl implements RideCompleteRepository {
  RideCompleteRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<RideResponse> getRideDetails(String rideId) async {
    final response = await _client.getRidesApi().rideGet(rideId: rideId);
    return response.data!;
  }

  @override
  Future<void> submitRating(String rideId, int stars, String? feedback) async {
    final request = SubmitRatingRequest(
      (SubmitRatingRequestBuilder b) => b
        ..stars = stars
        ..feedback = feedback,
    );
    await _client.getRidesApi().submitRating(
      rideId: rideId,
      submitRatingRequest: request,
    );
  }

  @override
  Future<void> addTip(String rideId, double tipAmount) async {
    final request = AddRideTipRequest(
      (AddRideTipRequestBuilder b) => b..tipAmount = tipAmount,
    );
    await _client.getRidesApi().addRideTip(
      rideId: rideId,
      addRideTipRequest: request,
    );
  }

  @override
  Future<ReceiptResponse?> getReceipt(String rideId) async {
    try {
      final response = await _client.getRidesApi().getRideReceipt(
        rideId: rideId,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
