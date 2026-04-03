// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverSummary extends DriverSummary {
  @override
  final String id;
  @override
  final String name;
  @override
  final VehicleInfo vehicle;
  @override
  final LatLng? currentLocation;

  factory _$DriverSummary([void Function(DriverSummaryBuilder)? updates]) =>
      (DriverSummaryBuilder()..update(updates))._build();

  _$DriverSummary._({
    required this.id,
    required this.name,
    required this.vehicle,
    this.currentLocation,
  }) : super._();
  @override
  DriverSummary rebuild(void Function(DriverSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverSummaryBuilder toBuilder() => DriverSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverSummary &&
        id == other.id &&
        name == other.name &&
        vehicle == other.vehicle &&
        currentLocation == other.currentLocation;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, vehicle.hashCode);
    _$hash = $jc(_$hash, currentLocation.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverSummary')
          ..add('id', id)
          ..add('name', name)
          ..add('vehicle', vehicle)
          ..add('currentLocation', currentLocation))
        .toString();
  }
}

class DriverSummaryBuilder
    implements Builder<DriverSummary, DriverSummaryBuilder> {
  _$DriverSummary? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  VehicleInfoBuilder? _vehicle;
  VehicleInfoBuilder get vehicle => _$this._vehicle ??= VehicleInfoBuilder();
  set vehicle(VehicleInfoBuilder? vehicle) => _$this._vehicle = vehicle;

  LatLngBuilder? _currentLocation;
  LatLngBuilder get currentLocation =>
      _$this._currentLocation ??= LatLngBuilder();
  set currentLocation(LatLngBuilder? currentLocation) =>
      _$this._currentLocation = currentLocation;

  DriverSummaryBuilder() {
    DriverSummary._defaults(this);
  }

  DriverSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _vehicle = $v.vehicle.toBuilder();
      _currentLocation = $v.currentLocation?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverSummary other) {
    _$v = other as _$DriverSummary;
  }

  @override
  void update(void Function(DriverSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverSummary build() => _build();

  _$DriverSummary _build() {
    _$DriverSummary _$result;
    try {
      _$result =
          _$v ??
          _$DriverSummary._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'DriverSummary',
              'id',
            ),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'DriverSummary',
              'name',
            ),
            vehicle: vehicle.build(),
            currentLocation: _currentLocation?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'vehicle';
        vehicle.build();
        _$failedField = 'currentLocation';
        _currentLocation?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DriverSummary',
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
