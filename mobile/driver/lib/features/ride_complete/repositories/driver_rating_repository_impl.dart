import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:sakai_shared/sakai_shared.dart';

import '../models/driver_rating_exception.dart';
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
      throw _fromDio(e);
    }
  }

  DriverRatingException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return DriverRatingException(
          machineCode: err.code.name,
          userMessage: _friendlyMessage(err.code),
        );
      } catch (_) {
        /* fall through */
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const DriverRatingException(
        userMessage: 'Connection timed out. Please try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const DriverRatingException(
        userMessage: 'No connection. Check your network and try again.',
      );
    }
    return DriverRatingException(
      userMessage: e.message ?? 'Failed to submit rating. Please try again.',
    );
  }

  String _friendlyMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.ALREADY_RATED:
        return 'You have already rated this passenger.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many requests. Please wait a moment and try again.';
      default:
        return 'Failed to submit rating. Please try again.';
    }
  }
}
