// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideRequestBodyRideTypeEnum _$rideRequestBodyRideTypeEnum_motorcycle =
    const RideRequestBodyRideTypeEnum._('motorcycle');
const RideRequestBodyRideTypeEnum _$rideRequestBodyRideTypeEnum_car =
    const RideRequestBodyRideTypeEnum._('car');
const RideRequestBodyRideTypeEnum _$rideRequestBodyRideTypeEnum_tricycle =
    const RideRequestBodyRideTypeEnum._('tricycle');

RideRequestBodyRideTypeEnum _$rideRequestBodyRideTypeEnumValueOf(String name) {
  switch (name) {
    case 'motorcycle':
      return _$rideRequestBodyRideTypeEnum_motorcycle;
    case 'car':
      return _$rideRequestBodyRideTypeEnum_car;
    case 'tricycle':
      return _$rideRequestBodyRideTypeEnum_tricycle;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideRequestBodyRideTypeEnum>
_$rideRequestBodyRideTypeEnumValues =
    BuiltSet<RideRequestBodyRideTypeEnum>(const <RideRequestBodyRideTypeEnum>[
      _$rideRequestBodyRideTypeEnum_motorcycle,
      _$rideRequestBodyRideTypeEnum_car,
      _$rideRequestBodyRideTypeEnum_tricycle,
    ]);

const RideRequestBodyPaymentMethodEnum _$rideRequestBodyPaymentMethodEnum_cash =
    const RideRequestBodyPaymentMethodEnum._('cash');
const RideRequestBodyPaymentMethodEnum _$rideRequestBodyPaymentMethodEnum_card =
    const RideRequestBodyPaymentMethodEnum._('card');

RideRequestBodyPaymentMethodEnum _$rideRequestBodyPaymentMethodEnumValueOf(
  String name,
) {
  switch (name) {
    case 'cash':
      return _$rideRequestBodyPaymentMethodEnum_cash;
    case 'card':
      return _$rideRequestBodyPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideRequestBodyPaymentMethodEnum>
_$rideRequestBodyPaymentMethodEnumValues =
    BuiltSet<RideRequestBodyPaymentMethodEnum>(
      const <RideRequestBodyPaymentMethodEnum>[
        _$rideRequestBodyPaymentMethodEnum_cash,
        _$rideRequestBodyPaymentMethodEnum_card,
      ],
    );

Serializer<RideRequestBodyRideTypeEnum>
_$rideRequestBodyRideTypeEnumSerializer =
    _$RideRequestBodyRideTypeEnumSerializer();
Serializer<RideRequestBodyPaymentMethodEnum>
_$rideRequestBodyPaymentMethodEnumSerializer =
    _$RideRequestBodyPaymentMethodEnumSerializer();

class _$RideRequestBodyRideTypeEnumSerializer
    implements PrimitiveSerializer<RideRequestBodyRideTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'motorcycle': 'motorcycle',
    'car': 'car',
    'tricycle': 'tricycle',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'motorcycle': 'motorcycle',
    'car': 'car',
    'tricycle': 'tricycle',
  };

  @override
  final Iterable<Type> types = const <Type>[RideRequestBodyRideTypeEnum];
  @override
  final String wireName = 'RideRequestBodyRideTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RideRequestBodyRideTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideRequestBodyRideTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideRequestBodyRideTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RideRequestBodyPaymentMethodEnumSerializer
    implements PrimitiveSerializer<RideRequestBodyPaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'card': 'card',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'card': 'card',
  };

  @override
  final Iterable<Type> types = const <Type>[RideRequestBodyPaymentMethodEnum];
  @override
  final String wireName = 'RideRequestBodyPaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    RideRequestBodyPaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideRequestBodyPaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideRequestBodyPaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RideRequestBody extends RideRequestBody {
  @override
  final LatLng origin;
  @override
  final LatLng destination;
  @override
  final String? originAddress;
  @override
  final String? destinationAddress;
  @override
  final String? notes;
  @override
  final RideRequestBodyRideTypeEnum rideType;
  @override
  final RideRequestBodyPaymentMethodEnum? paymentMethod;

  factory _$RideRequestBody([void Function(RideRequestBodyBuilder)? updates]) =>
      (RideRequestBodyBuilder()..update(updates))._build();

  _$RideRequestBody._({
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
    this.notes,
    required this.rideType,
    this.paymentMethod,
  }) : super._();
  @override
  RideRequestBody rebuild(void Function(RideRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideRequestBodyBuilder toBuilder() => RideRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideRequestBody &&
        origin == other.origin &&
        destination == other.destination &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        notes == other.notes &&
        rideType == other.rideType &&
        paymentMethod == other.paymentMethod;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, rideType.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideRequestBody')
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('notes', notes)
          ..add('rideType', rideType)
          ..add('paymentMethod', paymentMethod))
        .toString();
  }
}

class RideRequestBodyBuilder
    implements Builder<RideRequestBody, RideRequestBodyBuilder> {
  _$RideRequestBody? _$v;

  LatLngBuilder? _origin;
  LatLngBuilder get origin => _$this._origin ??= LatLngBuilder();
  set origin(LatLngBuilder? origin) => _$this._origin = origin;

  LatLngBuilder? _destination;
  LatLngBuilder get destination => _$this._destination ??= LatLngBuilder();
  set destination(LatLngBuilder? destination) =>
      _$this._destination = destination;

  String? _originAddress;
  String? get originAddress => _$this._originAddress;
  set originAddress(String? originAddress) =>
      _$this._originAddress = originAddress;

  String? _destinationAddress;
  String? get destinationAddress => _$this._destinationAddress;
  set destinationAddress(String? destinationAddress) =>
      _$this._destinationAddress = destinationAddress;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  RideRequestBodyRideTypeEnum? _rideType;
  RideRequestBodyRideTypeEnum? get rideType => _$this._rideType;
  set rideType(RideRequestBodyRideTypeEnum? rideType) =>
      _$this._rideType = rideType;

  RideRequestBodyPaymentMethodEnum? _paymentMethod;
  RideRequestBodyPaymentMethodEnum? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(RideRequestBodyPaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  RideRequestBodyBuilder() {
    RideRequestBody._defaults(this);
  }

  RideRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _notes = $v.notes;
      _rideType = $v.rideType;
      _paymentMethod = $v.paymentMethod;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideRequestBody other) {
    _$v = other as _$RideRequestBody;
  }

  @override
  void update(void Function(RideRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideRequestBody build() => _build();

  _$RideRequestBody _build() {
    _$RideRequestBody _$result;
    try {
      _$result =
          _$v ??
          _$RideRequestBody._(
            origin: origin.build(),
            destination: destination.build(),
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            notes: notes,
            rideType: BuiltValueNullFieldError.checkNotNull(
              rideType,
              r'RideRequestBody',
              'rideType',
            ),
            paymentMethod: paymentMethod,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'origin';
        origin.build();
        _$failedField = 'destination';
        destination.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'RideRequestBody',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
