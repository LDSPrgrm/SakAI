// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_code.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ErrorCode _$EMAIL_ALREADY_REGISTERED = const ErrorCode._(
  'EMAIL_ALREADY_REGISTERED',
);
const ErrorCode _$INVALID_CREDENTIALS = const ErrorCode._(
  'INVALID_CREDENTIALS',
);
const ErrorCode _$TOKEN_INVALID = const ErrorCode._('TOKEN_INVALID');
const ErrorCode _$TOKEN_EXPIRED = const ErrorCode._('TOKEN_EXPIRED');
const ErrorCode _$REFRESH_TOKEN_INVALID = const ErrorCode._(
  'REFRESH_TOKEN_INVALID',
);
const ErrorCode _$VALIDATION_ERROR = const ErrorCode._('VALIDATION_ERROR');
const ErrorCode _$FORBIDDEN = const ErrorCode._('FORBIDDEN');
const ErrorCode _$RIDE_NOT_FOUND = const ErrorCode._('RIDE_NOT_FOUND');
const ErrorCode _$USER_NOT_FOUND = const ErrorCode._('USER_NOT_FOUND');
const ErrorCode _$RIDE_INVALID_STATE_TRANSITION = const ErrorCode._(
  'RIDE_INVALID_STATE_TRANSITION',
);
const ErrorCode _$PASSENGER_HAS_ACTIVE_RIDE = const ErrorCode._(
  'PASSENGER_HAS_ACTIVE_RIDE',
);
const ErrorCode _$DRIVER_HAS_ACTIVE_RIDE = const ErrorCode._(
  'DRIVER_HAS_ACTIVE_RIDE',
);
const ErrorCode _$NO_DRIVERS_AVAILABLE = const ErrorCode._(
  'NO_DRIVERS_AVAILABLE',
);
const ErrorCode _$RATE_LIMIT_EXCEEDED = const ErrorCode._(
  'RATE_LIMIT_EXCEEDED',
);
const ErrorCode _$INTERNAL_SERVER_ERROR = const ErrorCode._(
  'INTERNAL_SERVER_ERROR',
);

