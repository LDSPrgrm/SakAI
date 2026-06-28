// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_envelope_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WsEnvelopePayloadPaymentMethodEnum
_$wsEnvelopePayloadPaymentMethodEnum_cash =
    const WsEnvelopePayloadPaymentMethodEnum._('cash');
const WsEnvelopePayloadPaymentMethodEnum
_$wsEnvelopePayloadPaymentMethodEnum_gcash =
    const WsEnvelopePayloadPaymentMethodEnum._('gcash');
const WsEnvelopePayloadPaymentMethodEnum
_$wsEnvelopePayloadPaymentMethodEnum_paymaya =
    const WsEnvelopePayloadPaymentMethodEnum._('paymaya');
const WsEnvelopePayloadPaymentMethodEnum
_$wsEnvelopePayloadPaymentMethodEnum_card =
    const WsEnvelopePayloadPaymentMethodEnum._('card');

WsEnvelopePayloadPaymentMethodEnum _$wsEnvelopePayloadPaymentMethodEnumValueOf(
  String name,
) {
  switch (name) {
    case 'cash':
      return _$wsEnvelopePayloadPaymentMethodEnum_cash;
    case 'gcash':
      return _$wsEnvelopePayloadPaymentMethodEnum_gcash;
    case 'paymaya':
      return _$wsEnvelopePayloadPaymentMethodEnum_paymaya;
    case 'card':
      return _$wsEnvelopePayloadPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEnvelopePayloadPaymentMethodEnum>
_$wsEnvelopePayloadPaymentMethodEnumValues =
    BuiltSet<WsEnvelopePayloadPaymentMethodEnum>(
      const <WsEnvelopePayloadPaymentMethodEnum>[
        _$wsEnvelopePayloadPaymentMethodEnum_cash,
        _$wsEnvelopePayloadPaymentMethodEnum_gcash,
        _$wsEnvelopePayloadPaymentMethodEnum_paymaya,
        _$wsEnvelopePayloadPaymentMethodEnum_card,
      ],
    );

const WsEnvelopePayloadCancelledByEnum
_$wsEnvelopePayloadCancelledByEnum_passenger =
    const WsEnvelopePayloadCancelledByEnum._('passenger');
const WsEnvelopePayloadCancelledByEnum
_$wsEnvelopePayloadCancelledByEnum_driver =
    const WsEnvelopePayloadCancelledByEnum._('driver');

WsEnvelopePayloadCancelledByEnum _$wsEnvelopePayloadCancelledByEnumValueOf(
  String name,
) {
  switch (name) {
    case 'passenger':
      return _$wsEnvelopePayloadCancelledByEnum_passenger;
    case 'driver':
      return _$wsEnvelopePayloadCancelledByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEnvelopePayloadCancelledByEnum>
_$wsEnvelopePayloadCancelledByEnumValues =
    BuiltSet<WsEnvelopePayloadCancelledByEnum>(
      const <WsEnvelopePayloadCancelledByEnum>[
        _$wsEnvelopePayloadCancelledByEnum_passenger,
        _$wsEnvelopePayloadCancelledByEnum_driver,
      ],
    );

const WsEnvelopePayloadTriggeredByEnum
_$wsEnvelopePayloadTriggeredByEnum_rider =
    const WsEnvelopePayloadTriggeredByEnum._('rider');
const WsEnvelopePayloadTriggeredByEnum
_$wsEnvelopePayloadTriggeredByEnum_driver =
    const WsEnvelopePayloadTriggeredByEnum._('driver');

WsEnvelopePayloadTriggeredByEnum _$wsEnvelopePayloadTriggeredByEnumValueOf(
  String name,
) {
  switch (name) {
    case 'rider':
      return _$wsEnvelopePayloadTriggeredByEnum_rider;
    case 'driver':
      return _$wsEnvelopePayloadTriggeredByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WsEnvelopePayloadTriggeredByEnum>
_$wsEnvelopePayloadTriggeredByEnumValues =
    BuiltSet<WsEnvelopePayloadTriggeredByEnum>(
      const <WsEnvelopePayloadTriggeredByEnum>[
        _$wsEnvelopePayloadTriggeredByEnum_rider,
        _$wsEnvelopePayloadTriggeredByEnum_driver,
      ],
    );

Serializer<WsEnvelopePayloadPaymentMethodEnum>
_$wsEnvelopePayloadPaymentMethodEnumSerializer =
    _$WsEnvelopePayloadPaymentMethodEnumSerializer();
Serializer<WsEnvelopePayloadCancelledByEnum>
_$wsEnvelopePayloadCancelledByEnumSerializer =
    _$WsEnvelopePayloadCancelledByEnumSerializer();
Serializer<WsEnvelopePayloadTriggeredByEnum>
_$wsEnvelopePayloadTriggeredByEnumSerializer =
    _$WsEnvelopePayloadTriggeredByEnumSerializer();

class _$WsEnvelopePayloadPaymentMethodEnumSerializer
    implements PrimitiveSerializer<WsEnvelopePayloadPaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };

  @override
  final Iterable<Type> types = const <Type>[WsEnvelopePayloadPaymentMethodEnum];
  @override
  final String wireName = 'WsEnvelopePayloadPaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEnvelopePayloadPaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEnvelopePayloadPaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEnvelopePayloadPaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEnvelopePayloadCancelledByEnumSerializer
    implements PrimitiveSerializer<WsEnvelopePayloadCancelledByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[WsEnvelopePayloadCancelledByEnum];
  @override
  final String wireName = 'WsEnvelopePayloadCancelledByEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEnvelopePayloadCancelledByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEnvelopePayloadCancelledByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEnvelopePayloadCancelledByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEnvelopePayloadTriggeredByEnumSerializer
    implements PrimitiveSerializer<WsEnvelopePayloadTriggeredByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'rider': 'rider',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'rider': 'rider',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[WsEnvelopePayloadTriggeredByEnum];
  @override
  final String wireName = 'WsEnvelopePayloadTriggeredByEnum';

  @override
  Object serialize(
    Serializers serializers,
    WsEnvelopePayloadTriggeredByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  WsEnvelopePayloadTriggeredByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => WsEnvelopePayloadTriggeredByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$WsEnvelopePayload extends WsEnvelopePayload {
  @override
  final OneOf oneOf;

  factory _$WsEnvelopePayload([
    void Function(WsEnvelopePayloadBuilder)? updates,
  ]) => (WsEnvelopePayloadBuilder()..update(updates))._build();

  _$WsEnvelopePayload._({required this.oneOf}) : super._();
  @override
  WsEnvelopePayload rebuild(void Function(WsEnvelopePayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEnvelopePayloadBuilder toBuilder() =>
      WsEnvelopePayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEnvelopePayload && oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'WsEnvelopePayload',
    )..add('oneOf', oneOf)).toString();
  }
}

class WsEnvelopePayloadBuilder
    implements Builder<WsEnvelopePayload, WsEnvelopePayloadBuilder> {
  _$WsEnvelopePayload? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  WsEnvelopePayloadBuilder() {
    WsEnvelopePayload._defaults(this);
  }

  WsEnvelopePayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEnvelopePayload other) {
    _$v = other as _$WsEnvelopePayload;
  }

  @override
  void update(void Function(WsEnvelopePayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEnvelopePayload build() => _build();

  _$WsEnvelopePayload _build() {
    final _$result =
        _$v ??
        _$WsEnvelopePayload._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
            oneOf,
            r'WsEnvelopePayload',
            'oneOf',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
