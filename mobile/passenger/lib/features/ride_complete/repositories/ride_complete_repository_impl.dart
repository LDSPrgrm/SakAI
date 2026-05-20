import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:sakai_shared/sakai_shared.dart';

import '../models/rating_exception.dart';
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
    } on DioException catch (_) {
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
      throw _fromDio(e);
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
    } on DioException catch (_) {
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
      rethrow;
    }
  }

  RatingException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return RatingException(
          machineCode: err.code.name,
          userMessage: _friendlyMessage(err.code),
        );
      } catch (_) {
        /* fall through */
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const RatingException(
        userMessage: 'Connection timed out. Please try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const RatingException(
        userMessage: 'No connection. Check your network and try again.',
      );
    }
    return RatingException(
      userMessage: e.message ?? 'Failed to submit rating. Please try again.',
    );
  }

  String _friendlyMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.ALREADY_RATED:
        return 'You have already rated this ride.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many requests. Please wait a moment and try again.';
      default:
        return 'Failed to submit rating. Please try again.';
    }
  }
}
