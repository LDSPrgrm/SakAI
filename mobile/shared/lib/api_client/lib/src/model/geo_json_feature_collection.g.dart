// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_json_feature_collection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GeoJSONFeatureCollectionTypeEnum
_$geoJSONFeatureCollectionTypeEnum_featureCollection =
    const GeoJSONFeatureCollectionTypeEnum._('featureCollection');

GeoJSONFeatureCollectionTypeEnum _$geoJSONFeatureCollectionTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'featureCollection':
      return _$geoJSONFeatureCollectionTypeEnum_featureCollection;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GeoJSONFeatureCollectionTypeEnum>
_$geoJSONFeatureCollectionTypeEnumValues =
    BuiltSet<GeoJSONFeatureCollectionTypeEnum>(
      const <GeoJSONFeatureCollectionTypeEnum>[
        _$geoJSONFeatureCollectionTypeEnum_featureCollection,
      ],
    );

Serializer<GeoJSONFeatureCollectionTypeEnum>
_$geoJSONFeatureCollectionTypeEnumSerializer =
    _$GeoJSONFeatureCollectionTypeEnumSerializer();

class _$GeoJSONFeatureCollectionTypeEnumSerializer
    implements PrimitiveSerializer<GeoJSONFeatureCollectionTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'featureCollection': 'FeatureCollection',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'FeatureCollection': 'featureCollection',
  };

  @override
  final Iterable<Type> types = const <Type>[GeoJSONFeatureCollectionTypeEnum];
  @override
  final String wireName = 'GeoJSONFeatureCollectionTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    GeoJSONFeatureCollectionTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  GeoJSONFeatureCollectionTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => GeoJSONFeatureCollectionTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$GeoJSONFeatureCollection extends GeoJSONFeatureCollection {
  @override
  final GeoJSONFeatureCollectionTypeEnum type;
  @override
  final BuiltList<GeoJSONFeatureCollectionFeaturesInner> features;

  factory _$GeoJSONFeatureCollection([
    void Function(GeoJSONFeatureCollectionBuilder)? updates,
  ]) => (GeoJSONFeatureCollectionBuilder()..update(updates))._build();

  _$GeoJSONFeatureCollection._({required this.type, required this.features})
    : super._();
  @override
  GeoJSONFeatureCollection rebuild(
    void Function(GeoJSONFeatureCollectionBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  GeoJSONFeatureCollectionBuilder toBuilder() =>
      GeoJSONFeatureCollectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GeoJSONFeatureCollection &&
        type == other.type &&
        features == other.features;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GeoJSONFeatureCollection')
          ..add('type', type)
          ..add('features', features))
        .toString();
  }
}

class GeoJSONFeatureCollectionBuilder
    implements
        Builder<GeoJSONFeatureCollection, GeoJSONFeatureCollectionBuilder> {
  _$GeoJSONFeatureCollection? _$v;

  GeoJSONFeatureCollectionTypeEnum? _type;
  GeoJSONFeatureCollectionTypeEnum? get type => _$this._type;
  set type(GeoJSONFeatureCollectionTypeEnum? type) => _$this._type = type;

  ListBuilder<GeoJSONFeatureCollectionFeaturesInner>? _features;
  ListBuilder<GeoJSONFeatureCollectionFeaturesInner> get features =>
      _$this._features ??= ListBuilder<GeoJSONFeatureCollectionFeaturesInner>();
  set features(ListBuilder<GeoJSONFeatureCollectionFeaturesInner>? features) =>
      _$this._features = features;

  GeoJSONFeatureCollectionBuilder() {
    GeoJSONFeatureCollection._defaults(this);
  }

  GeoJSONFeatureCollectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _features = $v.features.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GeoJSONFeatureCollection other) {
    _$v = other as _$GeoJSONFeatureCollection;
  }

  @override
  void update(void Function(GeoJSONFeatureCollectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GeoJSONFeatureCollection build() => _build();

  _$GeoJSONFeatureCollection _build() {
    _$GeoJSONFeatureCollection _$result;
    try {
      _$result =
          _$v ??
          _$GeoJSONFeatureCollection._(
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'GeoJSONFeatureCollection',
              'type',
            ),
            features: features.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GeoJSONFeatureCollection',
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
