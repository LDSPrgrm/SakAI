import 'package:built_value/serializer.dart' show FullType;
import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:sakai_shared/sakai_shared.dart';

import '../models/ride_detail.dart';
import '../models/ride_history_item.dart';
import 'ride_history_repository.dart';

/// Implementation of [RideHistoryRepository] using the generated SakaiApiClient.
class RideHistoryRepositoryImpl implements RideHistoryRepository {
  RideHistoryRepositoryImpl(this._client);

  final SakaiApiClient _client;
  bool _hasMore = true;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<List<RideHistoryItem>> getRideHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _client.getRidesApi().rideList(
        page: page,
        limit: limit,
        status: status,
      );

      final data = response.data;
      if (data == null) {
        _hasMore = false;
        return [];
      }

      final pagination = data.pagination;
      _hasMore = (pagination.currentPage ?? 1) < (pagination.totalPages ?? 1);

      return data.data
          .map((item) => RideHistoryItem.fromUserRideItem(item))
          .toList();
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails.
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        _hasMore = false;
        return [];
      }
      throw _fromDio(e);
    }
  }

  @override
  Future<RideDetail> getRideDetail(String rideId) async {
    try {
      final response = await _client.getRidesApi().rideGet(rideId: rideId);
      final data = response.data;
      if (data == null) {
        throw RideHistoryException(
          userMessage: 'Ride details not found.',
          machineCode: ErrorCode.RIDE_NOT_FOUND.name,
        );
      }
      return RideDetail.fromRideResponse(data);
    } on DioException catch (e) {
      // 2xx = success even if body parsing fails.
      final statusCode = e.response?.statusCode;
      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final ride = _rideFromJson(data);
          return RideDetail.fromRideResponse(ride);
        }
      }
      throw _fromDio(e);
    }
  }

  RideHistoryException _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return RideHistoryException(
          userMessage: _friendlyMessage(err.code),
          machineCode: err.code.name,
        );
      } catch (_) {
        // fall through
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const RideHistoryException(
        userMessage: 'Connection timed out. Try again.',
      );
    }
    if (e.type == DioExceptionType.connectionError) {
      return const RideHistoryException(
        userMessage: 'No connection. Check network or server URL.',
      );
    }

    return RideHistoryException(
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
        return 'Failed to load ride data. Please try again.';
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

/// Custom domain error for ride history operations.
class RideHistoryException implements Exception {
  const RideHistoryException({required this.userMessage, this.machineCode});

  final String userMessage;
  final String? machineCode;

  @override
  String toString() => 'RideHistoryException[$machineCode]: $userMessage';
}
