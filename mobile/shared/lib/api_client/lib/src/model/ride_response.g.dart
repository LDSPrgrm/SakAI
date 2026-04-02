// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideResponseCancelledByEnum _$rideResponseCancelledByEnum_passenger =
    const RideResponseCancelledByEnum._('passenger');
const RideResponseCancelledByEnum _$rideResponseCancelledByEnum_driver =
    const RideResponseCancelledByEnum._('driver');

RideResponseCancelledByEnum _$rideResponseCancelledByEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$rideResponseCancelledByEnum_passenger;
    case 'driver':
      return _$rideResponseCancelledByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideResponseCancelledByEnum>
    _$rideResponseCancelledByEnumValues =
    BuiltSet<RideResponseCancelledByEnum>(const <RideResponseCancelledByEnum>[
  _$rideResponseCancelledByEnum_passenger,
  _$rideResponseCancelledByEnum_driver,
]);

Serializer<RideResponseCancelledByEnum>
    _$rideResponseCancelledByEnumSerializer =
    _$RideResponseCancelledByEnumSerializer();

class _$RideResponseCancelledByEnumSerializer
    implements PrimitiveSerializer<RideResponseCancelledByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[RideResponseCancelledByEnum];
  @override
  final String wireName = 'RideResponseCancelledByEnum';

  @override
  Object serialize(Serializers serializers, RideResponseCancelledByEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RideResponseCancelledByEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RideResponseCancelledByEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RideResponse extends RideResponse {
  @override
  final String id;
  @override
  final RideStatus status;
  @override
  final UserProfile passenger;
  @override
  final DriverSummary? driver;
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
  final RideResponseCancelledByEnum? cancelledBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$RideResponse([void Function(RideResponseBuilder)? updates]) =>
      (RideResponseBuilder()..update(updates))._build();

  _$RideResponse._(
      {required this.id,
      required this.status,
      required this.passenger,
      this.driver,
      required this.origin,
      required this.destination,
      this.originAddress,
      this.destinationAddress,
      this.notes,
      this.cancelledBy,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  RideResponse rebuild(void Function(RideResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideResponseBuilder toBuilder() => RideResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideResponse &&
        id == other.id &&
        status == other.status &&
        passenger == other.passenger &&
        driver == other.driver &&
        origin == other.origin &&
        destination == other.destination &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        notes == other.notes &&
        cancelledBy == other.cancelledBy &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, passenger.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, cancelledBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideResponse')
          ..add('id', id)
          ..add('status', status)
          ..add('passenger', passenger)
          ..add('driver', driver)
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('notes', notes)
          ..add('cancelledBy', cancelledBy)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RideResponseBuilder
    implements Builder<RideResponse, RideResponseBuilder> {
  _$RideResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RideStatus? _status;
  RideStatus? get status => _$this._status;
  set status(RideStatus? status) => _$this._status = status;

  UserProfileBuilder? _passenger;
  UserProfileBuilder get passenger =>
      _$this._passenger ??= UserProfileBuilder();
  set passenger(UserProfileBuilder? passenger) => _$this._passenger = passenger;

  DriverSummaryBuilder? _driver;
  DriverSummaryBuilder get driver => _$this._driver ??= DriverSummaryBuilder();
  set driver(DriverSummaryBuilder? driver) => _$this._driver = driver;

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

  RideResponseCancelledByEnum? _cancelledBy;
  RideResponseCancelledByEnum? get cancelledBy => _$this._cancelledBy;
  set cancelledBy(RideResponseCancelledByEnum? cancelledBy) =>
      _$this._cancelledBy = cancelledBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RideResponseBuilder() {
    RideResponse._defaults(this);
  }

  RideResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _passenger = $v.passenger.toBuilder();
      _driver = $v.driver?.toBuilder();
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _notes = $v.notes;
      _cancelledBy = $v.cancelledBy;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideResponse other) {
    _$v = other as _$RideResponse;
  }

  @override
  void update(void Function(RideResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideResponse build() => _build();

  _$RideResponse _build() {
    _$RideResponse _$result;
    try {
      _$result = _$v ??
          _$RideResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'RideResponse', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'RideResponse', 'status'),
            passenger: passenger.build(),
            driver: _driver?.build(),
            origin: origin.build(),
            destination: destination.build(),
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            notes: notes,
            cancelledBy: cancelledBy,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RideResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'RideResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'passenger';
        passenger.build();
        _$failedField = 'driver';
        _driver?.build();
        _$failedField = 'origin';
        origin.build();
        _$failedField = 'destination';
        destination.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RideResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
