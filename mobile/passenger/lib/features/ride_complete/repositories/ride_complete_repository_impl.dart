import 'package:dio/dio.dart' show DioException;
import 'package:sakai_shared/sakai_shared.dart';

import 'ride_complete_repository.dart';

/// Implementation of RideCompleteRepository using the generated SakaiApiClient.
class RideCompleteRepositoryImpl implements RideCompleteRepository {
  RideCompleteRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<RideResponse> getRideDetails(String rideId) async {
    try {
      final response = await _client.getRidesApi().rideGet(rideId: rideId);
      return response.data!;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return _rideFromJson(data);
        }
      }
      rethrow;
    }
  }

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

  @override
  Future<void> addTip(String rideId, double tipAmount) async {
    try {
      final request = AddRideTipRequest(
        (AddRideTipRequestBuilder b) => b..tipAmount = tipAmount,
      );
      await _client.getRidesApi().addRideTip(
        rideId: rideId,
        addRideTipRequest: request,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) return;
      rethrow;
    }
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
      // 2xx = success even if body parsing fails.
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        return null;
      }
      rethrow;
    }
  }

  // ── Fallback JSON parsing for when generated client fails on 2xx ───────

  RideResponse _rideFromJson(Map<String, dynamic> json) {
    return $RideResponse(
      (b) => b
        ..id = json['id'] as String
        ..status = RideStatus.valueOf(json['status'] as String)
        ..origin.replace(
          LatLng(
            (ob) => ob
              ..lat = (json['origin']['lat'] as num).toDouble()
              ..lng = (json['origin']['lng'] as num).toDouble(),
          ),
        )
        ..destination.replace(
          LatLng(
            (db) => db
              ..lat = (json['destination']['lat'] as num).toDouble()
              ..lng = (json['destination']['lng'] as num).toDouble(),
          ),
        )
        ..originAddress = json['origin_address'] as String?
        ..destinationAddress = json['destination_address'] as String?
        ..createdAt = DateTime.parse(json['created_at'] as String)
        ..updatedAt = DateTime.parse(json['updated_at'] as String),
    );
  }
}
