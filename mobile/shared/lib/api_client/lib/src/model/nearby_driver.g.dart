// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NearbyDriverVehicleTypeEnum _$nearbyDriverVehicleTypeEnum_motorcycle =
    const NearbyDriverVehicleTypeEnum._('motorcycle');
const NearbyDriverVehicleTypeEnum _$nearbyDriverVehicleTypeEnum_car =
    const NearbyDriverVehicleTypeEnum._('car');
const NearbyDriverVehicleTypeEnum _$nearbyDriverVehicleTypeEnum_tricycle =
    const NearbyDriverVehicleTypeEnum._('tricycle');

NearbyDriverVehicleTypeEnum _$nearbyDriverVehicleTypeEnumValueOf(String name) {
  switch (name) {
    case 'motorcycle':
      return _$nearbyDriverVehicleTypeEnum_motorcycle;
    case 'car':
      return _$nearbyDriverVehicleTypeEnum_car;
    case 'tricycle':
      return _$nearbyDriverVehicleTypeEnum_tricycle;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NearbyDriverVehicleTypeEnum>
_$nearbyDriverVehicleTypeEnumValues =
    BuiltSet<NearbyDriverVehicleTypeEnum>(const <NearbyDriverVehicleTypeEnum>[
      _$nearbyDriverVehicleTypeEnum_motorcycle,
      _$nearbyDriverVehicleTypeEnum_car,
      _$nearbyDriverVehicleTypeEnum_tricycle,
    ]);

Serializer<NearbyDriverVehicleTypeEnum>
_$nearbyDriverVehicleTypeEnumSerializer =
    _$NearbyDriverVehicleTypeEnumSerializer();

class _$NearbyDriverVehicleTypeEnumSerializer
    implements PrimitiveSerializer<NearbyDriverVehicleTypeEnum> {
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
  final Iterable<Type> types = const <Type>[NearbyDriverVehicleTypeEnum];
  @override
  final String wireName = 'NearbyDriverVehicleTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    NearbyDriverVehicleTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NearbyDriverVehicleTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NearbyDriverVehicleTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NearbyDriver extends NearbyDriver {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? vehicleMake;
  @override
  final String? vehicleModel;
  @override
  final String? vehiclePlate;
  @override
  final NearbyDriverVehicleTypeEnum vehicleType;
  @override
  final double? rating;
  @override
  final double? distanceM;
  @override
  final LatLng location;
  @override
  final double? heading;

  factory _$NearbyDriver([void Function(NearbyDriverBuilder)? updates]) =>
      (NearbyDriverBuilder()..update(updates))._build();

  _$NearbyDriver._({
    required this.id,
    required this.name,
    this.vehicleMake,
    this.vehicleModel,
    this.vehiclePlate,
    required this.vehicleType,
    this.rating,
    this.distanceM,
    required this.location,
    this.heading,
  }) : super._();
  @override
  NearbyDriver rebuild(void Function(NearbyDriverBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NearbyDriverBuilder toBuilder() => NearbyDriverBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NearbyDriver &&
        id == other.id &&
        name == other.name &&
        vehicleMake == other.vehicleMake &&
        vehicleModel == other.vehicleModel &&
        vehiclePlate == other.vehiclePlate &&
        vehicleType == other.vehicleType &&
        rating == other.rating &&
        distanceM == other.distanceM &&
        location == other.location &&
        heading == other.heading;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, vehicleMake.hashCode);
    _$hash = $jc(_$hash, vehicleModel.hashCode);
    _$hash = $jc(_$hash, vehiclePlate.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, heading.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NearbyDriver')
          ..add('id', id)
          ..add('name', name)
          ..add('vehicleMake', vehicleMake)
          ..add('vehicleModel', vehicleModel)
          ..add('vehiclePlate', vehiclePlate)
          ..add('vehicleType', vehicleType)
          ..add('rating', rating)
          ..add('distanceM', distanceM)
          ..add('location', location)
          ..add('heading', heading))
        .toString();
  }
}

class NearbyDriverBuilder
    implements Builder<NearbyDriver, NearbyDriverBuilder> {
  _$NearbyDriver? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _vehicleMake;
  String? get vehicleMake => _$this._vehicleMake;
  set vehicleMake(String? vehicleMake) => _$this._vehicleMake = vehicleMake;

  String? _vehicleModel;
  String? get vehicleModel => _$this._vehicleModel;
  set vehicleModel(String? vehicleModel) => _$this._vehicleModel = vehicleModel;

  String? _vehiclePlate;
  String? get vehiclePlate => _$this._vehiclePlate;
  set vehiclePlate(String? vehiclePlate) => _$this._vehiclePlate = vehiclePlate;

  NearbyDriverVehicleTypeEnum? _vehicleType;
  NearbyDriverVehicleTypeEnum? get vehicleType => _$this._vehicleType;
  set vehicleType(NearbyDriverVehicleTypeEnum? vehicleType) =>
      _$this._vehicleType = vehicleType;

  double? _rating;
  double? get rating => _$this._rating;
  set rating(double? rating) => _$this._rating = rating;

  double? _distanceM;
  double? get distanceM => _$this._distanceM;
  set distanceM(double? distanceM) => _$this._distanceM = distanceM;

  LatLngBuilder? _location;
  LatLngBuilder get location => _$this._location ??= LatLngBuilder();
  set location(LatLngBuilder? location) => _$this._location = location;

  double? _heading;
  double? get heading => _$this._heading;
  set heading(double? heading) => _$this._heading = heading;

  NearbyDriverBuilder() {
    NearbyDriver._defaults(this);
  }

  NearbyDriverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _vehicleMake = $v.vehicleMake;
      _vehicleModel = $v.vehicleModel;
      _vehiclePlate = $v.vehiclePlate;
      _vehicleType = $v.vehicleType;
      _rating = $v.rating;
      _distanceM = $v.distanceM;
      _location = $v.location.toBuilder();
      _heading = $v.heading;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NearbyDriver other) {
    _$v = other as _$NearbyDriver;
  }

  @override
  void update(void Function(NearbyDriverBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NearbyDriver build() => _build();

  _$NearbyDriver _build() {
    _$NearbyDriver _$result;
    try {
      _$result =
          _$v ??
          _$NearbyDriver._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'NearbyDriver',
              'id',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'NearbyDriver',
              'name',
            ),
            vehicleMake: vehicleMake,
            vehicleModel: vehicleModel,
            vehiclePlate: vehiclePlate,
            vehicleType: BuiltValueNullFieldError.checkNotNull(
              vehicleType,
              r'NearbyDriver',
              'vehicleType',
            ),
            rating: rating,
            distanceM: distanceM,
            location: location.build(),
            heading: heading,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        location.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NearbyDriver',
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
