// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_position.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HeatmapPositionVehicleTypeEnum
_$heatmapPositionVehicleTypeEnum_motorcycle =
    const HeatmapPositionVehicleTypeEnum._('motorcycle');
const HeatmapPositionVehicleTypeEnum _$heatmapPositionVehicleTypeEnum_tricycle =
    const HeatmapPositionVehicleTypeEnum._('tricycle');
const HeatmapPositionVehicleTypeEnum _$heatmapPositionVehicleTypeEnum_car =
    const HeatmapPositionVehicleTypeEnum._('car');

HeatmapPositionVehicleTypeEnum _$heatmapPositionVehicleTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'motorcycle':
      return _$heatmapPositionVehicleTypeEnum_motorcycle;
    case 'tricycle':
      return _$heatmapPositionVehicleTypeEnum_tricycle;
    case 'car':
      return _$heatmapPositionVehicleTypeEnum_car;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HeatmapPositionVehicleTypeEnum>
_$heatmapPositionVehicleTypeEnumValues =
    BuiltSet<HeatmapPositionVehicleTypeEnum>(
      const <HeatmapPositionVehicleTypeEnum>[
        _$heatmapPositionVehicleTypeEnum_motorcycle,
        _$heatmapPositionVehicleTypeEnum_tricycle,
        _$heatmapPositionVehicleTypeEnum_car,
      ],
    );

Serializer<HeatmapPositionVehicleTypeEnum>
_$heatmapPositionVehicleTypeEnumSerializer =
    _$HeatmapPositionVehicleTypeEnumSerializer();

class _$HeatmapPositionVehicleTypeEnumSerializer
    implements PrimitiveSerializer<HeatmapPositionVehicleTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'motorcycle': 'motorcycle',
    'tricycle': 'tricycle',
    'car': 'car',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'motorcycle': 'motorcycle',
    'tricycle': 'tricycle',
    'car': 'car',
  };

  @override
  final Iterable<Type> types = const <Type>[HeatmapPositionVehicleTypeEnum];
  @override
  final String wireName = 'HeatmapPositionVehicleTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    HeatmapPositionVehicleTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HeatmapPositionVehicleTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HeatmapPositionVehicleTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HeatmapPosition extends HeatmapPosition {
  @override
  final String? driverId;
  @override
  final double? lat;
  @override
  final double? lng;
  @override
  final HeatmapPositionVehicleTypeEnum? vehicleType;
  @override
  final bool? isAvailable;
  @override
  final DateTime? updatedAt;

  factory _$HeatmapPosition([void Function(HeatmapPositionBuilder)? updates]) =>
      (HeatmapPositionBuilder()..update(updates))._build();

  _$HeatmapPosition._({
    this.driverId,
    this.lat,
    this.lng,
    this.vehicleType,
    this.isAvailable,
    this.updatedAt,
  }) : super._();
  @override
  HeatmapPosition rebuild(void Function(HeatmapPositionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HeatmapPositionBuilder toBuilder() => HeatmapPositionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HeatmapPosition &&
        driverId == other.driverId &&
        lat == other.lat &&
        lng == other.lng &&
        vehicleType == other.vehicleType &&
        isAvailable == other.isAvailable &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, isAvailable.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HeatmapPosition')
          ..add('driverId', driverId)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('vehicleType', vehicleType)
          ..add('isAvailable', isAvailable)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class HeatmapPositionBuilder
    implements Builder<HeatmapPosition, HeatmapPositionBuilder> {
  _$HeatmapPosition? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  double? _lat;
  double? get lat => _$this._lat;
  set lat(double? lat) => _$this._lat = lat;

  double? _lng;
  double? get lng => _$this._lng;
  set lng(double? lng) => _$this._lng = lng;

  HeatmapPositionVehicleTypeEnum? _vehicleType;
  HeatmapPositionVehicleTypeEnum? get vehicleType => _$this._vehicleType;
  set vehicleType(HeatmapPositionVehicleTypeEnum? vehicleType) =>
      _$this._vehicleType = vehicleType;

  bool? _isAvailable;
  bool? get isAvailable => _$this._isAvailable;
  set isAvailable(bool? isAvailable) => _$this._isAvailable = isAvailable;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  HeatmapPositionBuilder() {
    HeatmapPosition._defaults(this);
  }

  HeatmapPositionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _lat = $v.lat;
      _lng = $v.lng;
      _vehicleType = $v.vehicleType;
      _isAvailable = $v.isAvailable;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HeatmapPosition other) {
    _$v = other as _$HeatmapPosition;
  }

  @override
  void update(void Function(HeatmapPositionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HeatmapPosition build() => _build();

  _$HeatmapPosition _build() {
    final _$result =
        _$v ??
        _$HeatmapPosition._(
          driverId: driverId,
          lat: lat,
          lng: lng,
          vehicleType: vehicleType,
          isAvailable: isAvailable,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
