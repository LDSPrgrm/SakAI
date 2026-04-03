// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_polygon.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONPolygonTypeEnum _$geoJSONPolygonTypeEnum_polygon =
    const GeoJSONPolygonTypeEnum._('polygon');

GeoJSONPolygonTypeEnum _$geoJSONPolygonTypeEnumValueOf(String name) {
  switch (name) {
    case 'polygon':
      return _$geoJSONPolygonTypeEnum_polygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONPolygonTypeEnum> _$geoJSONPolygonTypeEnumValues =
    BuiltSet<GeoJSONPolygonTypeEnum>(const <GeoJSONPolygonTypeEnum>[
      _$geoJSONPolygonTypeEnum_polygon,
    ]);

Serializer<GeoJSONPolygonTypeEnum> _$geoJSONPolygonTypeEnumSerializer =
    _$GeoJSONPolygonTypeEnumSerializer();

class _$GeoJSONPolygonTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONPolygonTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'polygon': 'Polygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Polygon': 'polygon',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONPolygonTypeEnum];
  @override
  final String wireName = 'GeoJSONPolygonTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONPolygonTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONPolygonTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONPolygonTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONPolygon extends GeoJSONPolygon {
  @override
  final GeoJSONPolygonTypeEnum type;
  @override
  final BuiltList<BuiltList<BuiltList<num>>> coordinates;

  factory _$GeoJSONPolygon([void Function(GeoJSONPolygonBuilder)? updates]) =>
      (GeoJSONPolygonBuilder()..update(updates))._build();

  _$GeoJSONPolygon._({required this.type, required this.coordinates})
    : super._();
  @override
  GeoJSONPolygon rebuild(void Function(GeoJSONPolygonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONPolygonBuilder toBuilder() => GeoJSONPolygonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONPolygon &&
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
    return (newBuiltValueToStringHelper(r'GeoJSONPolygon')
          ..add('type', type)
          ..add('coordinates', coordinates))
        .toString();
  }
}

class GeoJSONPolygonBuilder
    implements Builder<GeoJSONPolygon, GeoJSONPolygonBuilder> {
  _$GeoJSONPolygon? _$v;

  GeoJSONPolygonTypeEnum? _type;
  GeoJSONPolygonTypeEnum? get type => _$this._type;
  set type(GeoJSONPolygonTypeEnum? type) => _$this._type = type;

  ListBuilder<BuiltList<BuiltList<num>>>? _coordinates;
  ListBuilder<BuiltList<BuiltList<num>>> get coordinates =>
      _$this._coordinates ??= ListBuilder<BuiltList<BuiltList<num>>>();
  set coordinates(ListBuilder<BuiltList<BuiltList<num>>>? coordinates) =>
      _$this._coordinates = coordinates;

  GeoJSONPolygonBuilder() {
    GeoJSONPolygon._defaults(this);
  }

  GeoJSONPolygonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _coordinates = $v.coordinates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONPolygon other) {
    _$v = other as _$GeoJSONPolygon;
  }

  @override
  void update(void Function(GeoJSONPolygonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONPolygon build() => _build();

  _$GeoJSONPolygon _build() {
    _$GeoJSONPolygon _$result;
    try {
      _$result =
          _$v ??
          _$GeoJSONPolygon._(
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'GeoJSONPolygon',
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
          r'GeoJSONPolygon',
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
