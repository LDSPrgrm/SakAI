// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_rule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AlertRuleTypeEnum _$alertRuleTypeEnum_lowRating =
    const AlertRuleTypeEnum._('lowRating');
const AlertRuleTypeEnum _$alertRuleTypeEnum_highCancellation =
    const AlertRuleTypeEnum._('highCancellation');
const AlertRuleTypeEnum _$alertRuleTypeEnum_fraudVelocity =
    const AlertRuleTypeEnum._('fraudVelocity');
const AlertRuleTypeEnum _$alertRuleTypeEnum_kycExpiry =
    const AlertRuleTypeEnum._('kycExpiry');

AlertRuleTypeEnum _$alertRuleTypeEnumValueOf(String name) {
  switch (name) {
    case 'lowRating':
      return _$alertRuleTypeEnum_lowRating;
    case 'highCancellation':
      return _$alertRuleTypeEnum_highCancellation;
    case 'fraudVelocity':
      return _$alertRuleTypeEnum_fraudVelocity;
    case 'kycExpiry':
      return _$alertRuleTypeEnum_kycExpiry;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AlertRuleTypeEnum> _$alertRuleTypeEnumValues =
    BuiltSet<AlertRuleTypeEnum>(const <AlertRuleTypeEnum>[
      _$alertRuleTypeEnum_lowRating,
      _$alertRuleTypeEnum_highCancellation,
      _$alertRuleTypeEnum_fraudVelocity,
      _$alertRuleTypeEnum_kycExpiry,
    ]);

Serializer<AlertRuleTypeEnum> _$alertRuleTypeEnumSerializer =
    _$AlertRuleTypeEnumSerializer();

class _$AlertRuleTypeEnumSerializer
    implements PrimitiveSerializer<AlertRuleTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'lowRating': 'low_rating',
    'highCancellation': 'high_cancellation',
    'fraudVelocity': 'fraud_velocity',
    'kycExpiry': 'kyc_expiry',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'low_rating': 'lowRating',
    'high_cancellation': 'highCancellation',
    'fraud_velocity': 'fraudVelocity',
    'kyc_expiry': 'kycExpiry',
  };

  @override
  final Iterable<Type> types = const <Type>[AlertRuleTypeEnum];
  @override
  final String wireName = 'AlertRuleTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AlertRuleTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AlertRuleTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AlertRuleTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AlertRule extends AlertRule {
  @override
  final String id;
  @override
  final String name;
  @override
  final AlertRuleTypeEnum type;
  @override
  final bool enabled;
  @override
  final BuiltMap<String, JsonObject?> config;
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$AlertRule([void Function(AlertRuleBuilder)? updates]) =>
      (AlertRuleBuilder()..update(updates))._build();

  _$AlertRule._({
    required this.id,
    required this.name,
    required this.type,
    required this.enabled,
    required this.config,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  }) : super._();
  @override
  AlertRule rebuild(void Function(AlertRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AlertRuleBuilder toBuilder() => AlertRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AlertRule &&
        id == other.id &&
        name == other.name &&
        type == other.type &&
        enabled == other.enabled &&
        config == other.config &&
        createdBy == other.createdBy &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AlertRule')
          ..add('id', id)
          ..add('name', name)
          ..add('type', type)
          ..add('enabled', enabled)
          ..add('config', config)
          ..add('createdBy', createdBy)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AlertRuleBuilder implements Builder<AlertRule, AlertRuleBuilder> {
  _$AlertRule? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AlertRuleTypeEnum? _type;
  AlertRuleTypeEnum? get type => _$this._type;
  set type(AlertRuleTypeEnum? type) => _$this._type = type;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  MapBuilder<String, JsonObject?>? _config;
  MapBuilder<String, JsonObject?> get config =>
      _$this._config ??= MapBuilder<String, JsonObject?>();
  set config(MapBuilder<String, JsonObject?>? config) =>
      _$this._config = config;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AlertRuleBuilder() {
    AlertRule._defaults(this);
  }

  AlertRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _type = $v.type;
      _enabled = $v.enabled;
      _config = $v.config.toBuilder();
      _createdBy = $v.createdBy;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AlertRule other) {
    _$v = other as _$AlertRule;
  }

  @override
  void update(void Function(AlertRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AlertRule build() => _build();

  _$AlertRule _build() {
    _$AlertRule _$result;
    try {
      _$result =
          _$v ??
          _$AlertRule._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'AlertRule', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'AlertRule',
              'name',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'AlertRule',
              'type',
            ),
            enabled: BuiltValueNullFieldError.checkNotNull(
              enabled,
              r'AlertRule',
              'enabled',
            ),
            config: config.build(),
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        config.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AlertRule',
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
