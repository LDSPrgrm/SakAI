import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/cancellation_details.dart';
import 'cancelled_ride_repository.dart';

/// Implementation of [CancelledRideRepository] using the generated SakaiApiClient.
class CancelledRideRepositoryImpl implements CancelledRideRepository {
  CancelledRideRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<CancellationDetails> getCancellationDetails(String rideId) async {
    try {
      final response = await _client.getRidesApi().rideGet(rideId: rideId);
      final data = response.data;
      if (data == null) {
        throw const CancelledRideException(
          userMessage: 'Ride details not found.',
          machineCode: 'RIDE_NOT_FOUND',
        );
      }
      return CancellationDetails.fromRideResponse(data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  @override
  Future<void> cancelRide(
    String rideId, {
    String? reasonCode,
    String? reasonText,
  }) async {
    debugPrint(
      '[CANCELLED_RIDE_REPO] Cancelling ride: $rideId, reasonCode: $reasonCode',
    );
    try {
      // Send cancellation request with reason_code and reason_text directly
      // using Dio to bypass stale generated CancelRequest model
      final dio = _client.dio;
      final response = await dio.post(
        '/rides/$rideId/cancel',
        data: <String, dynamic>{
          'reason_code': reasonCode,
          if (reasonText != null) 'reason_text': reasonText,
        },
      );
      debugPrint(
        '[CANCELLED_RIDE_REPO] Cancel ride succeeded (HTTP ${response.statusCode})',
      );
    } on DioException catch (e) {
      debugPrint(
        '[CANCELLED_RIDE_REPO] Cancel ride failed (Dio): ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.data != null) {
        debugPrint('[CANCELLED_RIDE_REPO] Error body: ${e.response?.data}');
      }
      throw _fromDio(e);
    } catch (e, st) {
      debugPrint('[CANCELLED_RIDE_REPO] Cancel ride failed (Unexpected): $e');
      debugPrint('[CANCELLED_RIDE_REPO] Stack: $st');
      rethrow;
    }
  }

  CancelledRideException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return CancelledRideException(
          userMessage: _friendlyMessage(err.code),
          machineCode: err.code.name,
        );
      } catch (_) {
        // fall through
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const CancelledRideException(
        userMessage: 'Connection timed out. Try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const CancelledRideException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }

    return CancelledRideException(
      userMessage: e.message ?? 'Something went wrong. Try again.',
    );
  }

  String _friendlyMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.RIDE_NOT_FOUND:
        return 'Ride not found.';
      case ErrorCode.FORBIDDEN:
        return 'You do not have permission to view this ride.';
      case ErrorCode.TOKEN_INVALID:
      case ErrorCode.TOKEN_EXPIRED:
        return 'Session expired. Please log in again.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many requests. Please wait a moment.';
      default:
        return 'Failed to load cancellation details. Please try again.';
    }
  }
}
