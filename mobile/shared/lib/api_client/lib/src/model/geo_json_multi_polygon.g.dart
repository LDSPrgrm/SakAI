// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_multi_polygon.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONMultiPolygonTypeEnum _$geoJSONMultiPolygonTypeEnum_multiPolygon =
    const GeoJSONMultiPolygonTypeEnum._('multiPolygon');

GeoJSONMultiPolygonTypeEnum _$geoJSONMultiPolygonTypeEnumValueOf(String name) {
  switch (name) {
    case 'multiPolygon':
      return _$geoJSONMultiPolygonTypeEnum_multiPolygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONMultiPolygonTypeEnum>
_$geoJSONMultiPolygonTypeEnumValues = BuiltSet<GeoJSONMultiPolygonTypeEnum>(
  const <GeoJSONMultiPolygonTypeEnum>[
    _$geoJSONMultiPolygonTypeEnum_multiPolygon,
  ],
);

Serializer<GeoJSONMultiPolygonTypeEnum>
_$geoJSONMultiPolygonTypeEnumSerializer =
    _$GeoJSONMultiPolygonTypeEnumSerializer();

class _$GeoJSONMultiPolygonTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONMultiPolygonTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'multiPolygon': 'MultiPolygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MultiPolygon': 'multiPolygon',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONMultiPolygonTypeEnum];
  @override
  final String wireName = 'GeoJSONMultiPolygonTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONMultiPolygonTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONMultiPolygonTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONMultiPolygonTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONMultiPolygon extends GeoJSONMultiPolygon {
  @override
  final GeoJSONMultiPolygonTypeEnum type;
  @override
  final BuiltList<BuiltList<BuiltList<BuiltList<num>>>> coordinates;

  factory _$GeoJSONMultiPolygon([
    void Function(GeoJSONMultiPolygonBuilder)? updates,
  ]) => (GeoJSONMultiPolygonBuilder()..update(updates))._build();

  _$GeoJSONMultiPolygon._({required this.type, required this.coordinates})
    : super._();
  @override
  GeoJSONMultiPolygon rebuild(
    void Function(GeoJSONMultiPolygonBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GeoJSONMultiPolygonBuilder toBuilder() =>
      GeoJSONMultiPolygonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONMultiPolygon &&
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
    return (newBuiltValueToStringHelper(r'GeoJSONMultiPolygon')
          ..add('type', type)
          ..add('coordinates', coordinates))
        .toString();
  }
}

class GeoJSONMultiPolygonBuilder
    implements Builder<GeoJSONMultiPolygon, GeoJSONMultiPolygonBuilder> {
  _$GeoJSONMultiPolygon? _$v;

  GeoJSONMultiPolygonTypeEnum? _type;
  GeoJSONMultiPolygonTypeEnum? get type => _$this._type;
  set type(GeoJSONMultiPolygonTypeEnum? type) => _$this._type = type;

  ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>? _coordinates;
  ListBuilder<BuiltList<BuiltList<BuiltList<num>>>> get coordinates =>
      _$this._coordinates ??=
          ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>();
  set coordinates(
    ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>? coordinates,
  ) => _$this._coordinates = coordinates;

  GeoJSONMultiPolygonBuilder() {
    GeoJSONMultiPolygon._defaults(this);
  }

  GeoJSONMultiPolygonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _coordinates = $v.coordinates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONMultiPolygon other) {
    _$v = other as _$GeoJSONMultiPolygon;
  }

  @override
  void update(void Function(GeoJSONMultiPolygonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONMultiPolygon build() => _build();

  _$GeoJSONMultiPolygon _build() {
    _$GeoJSONMultiPolygon _$result;
    try {
      _$result =
          _$v ??
          _$GeoJSONMultiPolygon._(
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'GeoJSONMultiPolygon',
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
          r'GeoJSONMultiPolygon',
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