ErrorCode _$valueOf(String name) {
  switch (name) {
    case 'EMAIL_ALREADY_REGISTERED':
      return _$EMAIL_ALREADY_REGISTERED;
    case 'INVALID_CREDENTIALS':
      return _$INVALID_CREDENTIALS;
    case 'TOKEN_INVALID':
      return _$TOKEN_INVALID;
    case 'TOKEN_EXPIRED':
      return _$TOKEN_EXPIRED;
    case 'REFRESH_TOKEN_INVALID':
      return _$REFRESH_TOKEN_INVALID;
    case 'VALIDATION_ERROR':
      return _$VALIDATION_ERROR;
    case 'FORBIDDEN':
      return _$FORBIDDEN;
    case 'RIDE_NOT_FOUND':
      return _$RIDE_NOT_FOUND;
    case 'USER_NOT_FOUND':
      return _$USER_NOT_FOUND;
    case 'RIDE_INVALID_STATE_TRANSITION':
      return _$RIDE_INVALID_STATE_TRANSITION;
    case 'PASSENGER_HAS_ACTIVE_RIDE':
      return _$PASSENGER_HAS_ACTIVE_RIDE;
    case 'DRIVER_HAS_ACTIVE_RIDE':
      return _$DRIVER_HAS_ACTIVE_RIDE;
    case 'NO_DRIVERS_AVAILABLE':
      return _$NO_DRIVERS_AVAILABLE;
    case 'RATE_LIMIT_EXCEEDED':
      return _$RATE_LIMIT_EXCEEDED;
    case 'INTERNAL_SERVER_ERROR':
      return _$INTERNAL_SERVER_ERROR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ErrorCode> _$values = BuiltSet<ErrorCode>(const <ErrorCode>[
  _$EMAIL_ALREADY_REGISTERED,
  _$INVALID_CREDENTIALS,
  _$TOKEN_INVALID,
  _$TOKEN_EXPIRED,
  _$REFRESH_TOKEN_INVALID,
  _$VALIDATION_ERROR,
  _$FORBIDDEN,
  _$RIDE_NOT_FOUND,
  _$USER_NOT_FOUND,
  _$RIDE_INVALID_STATE_TRANSITION,
  _$PASSENGER_HAS_ACTIVE_RIDE,
  _$DRIVER_HAS_ACTIVE_RIDE,
  _$NO_DRIVERS_AVAILABLE,
  _$RATE_LIMIT_EXCEEDED,
  _$INTERNAL_SERVER_ERROR,
]);

Serializer<ErrorCode> _$errorCodeSerializer = _$ErrorCodeSerializer();

class _$ErrorCodeSerializer implements PrimitiveSerializer<ErrorCode> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'EMAIL_ALREADY_REGISTERED': 'EMAIL_ALREADY_REGISTERED',
    'INVALID_CREDENTIALS': 'INVALID_CREDENTIALS',
    'TOKEN_INVALID': 'TOKEN_INVALID',
    'TOKEN_EXPIRED': 'TOKEN_EXPIRED',
    'REFRESH_TOKEN_INVALID': 'REFRESH_TOKEN_INVALID',
    'VALIDATION_ERROR': 'VALIDATION_ERROR',
    'FORBIDDEN': 'FORBIDDEN',
    'RIDE_NOT_FOUND': 'RIDE_NOT_FOUND',
    'USER_NOT_FOUND': 'USER_NOT_FOUND',
    'RIDE_INVALID_STATE_TRANSITION': 'RIDE_INVALID_STATE_TRANSITION',
    'PASSENGER_HAS_ACTIVE_RIDE': 'PASSENGER_HAS_ACTIVE_RIDE',
    'DRIVER_HAS_ACTIVE_RIDE': 'DRIVER_HAS_ACTIVE_RIDE',
    'NO_DRIVERS_AVAILABLE': 'NO_DRIVERS_AVAILABLE',
    'RATE_LIMIT_EXCEEDED': 'RATE_LIMIT_EXCEEDED',
    'INTERNAL_SERVER_ERROR': 'INTERNAL_SERVER_ERROR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'EMAIL_ALREADY_REGISTERED': 'EMAIL_ALREADY_REGISTERED',
    'INVALID_CREDENTIALS': 'INVALID_CREDENTIALS',
    'TOKEN_INVALID': 'TOKEN_INVALID',
    'TOKEN_EXPIRED': 'TOKEN_EXPIRED',
    'REFRESH_TOKEN_INVALID': 'REFRESH_TOKEN_INVALID',
    'VALIDATION_ERROR': 'VALIDATION_ERROR',
    'FORBIDDEN': 'FORBIDDEN',
    'RIDE_NOT_FOUND': 'RIDE_NOT_FOUND',
    'USER_NOT_FOUND': 'USER_NOT_FOUND',
    'RIDE_INVALID_STATE_TRANSITION': 'RIDE_INVALID_STATE_TRANSITION',
    'PASSENGER_HAS_ACTIVE_RIDE': 'PASSENGER_HAS_ACTIVE_RIDE',
    'DRIVER_HAS_ACTIVE_RIDE': 'DRIVER_HAS_ACTIVE_RIDE',
    'NO_DRIVERS_AVAILABLE': 'NO_DRIVERS_AVAILABLE',
    'RATE_LIMIT_EXCEEDED': 'RATE_LIMIT_EXCEEDED',
    'INTERNAL_SERVER_ERROR': 'INTERNAL_SERVER_ERROR',
  };

  @override
  final Iterable<Type> types = const <Type>[ErrorCode];
  @override
  final String wireName = 'ErrorCode';

  @override
  Object serialize(
    Serializers serializers,
    ErrorCode object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  ErrorCode deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => ErrorCode.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
