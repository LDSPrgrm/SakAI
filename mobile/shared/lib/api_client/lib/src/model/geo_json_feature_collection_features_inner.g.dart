// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_feature_collection_features_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONFeatureCollectionFeaturesInnerTypeEnum
    _$geoJSONFeatureCollectionFeaturesInnerTypeEnum_feature =
    const GeoJSONFeatureCollectionFeaturesInnerTypeEnum._('feature');

GeoJSONFeatureCollectionFeaturesInnerTypeEnum
    _$geoJSONFeatureCollectionFeaturesInnerTypeEnumValueOf(String name) {
  switch (name) {
    case 'feature':
      return _$geoJSONFeatureCollectionFeaturesInnerTypeEnum_feature;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONFeatureCollectionFeaturesInnerTypeEnum>
    _$geoJSONFeatureCollectionFeaturesInnerTypeEnumValues = BuiltSet<
        GeoJSONFeatureCollectionFeaturesInnerTypeEnum>(const <GeoJSONFeatureCollectionFeaturesInnerTypeEnum>[
  _$geoJSONFeatureCollectionFeaturesInnerTypeEnum_feature,
]);

Serializer<GeoJSONFeatureCollectionFeaturesInnerTypeEnum>
    _$geoJSONFeatureCollectionFeaturesInnerTypeEnumSerializer =
    _$GeoJSONFeatureCollectionFeaturesInnerTypeEnumSerializer();

class _$GeoJSONFeatureCollectionFeaturesInnerTypeEnumSerializer
    implements
        PrimitiveSerializer<GeoJSONFeatureCollectionFeaturesInnerTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'feature': 'Feature',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Feature': 'feature',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GeoJSONFeatureCollectionFeaturesInnerTypeEnum
  ];
  @override
  final String wireName = 'GeoJSONFeatureCollectionFeaturesInnerTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GeoJSONFeatureCollectionFeaturesInnerTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GeoJSONFeatureCollectionFeaturesInnerTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GeoJSONFeatureCollectionFeaturesInnerTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GeoJSONFeatureCollectionFeaturesInner
    extends GeoJSONFeatureCollectionFeaturesInner {
  @override
  final GeoJSONFeatureCollectionFeaturesInnerTypeEnum type;
  @override
  final GeoJSONFeatureCollectionFeaturesInnerGeometry geometry;
  @override
  final BuiltMap<String, JsonObject?>? properties;

  factory _$GeoJSONFeatureCollectionFeaturesInner(
          [void Function(GeoJSONFeatureCollectionFeaturesInnerBuilder)?
              updates]) =>
      (GeoJSONFeatureCollectionFeaturesInnerBuilder()..update(updates))
          ._build();

  _$GeoJSONFeatureCollectionFeaturesInner._(
      {required this.type, required this.geometry, this.properties})
      : super._();
  @override
  GeoJSONFeatureCollectionFeaturesInner rebuild(
          void Function(GeoJSONFeatureCollectionFeaturesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONFeatureCollectionFeaturesInnerBuilder toBuilder() =>
      GeoJSONFeatureCollectionFeaturesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONFeatureCollectionFeaturesInner &&
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
    return (newBuiltValueToStringHelper(
            r'GeoJSONFeatureCollectionFeaturesInner')
          ..add('type', type)
          ..add('geometry', geometry)
          ..add('properties', properties))
        .toString();
  }
}

class GeoJSONFeatureCollectionFeaturesInnerBuilder
    implements
        Builder<GeoJSONFeatureCollectionFeaturesInner,
            GeoJSONFeatureCollectionFeaturesInnerBuilder> {
  _$GeoJSONFeatureCollectionFeaturesInner? _$v;

  GeoJSONFeatureCollectionFeaturesInnerTypeEnum? _type;
  GeoJSONFeatureCollectionFeaturesInnerTypeEnum? get type => _$this._type;
  set type(GeoJSONFeatureCollectionFeaturesInnerTypeEnum? type) =>
      _$this._type = type;

  GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder? _geometry;
  GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder get geometry =>
      _$this._geometry ??=
          GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder();
  set geometry(
          GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder? geometry) =>
      _$this._geometry = geometry;

  MapBuilder<String, JsonObject?>? _properties;
  MapBuilder<String, JsonObject?> get properties =>
      _$this._properties ??= MapBuilder<String, JsonObject?>();
  set properties(MapBuilder<String, JsonObject?>? properties) =>
      _$this._properties = properties;

  GeoJSONFeatureCollectionFeaturesInnerBuilder() {
    GeoJSONFeatureCollectionFeaturesInner._defaults(this);
  }

  GeoJSONFeatureCollectionFeaturesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _geometry = $v.geometry.toBuilder();
      _properties = $v.properties?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONFeatureCollectionFeaturesInner other) {
    _$v = other as _$GeoJSONFeatureCollectionFeaturesInner;
  }

  @override
  void update(
      void Function(GeoJSONFeatureCollectionFeaturesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONFeatureCollectionFeaturesInner build() => _build();

  _$GeoJSONFeatureCollectionFeaturesInner _build() {
    _$GeoJSONFeatureCollectionFeaturesInner _$result;
    try {
      _$result = _$v ??
          _$GeoJSONFeatureCollectionFeaturesInner._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GeoJSONFeatureCollectionFeaturesInner', 'type'),
            geometry: geometry.build(),
            properties: _properties?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'geometry';
        geometry.build();
        _$failedField = 'properties';
        _properties?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GeoJSONFeatureCollectionFeaturesInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
