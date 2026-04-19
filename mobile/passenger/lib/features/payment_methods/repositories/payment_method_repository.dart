// ignore_for_file: unchecked_use_of_nullable_value
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import '../models/payment_method.dart';

/// Domain error types for payment method operations.
sealed class PaymentMethodError {
  const PaymentMethodError({required this.message, this.code});
  final String message;
  final ErrorCode? code;
}

class PaymentMethodNetworkError extends PaymentMethodError {
  const PaymentMethodNetworkError({required super.message});
}

class PaymentMethodServerError extends PaymentMethodError {
  const PaymentMethodServerError({required super.message, super.code});
}

class PaymentMethodNotFoundError extends PaymentMethodError {
  const PaymentMethodNotFoundError({required super.message});
}

class PaymentMethodDuplicateError extends PaymentMethodError {
  const PaymentMethodDuplicateError({required super.message});
}

class PaymentMethodUnsupportedError extends PaymentMethodError {
  const PaymentMethodUnsupportedError({required super.message});
}

class PaymentMethodLastMethodError extends PaymentMethodError {
  const PaymentMethodLastMethodError({required super.message});
}

class PaymentMethodValidationError extends PaymentMethodError {
  const PaymentMethodValidationError({required super.message});
}

/// Repository interface for payment method operations.
abstract class PaymentMethodRepository {
  /// Fetches the list of saved payment methods for the current user.
  Future<List<PaymentMethodModel>> getPaymentMethods();

  /// Adds a new payment method.
  /// [type] - The type of payment method (card, eWallet, cash).
  /// [cardToken] - Payment gateway token for cards (required if type == card).
  /// [provider] - E-wallet provider name (required if type == eWallet).
  /// [accountId] - E-wallet account ID (required if type == eWallet).
  /// [setAsDefault] - Whether to set this as the default method.
  Future<PaymentMethodModel> addPaymentMethod({
    required DomainPaymentMethodType type,
    String? cardToken,
    String? provider,
    String? accountId,
    bool setAsDefault = false,
  });

  /// Removes a payment method by ID.
  Future<void> removePaymentMethod(String methodId);

  /// Sets a payment method as the default.
  Future<PaymentMethodModel> setAsDefault(String methodId);
}

