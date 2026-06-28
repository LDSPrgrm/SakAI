// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_rule_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AlertRuleInputTypeEnum _$alertRuleInputTypeEnum_lowRating =
    const AlertRuleInputTypeEnum._('lowRating');
const AlertRuleInputTypeEnum _$alertRuleInputTypeEnum_highCancellation =
    const AlertRuleInputTypeEnum._('highCancellation');
const AlertRuleInputTypeEnum _$alertRuleInputTypeEnum_fraudVelocity =
    const AlertRuleInputTypeEnum._('fraudVelocity');
const AlertRuleInputTypeEnum _$alertRuleInputTypeEnum_kycExpiry =
    const AlertRuleInputTypeEnum._('kycExpiry');

AlertRuleInputTypeEnum _$alertRuleInputTypeEnumValueOf(String name) {
  switch (name) {
    case 'lowRating':
      return _$alertRuleInputTypeEnum_lowRating;
    case 'highCancellation':
      return _$alertRuleInputTypeEnum_highCancellation;
    case 'fraudVelocity':
      return _$alertRuleInputTypeEnum_fraudVelocity;
    case 'kycExpiry':
      return _$alertRuleInputTypeEnum_kycExpiry;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AlertRuleInputTypeEnum> _$alertRuleInputTypeEnumValues =
    BuiltSet<AlertRuleInputTypeEnum>(const <AlertRuleInputTypeEnum>[
      _$alertRuleInputTypeEnum_lowRating,
      _$alertRuleInputTypeEnum_highCancellation,
      _$alertRuleInputTypeEnum_fraudVelocity,
      _$alertRuleInputTypeEnum_kycExpiry,
    ]);

Serializer<AlertRuleInputTypeEnum> _$alertRuleInputTypeEnumSerializer =
    _$AlertRuleInputTypeEnumSerializer();

class _$AlertRuleInputTypeEnumSerializer
    implements PrimitiveSerializer<AlertRuleInputTypeEnum> {
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
  final Iterable<Type> types = const <Type>[AlertRuleInputTypeEnum];
  @override
  final String wireName = 'AlertRuleInputTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AlertRuleInputTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AlertRuleInputTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AlertRuleInputTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AlertRuleInput extends AlertRuleInput {
  @override
  final String name;
  @override
  final AlertRuleInputTypeEnum type;
  @override
  final bool? enabled;
  @override
  final BuiltMap<String, JsonObject?> config;

  factory _$AlertRuleInput([void Function(AlertRuleInputBuilder)? updates]) =>
      (AlertRuleInputBuilder()..update(updates))._build();

  _$AlertRuleInput._({
    required this.name,
    required this.type,
    this.enabled,
    required this.config,
  }) : super._();
  @override
  AlertRuleInput rebuild(void Function(AlertRuleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AlertRuleInputBuilder toBuilder() => AlertRuleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AlertRuleInput &&
        name == other.name &&
        type == other.type &&
        enabled == other.enabled &&
        config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AlertRuleInput')
          ..add('name', name)
          ..add('type', type)
          ..add('enabled', enabled)
          ..add('config', config))
        .toString();
  }
}

class AlertRuleInputBuilder
    implements Builder<AlertRuleInput, AlertRuleInputBuilder> {
  _$AlertRuleInput? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AlertRuleInputTypeEnum? _type;
  AlertRuleInputTypeEnum? get type => _$this._type;
  set type(AlertRuleInputTypeEnum? type) => _$this._type = type;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  MapBuilder<String, JsonObject?>? _config;
  MapBuilder<String, JsonObject?> get config =>
      _$this._config ??= MapBuilder<String, JsonObject?>();
  set config(MapBuilder<String, JsonObject?>? config) =>
      _$this._config = config;

  AlertRuleInputBuilder() {
    AlertRuleInput._defaults(this);
  }

  AlertRuleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _type = $v.type;
      _enabled = $v.enabled;
      _config = $v.config.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AlertRuleInput other) {
    _$v = other as _$AlertRuleInput;
  }

  @override
  void update(void Function(AlertRuleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AlertRuleInput build() => _build();

  _$AlertRuleInput _build() {
    _$AlertRuleInput _$result;
    try {
      _$result =
          _$v ??
          _$AlertRuleInput._(
            name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'AlertRuleInput',
              'name',
            ),
            type: BuiltValueNullFieldError.checkNotNull(
              type,
              r'AlertRuleInput',
              'type',
            ),
            enabled: enabled,
            config: config.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        config.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AlertRuleInput',
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
