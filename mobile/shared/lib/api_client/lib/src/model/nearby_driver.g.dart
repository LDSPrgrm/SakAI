// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_driver.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NearbyDriverProviderEnum _$nearbyDriverProviderEnum_gcash =
    const NearbyDriverProviderEnum._('gcash');
const NearbyDriverProviderEnum _$nearbyDriverProviderEnum_paymaya =
    const NearbyDriverProviderEnum._('paymaya');
const NearbyDriverProviderEnum _$nearbyDriverProviderEnum_card =
    const NearbyDriverProviderEnum._('card');
const NearbyDriverProviderEnum _$nearbyDriverProviderEnum_cash =
    const NearbyDriverProviderEnum._('cash');

NearbyDriverProviderEnum _$nearbyDriverProviderEnumValueOf(String name) {
  switch (name) {
    case 'gcash':
      return _$nearbyDriverProviderEnum_gcash;
    case 'paymaya':
      return _$nearbyDriverProviderEnum_paymaya;
    case 'card':
      return _$nearbyDriverProviderEnum_card;
    case 'cash':
      return _$nearbyDriverProviderEnum_cash;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NearbyDriverProviderEnum> _$nearbyDriverProviderEnumValues =
    BuiltSet<NearbyDriverProviderEnum>(const <NearbyDriverProviderEnum>[
      _$nearbyDriverProviderEnum_gcash,
      _$nearbyDriverProviderEnum_paymaya,
      _$nearbyDriverProviderEnum_card,
      _$nearbyDriverProviderEnum_cash,
    ]);

Serializer<NearbyDriverProviderEnum> _$nearbyDriverProviderEnumSerializer =
    _$NearbyDriverProviderEnumSerializer();

class _$NearbyDriverProviderEnumSerializer
    implements PrimitiveSerializer<NearbyDriverProviderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
    'cash': 'cash',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
    'cash': 'cash',
  };

  @override
  final Iterable<Type> types = const <Type>[NearbyDriverProviderEnum];
  @override
  final String wireName = 'NearbyDriverProviderEnum';

  @override
  Object serialize(
    Serializers serializers,
    NearbyDriverProviderEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NearbyDriverProviderEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NearbyDriverProviderEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NearbyDriver extends NearbyDriver {
  @override
  final String id;
  @override
  final NearbyDriverProviderEnum? provider;
  @override
  final BuiltMap<String, String>? configFields;
  @override
  final bool? isActive;
  @override
  final DateTime? updatedAt;

  factory _$NearbyDriver([void Function(NearbyDriverBuilder)? updates]) =>
      (NearbyDriverBuilder()..update(updates))._build();

  _$NearbyDriver._({
    required this.id,
    this.provider,
    this.configFields,
    this.isActive,
    this.updatedAt,
  }) : super._();
  @override
  NearbyDriver rebuild(void Function(NearbyDriverBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NearbyDriverBuilder toBuilder() => NearbyDriverBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NearbyDriver &&
        id == other.id &&
        provider == other.provider &&
        configFields == other.configFields &&
        isActive == other.isActive &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, configFields.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NearbyDriver')
          ..add('id', id)
          ..add('provider', provider)
          ..add('configFields', configFields)
          ..add('isActive', isActive)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class NearbyDriverBuilder
    implements Builder<NearbyDriver, NearbyDriverBuilder> {
  _$NearbyDriver? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  NearbyDriverProviderEnum? _provider;
  NearbyDriverProviderEnum? get provider => _$this._provider;
  set provider(NearbyDriverProviderEnum? provider) =>
      _$this._provider = provider;

  MapBuilder<String, String>? _configFields;
  MapBuilder<String, String> get configFields =>
      _$this._configFields ??= MapBuilder<String, String>();
  set configFields(MapBuilder<String, String>? configFields) =>
      _$this._configFields = configFields;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  NearbyDriverBuilder() {
    NearbyDriver._defaults(this);
  }

  NearbyDriverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _provider = $v.provider;
      _configFields = $v.configFields?.toBuilder();
      _isActive = $v.isActive;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NearbyDriver other) {
    _$v = other as _$NearbyDriver;
  }

  @override
  void update(void Function(NearbyDriverBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NearbyDriver build() => _build();

  _$NearbyDriver _build() {
    _$NearbyDriver _$result;
    try {
      _$result =
          _$v ??
          _$NearbyDriver._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'NearbyDriver',
              'id',
            ),
            provider: provider,
            configFields: _configFields?.build(),
            isActive: isActive,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configFields';
        _configFields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'NearbyDriver',
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
