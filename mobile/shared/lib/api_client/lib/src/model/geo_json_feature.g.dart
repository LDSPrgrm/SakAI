// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_feature.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONFeatureTypeEnum _$geoJSONFeatureTypeEnum_feature =
    const GeoJSONFeatureTypeEnum._('feature');

GeoJSONFeatureTypeEnum _$geoJSONFeatureTypeEnumValueOf(String name) {
  switch (name) {
    case 'feature':
      return _$geoJSONFeatureTypeEnum_feature;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONFeatureTypeEnum> _$geoJSONFeatureTypeEnumValues =
    BuiltSet<GeoJSONFeatureTypeEnum>(const <GeoJSONFeatureTypeEnum>[
      _$geoJSONFeatureTypeEnum_feature,
    ]);

Serializer<GeoJSONFeatureTypeEnum> _$geoJSONFeatureTypeEnumSerializer =
    _$GeoJSONFeatureTypeEnumSerializer();

class _$GeoJSONFeatureTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONFeatureTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'feature': 'Feature',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Feature': 'feature',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONFeatureTypeEnum];
  @override
  final String wireName = 'GeoJSONFeatureTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONFeatureTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONFeatureTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONFeatureTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONFeature extends GeoJSONFeature {
  @override
  final GeoJSONFeatureTypeEnum type;
  @override
  final GeoJSONGeometry geometry;
  @override
  final JsonObject properties;

  factory _$GeoJSONFeature([void Function(GeoJSONFeatureBuilder)? updates]) =>
      (GeoJSONFeatureBuilder()..update(updates))._build();

  _$GeoJSONFeature._({
    required this.type,
    required this.geometry,
    required this.properties,
  }) : super._();
  @override
  GeoJSONFeature rebuild(void Function(GeoJSONFeatureBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONFeatureBuilder toBuilder() => GeoJSONFeatureBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONFeature &&
        type == other.type &&
        geometry == other.geometry &&
        properties == other.properties;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, geometry.hashCode);
    _$hash = $jc(_$hash, properties.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoJSONFeature')
          ..add('type', type)
          ..add('geometry', geometry)
          ..add('properties', properties))
        .toString();
  }
}

class GeoJSONFeatureBuilder
    implements Builder<GeoJSONFeature, GeoJSONFeatureBuilder> {
  _$GeoJSONFeature? _$v;

  GeoJSONFeatureTypeEnum? _type;
  GeoJSONFeatureTypeEnum? get type => _$this._type;
  set type(GeoJSONFeatureTypeEnum? type) => _$this._type = type;

  GeoJSONGeometryBuilder? _geometry;
  GeoJSONGeometryBuilder get geometry =>
      _$this._geometry ??= GeoJSONGeometryBuilder();
  set geometry(GeoJSONGeometryBuilder? geometry) => _$this._geometry = geometry;

  JsonObject? _properties;
  JsonObject? get properties => _$this._properties;
  set properties(JsonObject? properties) => _$this._properties = properties;

  GeoJSONFeatureBuilder() {
    GeoJSONFeature._defaults(this);
  }

  GeoJSONFeatureBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _geometry = $v.geometry.toBuilder();
      _properties = $v.properties;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONFeature other) {
    _$v = other as _$GeoJSONFeature;
  }

  @override
  void update(void Function(GeoJSONFeatureBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONFeature build() => _build();

  _$GeoJSONFeature _build() {
    _$GeoJSONFeature _$result;
    try {
      _$result =
          _$v ??
          _$GeoJSONFeature._(
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'GeoJSONFeature',
              'type',
            ),
            geometry: geometry.build(),
            properties: BuiltValueNullFieldError.checkNotNull(
              properties,
              r'GeoJSONFeature',
              'properties',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'geometry';
        geometry.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GeoJSONFeature',
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
