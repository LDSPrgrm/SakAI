// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_point.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONPointTypeEnum _$geoJSONPointTypeEnum_point =
    const GeoJSONPointTypeEnum._('point');

GeoJSONPointTypeEnum _$geoJSONPointTypeEnumValueOf(String name) {
  switch (name) {
    case 'point':
      return _$geoJSONPointTypeEnum_point;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONPointTypeEnum> _$geoJSONPointTypeEnumValues =
    BuiltSet<GeoJSONPointTypeEnum>(const <GeoJSONPointTypeEnum>[
      _$geoJSONPointTypeEnum_point,
    ]);

Serializer<GeoJSONPointTypeEnum> _$geoJSONPointTypeEnumSerializer =
    _$GeoJSONPointTypeEnumSerializer();

class _$GeoJSONPointTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONPointTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'point': 'Point',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Point': 'point',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONPointTypeEnum];
  @override
  final String wireName = 'GeoJSONPointTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONPointTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONPointTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONPointTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONPoint extends GeoJSONPoint {
  @override
  final GeoJSONPointTypeEnum type;
  @override
  final BuiltList<num> coordinates;

  factory _$GeoJSONPoint([void Function(GeoJSONPointBuilder)? updates]) =>
      (GeoJSONPointBuilder()..update(updates))._build();

  _$GeoJSONPoint._({required this.type, required this.coordinates}) : super._();
  @override
  GeoJSONPoint rebuild(void Function(GeoJSONPointBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONPointBuilder toBuilder() => GeoJSONPointBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONPoint &&
        type == other.type &&
        coordinates == other.coordinates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, coordinates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoJSONPoint')
          ..add('type', type)
          ..add('coordinates', coordinates))
        .toString();
  }
}

class GeoJSONPointBuilder
    implements Builder<GeoJSONPoint, GeoJSONPointBuilder> {
  _$GeoJSONPoint? _$v;

  GeoJSONPointTypeEnum? _type;
  GeoJSONPointTypeEnum? get type => _$this._type;
  set type(GeoJSONPointTypeEnum? type) => _$this._type = type;

  ListBuilder<num>? _coordinates;
  ListBuilder<num> get coordinates =>
      _$this._coordinates ??= ListBuilder<num>();
  set coordinates(ListBuilder<num>? coordinates) =>
      _$this._coordinates = coordinates;

  GeoJSONPointBuilder() {
    GeoJSONPoint._defaults(this);
  }

  GeoJSONPointBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _coordinates = $v.coordinates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONPoint other) {
    _$v = other as _$GeoJSONPoint;
  }

  @override
  void update(void Function(GeoJSONPointBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONPoint build() => _build();

  _$GeoJSONPoint _build() {
    _$GeoJSONPoint _$result;
    try {
      _$result =
          _$v ??
          _$GeoJSONPoint._(
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'GeoJSONPoint',
              'type',
            ),
            coordinates: coordinates.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GeoJSONPoint',
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
