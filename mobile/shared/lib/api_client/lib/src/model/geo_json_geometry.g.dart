// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_geometry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONGeometryTypeEnum _$geoJSONGeometryTypeEnum_point =
    const GeoJSONGeometryTypeEnum._('point');
const GeoJSONGeometryTypeEnum _$geoJSONGeometryTypeEnum_polygon =
    const GeoJSONGeometryTypeEnum._('polygon');
const GeoJSONGeometryTypeEnum _$geoJSONGeometryTypeEnum_multiPolygon =
    const GeoJSONGeometryTypeEnum._('multiPolygon');

GeoJSONGeometryTypeEnum _$geoJSONGeometryTypeEnumValueOf(String name) {
  switch (name) {
    case 'point':
      return _$geoJSONGeometryTypeEnum_point;
    case 'polygon':
      return _$geoJSONGeometryTypeEnum_polygon;
    case 'multiPolygon':
      return _$geoJSONGeometryTypeEnum_multiPolygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONGeometryTypeEnum> _$geoJSONGeometryTypeEnumValues =
    BuiltSet<GeoJSONGeometryTypeEnum>(const <GeoJSONGeometryTypeEnum>[
      _$geoJSONGeometryTypeEnum_point,
      _$geoJSONGeometryTypeEnum_polygon,
      _$geoJSONGeometryTypeEnum_multiPolygon,
    ]);

Serializer<GeoJSONGeometryTypeEnum> _$geoJSONGeometryTypeEnumSerializer =
    _$GeoJSONGeometryTypeEnumSerializer();

class _$GeoJSONGeometryTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONGeometryTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'point': 'Point',
    'polygon': 'Polygon',
    'multiPolygon': 'MultiPolygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Point': 'point',
    'Polygon': 'polygon',
    'MultiPolygon': 'multiPolygon',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONGeometryTypeEnum];
  @override
  final String wireName = 'GeoJSONGeometryTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONGeometryTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONGeometryTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONGeometryTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONGeometry extends GeoJSONGeometry {
  @override
  final OneOf oneOf;

  factory _$GeoJSONGeometry([void Function(GeoJSONGeometryBuilder)? updates]) =>
      (GeoJSONGeometryBuilder()..update(updates))._build();

  _$GeoJSONGeometry._({required this.oneOf}) : super._();
  @override
  GeoJSONGeometry rebuild(void Function(GeoJSONGeometryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONGeometryBuilder toBuilder() => GeoJSONGeometryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONGeometry && oneOf == other.oneOf;
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
      r'GeoJSONGeometry',
    )..add('oneOf', oneOf)).toString();
  }
}

class GeoJSONGeometryBuilder
    implements Builder<GeoJSONGeometry, GeoJSONGeometryBuilder> {
  _$GeoJSONGeometry? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  GeoJSONGeometryBuilder() {
    GeoJSONGeometry._defaults(this);
  }

  GeoJSONGeometryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONGeometry other) {
    _$v = other as _$GeoJSONGeometry;
  }

  @override
  void update(void Function(GeoJSONGeometryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONGeometry build() => _build();

  _$GeoJSONGeometry _build() {
    final _$result =
        _$v ??
        _$GeoJSONGeometry._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
            oneOf,
            r'GeoJSONGeometry',
            'oneOf',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