/// Implementation using the generated SakaiApiClient.
class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  PaymentMethodRepositoryImpl(this._client);

  final SakaiApiClient _client;

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      debugPrint(
        '[PaymentMethodRepo] Fetching payment methods: GET /users/me/payment-methods',
      );
      final response = await _client.getUsersApi().paymentMethodsList();
      final listResponse = response.data;
      if (listResponse == null) {
        return [];
      }

      final methods = listResponse.data
          .map(
            (apiMethod) => PaymentMethodModel.fromApiPaymentMethod(apiMethod),
          )
          .toList();

      debugPrint(
        '[PaymentMethodRepo] Fetched ${methods.length} payment methods',
      );
      return methods;
    } on DioException catch (e) {
      debugPrint('[PaymentMethodRepo] DioException: ${e.type} - ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod({
    required DomainPaymentMethodType type,
    String? cardToken,
    String? provider,
    String? accountId,
    bool setAsDefault = false,
  }) async {
    try {
      debugPrint(
        '[PaymentMethodRepo] Adding payment method: POST /users/me/payment-methods',
      );

      final request = AddPaymentMethodRequest(
        (b) => b
          ..type = type.toApi()
          ..cardToken = cardToken
          ..provider = provider
          ..accountId = accountId
          ..setAsDefault = setAsDefault,
      );

      final response = await _client.getUsersApi().paymentMethodsAdd(
        addPaymentMethodRequest: request,
      );
      final apiMethod = response.data;
      if (apiMethod == null) {
        throw const PaymentMethodServerError(
          message: 'Failed to add payment method',
        );
      }

      debugPrint('[PaymentMethodRepo] Added payment method: ${apiMethod.id}');
      return PaymentMethodModel.fromApiPaymentMethod(apiMethod);
    } on DioException catch (e) {
      debugPrint('[PaymentMethodRepo] DioException: ${e.type} - ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<void> removePaymentMethod(String methodId) async {
    try {
      debugPrint(
        '[PaymentMethodRepo] Removing payment method: DELETE /users/me/payment-methods/$methodId',
      );
      await _client.getUsersApi().paymentMethodsRemove(
        paymentMethodId: methodId,
      );
      debugPrint('[PaymentMethodRepo] Removed payment method: $methodId');
    } on DioException catch (e) {
      debugPrint('[PaymentMethodRepo] DioException: ${e.type} - ${e.message}');
      throw _fromDio(e);
    }
  }

  @override
  Future<PaymentMethodModel> setAsDefault(String methodId) async {
    try {
      debugPrint(
        '[PaymentMethodRepo] Setting default: PUT /users/me/payment-methods/$methodId/default',
      );
      final response = await _client.getUsersApi().paymentMethodsSetDefault(
        paymentMethodId: methodId,
      );
      final apiMethod = response.data;
      if (apiMethod == null) {
        throw const PaymentMethodServerError(
          message: 'Failed to set default payment method',
        );
      }

      debugPrint('[PaymentMethodRepo] Set default: ${apiMethod.id}');
      return PaymentMethodModel.fromApiPaymentMethod(apiMethod);
    } on DioException catch (e) {
      debugPrint('[PaymentMethodRepo] DioException: ${e.type} - ${e.message}');
      throw _fromDio(e);
    }
  }

  PaymentMethodError _fromDio(DioException e) {
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
        return const PaymentMethodNetworkError(
          message: 'Connection timed out. Try again.',
        );
      case DioExceptionType.connectionError:
        return const PaymentMethodNetworkError(
          message: 'No connection. Check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return const PaymentMethodServerError(
            message: 'Session expired. Please log in again.',
            code: ErrorCode.TOKEN_INVALID,
          );
        }
        return PaymentMethodServerError(
          message: e.message ?? 'Server error. Try again.',
        );
      default:
        return PaymentMethodServerError(
          message: e.message ?? 'Something went wrong. Try again.',
        );
    }
  }

  PaymentMethodError _mapErrorCode(ErrorResponse err) {
    switch (err.code) {
      case ErrorCode.TOKEN_INVALID:
      case ErrorCode.TOKEN_EXPIRED:
        return PaymentMethodServerError(
          message: 'Session expired. Please log in again.',
          code: err.code,
        );
      case ErrorCode.PAYMENT_METHOD_UNSUPPORTED:
        return PaymentMethodUnsupportedError(message: err.message);
      case ErrorCode.PAYMENT_METHOD_DUPLICATE:
        return PaymentMethodDuplicateError(message: err.message);
      case ErrorCode.PAYMENT_METHOD_NOT_FOUND:
        return PaymentMethodNotFoundError(message: err.message);
      case ErrorCode.PAYMENT_METHOD_LAST_METHOD:
        return PaymentMethodLastMethodError(message: err.message);
      case ErrorCode.INVALID_PAYMENT_TOKEN:
        return PaymentMethodValidationError(message: err.message);
      case ErrorCode.VALIDATION_ERROR:
        return PaymentMethodValidationError(message: err.message);
      case ErrorCode.PAYMENT_GATEWAY_ERROR:
        return const PaymentMethodServerError(
          message: 'Payment gateway error. Please try again.',
          code: ErrorCode.PAYMENT_GATEWAY_ERROR,
        );
      case ErrorCode.RATE_LIMIT_EXCEEDED:
        return const PaymentMethodServerError(
          message: 'Too many attempts. Wait a moment and try again.',
          code: ErrorCode.RATE_LIMIT_EXCEEDED,
        );
      case ErrorCode.INTERNAL_SERVER_ERROR:
        return const PaymentMethodServerError(
          message: 'Server error. Please try again later.',
          code: ErrorCode.INTERNAL_SERVER_ERROR,
        );
      default:
        return PaymentMethodServerError(message: err.message, code: err.code);
    }
  }
}
