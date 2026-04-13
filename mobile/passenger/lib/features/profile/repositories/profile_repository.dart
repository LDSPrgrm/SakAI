import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../models/user_profile.dart';

/// Domain error types for profile operations.
sealed class ProfileError {
  const ProfileError({required this.message});
  final String message;
}

class ProfileNetworkError extends ProfileError {
  const ProfileNetworkError({required super.message});
}

class ProfileServerError extends ProfileError {
  const ProfileServerError({required super.message, this.code});
  final ErrorCode? code;
}

class ProfileNotFoundError extends ProfileError {
  const ProfileNotFoundError({required super.message});
}

class ProfileValidationError extends ProfileError {
  const ProfileValidationError({required super.message, this.code});
  final ErrorCode? code;
}

/// Repository interface for profile operations.
abstract class ProfileRepository {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({String? name, String? phone});
}

/// Implementation using the generated SakaiApiClient.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      debugPrint('[ProfileRepo] Fetching profile: GET /users/me');
      final response = await _client.getUsersApi().usersGetMe();
      final apiProfile = response.data;
      if (apiProfile == null) {
        throw const ProfileNotFoundError(message: 'Profile not found');
      }

      // Attempt to fetch rating as well
      double? rating;
      try {
        final ratingResponse = await _client.getUsersApi().getUserRating(
          userId: apiProfile.id,
        );
        rating = ratingResponse.data?.averageRating;
      } catch (e) {
        debugPrint('[ProfileRepo] Could not fetch rating: $e');
      }

      debugPrint(
        '[ProfileRepo] Profile fetched successfully for ${apiProfile.name}',
      );
      return UserProfileModel.fromApiUserProfile(apiProfile, rating: rating);
    } on DioException catch (e) {
      debugPrint('[ProfileRepo] DioException: ${e.type} - ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile({String? name, String? phone}) async {
    // The current API client does not have a PUT /users/me endpoint.
    // When it becomes available, use _client.getUsersApi().usersUpdateMe(...)
    // For now, this is a placeholder that returns the current profile.
    debugPrint(
      '[ProfileRepo] updateProfile called (name: $name, phone: $phone)',
    );
    debugPrint(
      '[ProfileRepo] Warning: PUT /users/me not yet available in API client',
    );

    // Fetch current profile to return
    return getProfile();
  }

  ProfileError _fromDio(DioException e) {
    final data = e.response?.data;
    if (data != null) {
      try {
        final err =
            standardSerializers.deserialize(
                  data,
                  specifiedType: const FullType(ErrorResponse),
                )
                as ErrorResponse;
        return _mapErrorCode(err);
      } catch (_) {
        // Fall through to generic handling
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ProfileNetworkError(
          message: 'Connection timed out. Try again.',
        );
      case DioExceptionType.connectionError:
        return const ProfileNetworkError(
          message: 'No connection. Check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const ProfileServerError(
            message: 'Session expired. Please log in again.',
            code: ErrorCode.TOKEN_INVALID,
          );
        }
        return ProfileServerError(
          message: e.message ?? 'Server error. Try again.',
        );
      default:
        return ProfileServerError(
          message: e.message ?? 'Something went wrong. Try again.',
        );
    }
  }

  ProfileError _mapErrorCode(ErrorResponse err) {
    switch (err.code) {
      case ErrorCode.TOKEN_INVALID:
      case ErrorCode.TOKEN_EXPIRED:
        return ProfileServerError(
          message: 'Session expired. Please log in again.',
          code: err.code,
        );
      case ErrorCode.USER_NOT_FOUND:
        return const ProfileNotFoundError(message: 'Profile not found');
      case ErrorCode.VALIDATION_ERROR:
        return ProfileValidationError(message: err.message, code: err.code);
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return const ProfileServerError(
          message: 'Too many attempts. Wait a moment and try again.',
          code: ErrorCode.RATE_LIMIT_EXCEEDED,
        );
      case ErrorCode.INTERNAL_SERVER_ERROR:
        return const ProfileServerError(
          message: 'Server error. Please try again later.',
          code: ErrorCode.INTERNAL_SERVER_ERROR,
        );
      default:
        return ProfileServerError(message: err.message, code: err.code);
    }
  }
}
