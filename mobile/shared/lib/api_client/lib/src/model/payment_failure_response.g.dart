// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_failure_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentFailureResponseCodeEnum
    _$paymentFailureResponseCodeEnum_PAYMENT_FAILED =
    const PaymentFailureResponseCodeEnum._('PAYMENT_FAILED');

PaymentFailureResponseCodeEnum _$paymentFailureResponseCodeEnumValueOf(
    String name) {
  switch (name) {
    case 'PAYMENT_FAILED':
      return _$paymentFailureResponseCodeEnum_PAYMENT_FAILED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentFailureResponseCodeEnum>
    _$paymentFailureResponseCodeEnumValues = BuiltSet<
        PaymentFailureResponseCodeEnum>(const <PaymentFailureResponseCodeEnum>[
  _$paymentFailureResponseCodeEnum_PAYMENT_FAILED,
]);

Serializer<PaymentFailureResponseCodeEnum>
    _$paymentFailureResponseCodeEnumSerializer =
    _$PaymentFailureResponseCodeEnumSerializer();

class _$PaymentFailureResponseCodeEnumSerializer
    implements PrimitiveSerializer<PaymentFailureResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PAYMENT_FAILED': 'PAYMENT_FAILED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PAYMENT_FAILED': 'PAYMENT_FAILED',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentFailureResponseCodeEnum];
  @override
  final String wireName = 'PaymentFailureResponseCodeEnum';

  @override
  Object serialize(
          Serializers serializers, PaymentFailureResponseCodeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentFailureResponseCodeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentFailureResponseCodeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PaymentFailureResponse extends PaymentFailureResponse {
  @override
  final PaymentFailureResponseCodeEnum code;
  @override
  final String message;
  @override
  final String? gatewayErrorCode;

  factory _$PaymentFailureResponse(
          [void Function(PaymentFailureResponseBuilder)? updates]) =>
      (PaymentFailureResponseBuilder()..update(updates))._build();

  _$PaymentFailureResponse._(
      {required this.code, required this.message, this.gatewayErrorCode})
      : super._();
  @override
  PaymentFailureResponse rebuild(
          void Function(PaymentFailureResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentFailureResponseBuilder toBuilder() =>
      PaymentFailureResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentFailureResponse &&
        code == other.code &&
        message == other.message &&
        gatewayErrorCode == other.gatewayErrorCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, gatewayErrorCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentFailureResponse')
          ..add('code', code)
          ..add('message', message)
          ..add('gatewayErrorCode', gatewayErrorCode))
        .toString();
  }
}

class PaymentFailureResponseBuilder
    implements Builder<PaymentFailureResponse, PaymentFailureResponseBuilder> {
  _$PaymentFailureResponse? _$v;

  PaymentFailureResponseCodeEnum? _code;
  PaymentFailureResponseCodeEnum? get code => _$this._code;
  set code(PaymentFailureResponseCodeEnum? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  String? _gatewayErrorCode;
  String? get gatewayErrorCode => _$this._gatewayErrorCode;
  set gatewayErrorCode(String? gatewayErrorCode) =>
      _$this._gatewayErrorCode = gatewayErrorCode;

  PaymentFailureResponseBuilder() {
    PaymentFailureResponse._defaults(this);
  }

  PaymentFailureResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _gatewayErrorCode = $v.gatewayErrorCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentFailureResponse other) {
    _$v = other as _$PaymentFailureResponse;
  }

  @override
  void update(void Function(PaymentFailureResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentFailureResponse build() => _build();

  _$PaymentFailureResponse _build() {
    final _$result = _$v ??
        _$PaymentFailureResponse._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PaymentFailureResponse', 'code'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'PaymentFailureResponse', 'message'),
          gatewayErrorCode: gatewayErrorCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
