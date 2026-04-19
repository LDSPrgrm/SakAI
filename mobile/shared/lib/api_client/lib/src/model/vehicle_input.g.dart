// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const VehicleInputVehicleTypeEnum _$vehicleInputVehicleTypeEnum_motorcycle =
    const VehicleInputVehicleTypeEnum._('motorcycle');
const VehicleInputVehicleTypeEnum _$vehicleInputVehicleTypeEnum_car =
    const VehicleInputVehicleTypeEnum._('car');
const VehicleInputVehicleTypeEnum _$vehicleInputVehicleTypeEnum_tricycle =
    const VehicleInputVehicleTypeEnum._('tricycle');

VehicleInputVehicleTypeEnum _$vehicleInputVehicleTypeEnumValueOf(String name) {
  switch (name) {
    case 'motorcycle':
      return _$vehicleInputVehicleTypeEnum_motorcycle;
    case 'car':
      return _$vehicleInputVehicleTypeEnum_car;
    case 'tricycle':
      return _$vehicleInputVehicleTypeEnum_tricycle;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<VehicleInputVehicleTypeEnum>
_$vehicleInputVehicleTypeEnumValues =
    BuiltSet<VehicleInputVehicleTypeEnum>(const <VehicleInputVehicleTypeEnum>[
      _$vehicleInputVehicleTypeEnum_motorcycle,
      _$vehicleInputVehicleTypeEnum_car,
      _$vehicleInputVehicleTypeEnum_tricycle,
    ]);

Serializer<VehicleInputVehicleTypeEnum>
_$vehicleInputVehicleTypeEnumSerializer =
    _$VehicleInputVehicleTypeEnumSerializer();

class _$VehicleInputVehicleTypeEnumSerializer
    implements PrimitiveSerializer<VehicleInputVehicleTypeEnum> {
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
  final Iterable<Type> types = const <Type>[VehicleInputVehicleTypeEnum];
  @override
  final String wireName = 'VehicleInputVehicleTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    VehicleInputVehicleTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  VehicleInputVehicleTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => VehicleInputVehicleTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$VehicleInput extends VehicleInput {
  @override
  final String make;
  @override
  final String model;
  @override
  final String color;
  @override
  final String plate;
  @override
  final VehicleInputVehicleTypeEnum vehicleType;

  factory _$VehicleInput([void Function(VehicleInputBuilder)? updates]) =>
      (VehicleInputBuilder()..update(updates))._build();

  _$VehicleInput._({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
    required this.vehicleType,
  }) : super._();
  @override
  VehicleInput rebuild(void Function(VehicleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VehicleInputBuilder toBuilder() => VehicleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VehicleInput &&
        make == other.make &&
        model == other.model &&
        color == other.color &&
        plate == other.plate &&
        vehicleType == other.vehicleType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, make.hashCode);
    _$hash = $jc(_$hash, model.hashCode);
    _$hash = $jc(_$hash, color.hashCode);
    _$hash = $jc(_$hash, plate.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VehicleInput')
          ..add('make', make)
          ..add('model', model)
          ..add('color', color)
          ..add('plate', plate)
          ..add('vehicleType', vehicleType))
        .toString();
  }
}

class VehicleInputBuilder
    implements Builder<VehicleInput, VehicleInputBuilder> {
  _$VehicleInput? _$v;

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

  VehicleInputVehicleTypeEnum? _vehicleType;
  VehicleInputVehicleTypeEnum? get vehicleType => _$this._vehicleType;
  set vehicleType(VehicleInputVehicleTypeEnum? vehicleType) =>
      _$this._vehicleType = vehicleType;

  VehicleInputBuilder() {
    VehicleInput._defaults(this);
  }

  VehicleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _make = $v.make;
      _model = $v.model;
      _color = $v.color;
      _plate = $v.plate;
      _vehicleType = $v.vehicleType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VehicleInput other) {
    _$v = other as _$VehicleInput;
  }

  @override
  void update(void Function(VehicleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VehicleInput build() => _build();

  _$VehicleInput _build() {
    final _$result =
        _$v ??
        _$VehicleInput._(
          make: BuiltValueNullFieldError.checkNotNull(
            make,
            r'VehicleInput',
            'make',
          ),
          model: BuiltValueNullFieldError.checkNotNull(
            model,
            r'VehicleInput',
            'model',
          ),
          color: BuiltValueNullFieldError.checkNotNull(
            color,
            r'VehicleInput',
            'color',
          ),
          plate: BuiltValueNullFieldError.checkNotNull(
            plate,
            r'VehicleInput',
            'plate',
          ),
          vehicleType: BuiltValueNullFieldError.checkNotNull(
            vehicleType,
            r'VehicleInput',
            'vehicleType',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
