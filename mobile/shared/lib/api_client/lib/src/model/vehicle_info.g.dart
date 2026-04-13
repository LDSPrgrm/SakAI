// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_info.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VehicleInfo extends VehicleInfo {
  @override
  final String make;
  @override
  final String model;
  @override
  final String color;
  @override
  final String plate;

  factory _$VehicleInfo([void Function(VehicleInfoBuilder)? updates]) =>
      (VehicleInfoBuilder()..update(updates))._build();

  _$VehicleInfo._({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
  }) : super._();
  @override
  VehicleInfo rebuild(void Function(VehicleInfoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleInfoBuilder toBuilder() => VehicleInfoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleInfo &&
        make == other.make &&
        model == other.model &&
        color == other.color &&
        plate == other.plate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleInfo')
          ..add('make', make)
          ..add('model', model)
          ..add('color', color)
          ..add('plate', plate))
        .toString();
  }
}

class VehicleInfoBuilder implements Builder<VehicleInfo, VehicleInfoBuilder> {
  _$VehicleInfo? _$v;

  String? _make;
  String? get make => _$this._make;
  set make(String? make) => _$this._make = make;

  String? _model;
  String? get model => _$this._model;
  set model(String? model) => _$this._model = model;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  String? _plate;
  String? get plate => _$this._plate;
  set plate(String? plate) => _$this._plate = plate;

  VehicleInfoBuilder() {
    VehicleInfo._defaults(this);
  }

  VehicleInfoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _make = $v.make;
      _model = $v.model;
      _color = $v.color;
      _plate = $v.plate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleInfo other) {
    _$v = other as _$VehicleInfo;
  }

  @override
  void update(void Function(VehicleInfoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleInfo build() => _build();

  _$VehicleInfo _build() {
    final _$result =
        _$v ??
        _$VehicleInfo._(
          make: BuiltValueNullFieldError.checkNotNull(
            make,
            r'VehicleInfo',
            'make',
          ),
          model: BuiltValueNullFieldError.checkNotNull(
            model,
            r'VehicleInfo',
            'model',
          ),
          color: BuiltValueNullFieldError.checkNotNull(
            color,
            r'VehicleInfo',
            'color',
          ),
          plate: BuiltValueNullFieldError.checkNotNull(
            plate,
            r'VehicleInfo',
            'plate',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
