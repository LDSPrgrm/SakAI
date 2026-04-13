// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_feature_collection_features_inner_geometry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum
    _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_polygon =
    const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum._('polygon');
const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum
    _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_multiPolygon =
    const GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum._(
        'multiPolygon');

GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum
    _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'polygon':
      return _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_polygon;
    case 'multiPolygon':
      return _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_multiPolygon;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum>
    _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumValues = BuiltSet<
        GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum>(const <GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum>[
  _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_polygon,
  _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum_multiPolygon,
]);

Serializer<GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum>
    _$geoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumSerializer =
    _$GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumSerializer();

class _$GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'polygon': 'Polygon',
    'multiPolygon': 'MultiPolygon',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Polygon': 'polygon',
    'MultiPolygon': 'multiPolygon',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum
  ];
  @override
  final String wireName =
      'GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GeoJSONFeatureCollectionFeaturesInnerGeometry
    extends GeoJSONFeatureCollectionFeaturesInnerGeometry {
  @override
  final GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum type;
  @override
  final BuiltList<BuiltList<BuiltList<num>>> coordinates;

  factory _$GeoJSONFeatureCollectionFeaturesInnerGeometry(
          [void Function(GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder)?
              updates]) =>
      (GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder()..update(updates))
          ._build();

  _$GeoJSONFeatureCollectionFeaturesInnerGeometry._(
      {required this.type, required this.coordinates})
      : super._();
  @override
  GeoJSONFeatureCollectionFeaturesInnerGeometry rebuild(
          void Function(GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder toBuilder() =>
      GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONFeatureCollectionFeaturesInnerGeometry &&
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
    return (newBuiltValueToStringHelper(
            r'GeoJSONFeatureCollectionFeaturesInnerGeometry')
          ..add('type', type)
          ..add('coordinates', coordinates))
        .toString();
  }
}

class GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder
    implements
        Builder<GeoJSONFeatureCollectionFeaturesInnerGeometry,
            GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder> {
  _$GeoJSONFeatureCollectionFeaturesInnerGeometry? _$v;

  GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum? _type;
  GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum? get type =>
      _$this._type;
  set type(GeoJSONFeatureCollectionFeaturesInnerGeometryTypeEnum? type) =>
      _$this._type = type;

  ListBuilder<BuiltList<BuiltList<num>>>? _coordinates;
  ListBuilder<BuiltList<BuiltList<num>>> get coordinates =>
      _$this._coordinates ??= ListBuilder<BuiltList<BuiltList<num>>>();
  set coordinates(ListBuilder<BuiltList<BuiltList<num>>>? coordinates) =>
      _$this._coordinates = coordinates;

  GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder() {
    GeoJSONFeatureCollectionFeaturesInnerGeometry._defaults(this);
  }

  GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _coordinates = $v.coordinates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONFeatureCollectionFeaturesInnerGeometry other) {
    _$v = other as _$GeoJSONFeatureCollectionFeaturesInnerGeometry;
  }

  @override
  void update(
      void Function(GeoJSONFeatureCollectionFeaturesInnerGeometryBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONFeatureCollectionFeaturesInnerGeometry build() => _build();

  _$GeoJSONFeatureCollectionFeaturesInnerGeometry _build() {
    _$GeoJSONFeatureCollectionFeaturesInnerGeometry _$result;
    try {
      _$result = _$v ??
          _$GeoJSONFeatureCollectionFeaturesInnerGeometry._(
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GeoJSONFeatureCollectionFeaturesInnerGeometry', 'type'),
            coordinates: coordinates.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GeoJSONFeatureCollectionFeaturesInnerGeometry',
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
