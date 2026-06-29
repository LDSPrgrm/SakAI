// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_gateway_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentGatewayConfigProviderEnum
_$paymentGatewayConfigProviderEnum_gcash =
    const PaymentGatewayConfigProviderEnum._('gcash');
const PaymentGatewayConfigProviderEnum
_$paymentGatewayConfigProviderEnum_paymaya =
    const PaymentGatewayConfigProviderEnum._('paymaya');
const PaymentGatewayConfigProviderEnum _$paymentGatewayConfigProviderEnum_card =
    const PaymentGatewayConfigProviderEnum._('card');
const PaymentGatewayConfigProviderEnum _$paymentGatewayConfigProviderEnum_cash =
    const PaymentGatewayConfigProviderEnum._('cash');

PaymentGatewayConfigProviderEnum _$paymentGatewayConfigProviderEnumValueOf(
  String name,
) {
  switch (name) {
    case 'gcash':
      return _$paymentGatewayConfigProviderEnum_gcash;
    case 'paymaya':
      return _$paymentGatewayConfigProviderEnum_paymaya;
    case 'card':
      return _$paymentGatewayConfigProviderEnum_card;
    case 'cash':
      return _$paymentGatewayConfigProviderEnum_cash;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentGatewayConfigProviderEnum>
_$paymentGatewayConfigProviderEnumValues =
    BuiltSet<PaymentGatewayConfigProviderEnum>(
      const <PaymentGatewayConfigProviderEnum>[
        _$paymentGatewayConfigProviderEnum_gcash,
        _$paymentGatewayConfigProviderEnum_paymaya,
        _$paymentGatewayConfigProviderEnum_card,
        _$paymentGatewayConfigProviderEnum_cash,
      ],
    );

Serializer<PaymentGatewayConfigProviderEnum>
_$paymentGatewayConfigProviderEnumSerializer =
    _$PaymentGatewayConfigProviderEnumSerializer();

class _$PaymentGatewayConfigProviderEnumSerializer
    implements PrimitiveSerializer<PaymentGatewayConfigProviderEnum> {
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
  final Iterable<Type> types = const <Type>[PaymentGatewayConfigProviderEnum];
  @override
  final String wireName = 'PaymentGatewayConfigProviderEnum';

  @override
  Object serialize(
    Serializers serializers,
    PaymentGatewayConfigProviderEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  PaymentGatewayConfigProviderEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => PaymentGatewayConfigProviderEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$PaymentGatewayConfig extends PaymentGatewayConfig {
  @override
  final String? id;
  @override
  final PaymentGatewayConfigProviderEnum? provider;
  @override
  final BuiltMap<String, String>? configFields;
  @override
  final bool? isActive;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;

  factory _$PaymentGatewayConfig([
    void Function(PaymentGatewayConfigBuilder)? updates,
  ]) => (PaymentGatewayConfigBuilder()..update(updates))._build();

  _$PaymentGatewayConfig._({
    this.id,
    this.provider,
    this.configFields,
    this.isActive,
    this.updatedAt,
    this.updatedBy,
  }) : super._();
  @override
  PaymentGatewayConfig rebuild(
    void Function(PaymentGatewayConfigBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  PaymentGatewayConfigBuilder toBuilder() =>
      PaymentGatewayConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentGatewayConfig &&
        id == other.id &&
        provider == other.provider &&
        configFields == other.configFields &&
        isActive == other.isActive &&
        updatedAt == other.updatedAt &&
        updatedBy == other.updatedBy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, configFields.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentGatewayConfig')
          ..add('id', id)
          ..add('provider', provider)
          ..add('configFields', configFields)
          ..add('isActive', isActive)
          ..add('updatedAt', updatedAt)
          ..add('updatedBy', updatedBy))
        .toString();
  }
}

class PaymentGatewayConfigBuilder
    implements Builder<PaymentGatewayConfig, PaymentGatewayConfigBuilder> {
  _$PaymentGatewayConfig? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PaymentGatewayConfigProviderEnum? _provider;
  PaymentGatewayConfigProviderEnum? get provider => _$this._provider;
  set provider(PaymentGatewayConfigProviderEnum? provider) =>
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

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  PaymentGatewayConfigBuilder() {
    PaymentGatewayConfig._defaults(this);
  }

  PaymentGatewayConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _provider = $v.provider;
      _configFields = $v.configFields?.toBuilder();
      _isActive = $v.isActive;
      _updatedAt = $v.updatedAt;
      _updatedBy = $v.updatedBy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentGatewayConfig other) {
    _$v = other as _$PaymentGatewayConfig;
  }

  @override
  void update(void Function(PaymentGatewayConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentGatewayConfig build() => _build();

  _$PaymentGatewayConfig _build() {
    _$PaymentGatewayConfig _$result;
    try {
      _$result =
          _$v ??
          _$PaymentGatewayConfig._(
            id: id,
            provider: provider,
            configFields: _configFields?.build(),
            isActive: isActive,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configFields';
        _configFields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'PaymentGatewayConfig',
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
