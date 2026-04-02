//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_code.g.dart';

class ErrorCode extends EnumClass {

  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'EMAIL_ALREADY_REGISTERED')
  static const ErrorCode EMAIL_ALREADY_REGISTERED = _$EMAIL_ALREADY_REGISTERED;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'INVALID_CREDENTIALS')
  static const ErrorCode INVALID_CREDENTIALS = _$INVALID_CREDENTIALS;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'TOKEN_INVALID')
  static const ErrorCode TOKEN_INVALID = _$TOKEN_INVALID;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'TOKEN_EXPIRED')
  static const ErrorCode TOKEN_EXPIRED = _$TOKEN_EXPIRED;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'REFRESH_TOKEN_INVALID')
  static const ErrorCode REFRESH_TOKEN_INVALID = _$REFRESH_TOKEN_INVALID;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'VALIDATION_ERROR')
  static const ErrorCode VALIDATION_ERROR = _$VALIDATION_ERROR;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'FORBIDDEN')
  static const ErrorCode FORBIDDEN = _$FORBIDDEN;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'RIDE_NOT_FOUND')
  static const ErrorCode RIDE_NOT_FOUND = _$RIDE_NOT_FOUND;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'USER_NOT_FOUND')
  static const ErrorCode USER_NOT_FOUND = _$USER_NOT_FOUND;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'RIDE_INVALID_STATE_TRANSITION')
  static const ErrorCode RIDE_INVALID_STATE_TRANSITION = _$RIDE_INVALID_STATE_TRANSITION;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'PASSENGER_HAS_ACTIVE_RIDE')
  static const ErrorCode PASSENGER_HAS_ACTIVE_RIDE = _$PASSENGER_HAS_ACTIVE_RIDE;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'DRIVER_HAS_ACTIVE_RIDE')
  static const ErrorCode DRIVER_HAS_ACTIVE_RIDE = _$DRIVER_HAS_ACTIVE_RIDE;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'NO_DRIVERS_AVAILABLE')
  static const ErrorCode NO_DRIVERS_AVAILABLE = _$NO_DRIVERS_AVAILABLE;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'RATE_LIMIT_EXCEEDED')
  static const ErrorCode RATE_LIMIT_EXCEEDED = _$RATE_LIMIT_EXCEEDED;
  /// Machine-readable error code. Flutter clients should branch on this, not on `message`. 
  @BuiltValueEnumConst(wireName: r'INTERNAL_SERVER_ERROR')
  static const ErrorCode INTERNAL_SERVER_ERROR = _$INTERNAL_SERVER_ERROR;

  static Serializer<ErrorCode> get serializer => _$errorCodeSerializer;

  const ErrorCode._(String name): super(name);

  static BuiltSet<ErrorCode> get values => _$values;
  static ErrorCode valueOf(String name) => _$valueOf(name);
}
