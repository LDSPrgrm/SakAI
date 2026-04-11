import 'package:sakai_api_client/sakai_api_client.dart';

/// Domain error response — branch on [code], not [message].
///
/// Renamed to avoid conflict with the generated [ErrorResponse].
class DomainErrorResponse {
  final ErrorCode code;
  final String message;

  DomainErrorResponse({required this.code, required this.message});

  factory DomainErrorResponse.fromApi(ErrorResponse e) =>
      DomainErrorResponse(code: e.code, message: e.message);

  /// User-friendly display string mapped from the stable [ErrorCode] enum.
  String get displayMessage {
    if (code == ErrorCode.INVALID_CREDENTIALS) {
      return 'Invalid email or password.';
    }
    if (code == ErrorCode.EMAIL_ALREADY_REGISTERED) {
      return 'An account with this email already exists.';
    }
    if (code == ErrorCode.FORBIDDEN) {
      return 'You do not have permission to perform this action.';
    }
    if (code == ErrorCode.RIDE_NOT_FOUND || code == ErrorCode.USER_NOT_FOUND) {
      return 'The requested resource was not found.';
    }
    if (code == ErrorCode.RIDE_INVALID_STATE_TRANSITION ||
        code == ErrorCode.PASSENGER_HAS_ACTIVE_RIDE ||
        code == ErrorCode.DRIVER_HAS_ACTIVE_RIDE) {
      return 'This action cannot be completed. Please try again.';
    }
    if (code == ErrorCode.RATE_LIMIT_EXCEEDED) {
      return 'Too many requests. Please wait and try again.';
    }
    if (code == ErrorCode.NO_DRIVERS_AVAILABLE) {
      return 'No drivers available right now. Please try again.';
    }
    return message;
  }
}
