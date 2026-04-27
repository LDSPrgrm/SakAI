import 'package:built_value/serializer.dart' show FullType;
import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:sakai_shared/sakai_shared.dart';

import '../models/ride_receipt.dart';
import 'receipt_repository.dart';

/// Implementation of [ReceiptRepository] using the generated SakaiApiClient.
class ReceiptRepositoryImpl implements ReceiptRepository {
  ReceiptRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<RideReceipt> getReceipt(String rideId) async {
    try {
      final response = await _client.getRidesApi().getRideReceipt(
        rideId: rideId,
      );
      final data = response.data;
      if (data == null) {
        throw ReceiptException(
          userMessage: 'Receipt not found.',
          machineCode: ErrorCode.RIDE_NOT_FOUND.name,
        );
      }
      return RideReceipt.fromApiResponse(data);
    } on DioException catch (e) {
      throw _fromDio(e);
    }
  }

  ReceiptException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return ReceiptException(
          userMessage: _friendlyMessage(err.code),
          machineCode: err.code.name,
        );
      } catch (_) {
        // fall through to generic message
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ReceiptException(
        userMessage: 'Connection timed out. Try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ReceiptException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }

    return ReceiptException(
      userMessage: e.message ?? 'Something went wrong. Try again.',
    );
  }

  String _friendlyMessage(ErrorCode code) {
    switch (code) {
      case ErrorCode.RIDE_NOT_FOUND:
        return 'Ride not found.';
      case ErrorCode.FORBIDDEN:
        return 'You do not have permission to view this receipt.';
      case ErrorCode.TOKEN_INVALID:
      case ErrorCode.TOKEN_EXPIRED:
        return 'Session expired. Please log in again.';
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return 'Too many requests. Please wait a moment.';
      default:
        return 'Failed to load receipt. Please try again.';
    }
  }
}

/// Custom domain error for receipt operations.
class ReceiptException implements Exception {
  const ReceiptException({required this.userMessage, this.machineCode});

  final String userMessage;
  final String? machineCode;

  @override
  String toString() => 'ReceiptException[$machineCode]: $userMessage';
}
