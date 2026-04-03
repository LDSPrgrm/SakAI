// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IntegrationStatusEnum _$integrationStatusEnum_active =
    const IntegrationStatusEnum._('active');
const IntegrationStatusEnum _$integrationStatusEnum_degraded =
    const IntegrationStatusEnum._('degraded');
const IntegrationStatusEnum _$integrationStatusEnum_offline =
    const IntegrationStatusEnum._('offline');

IntegrationStatusEnum _$integrationStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$integrationStatusEnum_active;
    case 'degraded':
      return _$integrationStatusEnum_degraded;
    case 'offline':
      return _$integrationStatusEnum_offline;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IntegrationStatusEnum> _$integrationStatusEnumValues =
    BuiltSet<IntegrationStatusEnum>(const <IntegrationStatusEnum>[
      _$integrationStatusEnum_active,
      _$integrationStatusEnum_degraded,
      _$integrationStatusEnum_offline,
    ]);

Serializer<IntegrationStatusEnum> _$integrationStatusEnumSerializer =
    _$IntegrationStatusEnumSerializer();

class _$IntegrationStatusEnumSerializer
    implements PrimitiveSerializer<IntegrationStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'degraded': 'degraded',
    'offline': 'offline',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'degraded': 'degraded',
    'offline': 'offline',
  };

  @override
  final Iterable<Type> types = const <Type>[IntegrationStatusEnum];
  @override
  final String wireName = 'IntegrationStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    IntegrationStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  IntegrationStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => IntegrationStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$Integration extends Integration {
  @override
  final String? service;
  @override
  final IntegrationStatusEnum? status;
  @override
  final DateTime? lastSync;
  @override
  final BuiltMap<String, String>? config;

  factory _$Integration([void Function(IntegrationBuilder)? updates]) =>
      (IntegrationBuilder()..update(updates))._build();

  _$Integration._({this.service, this.status, this.lastSync, this.config})
    : super._();
  @override
  Integration rebuild(void Function(IntegrationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IntegrationBuilder toBuilder() => IntegrationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Integration &&
        service == other.service &&
        status == other.status &&
        lastSync == other.lastSync &&
        config == other.config;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, service.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, lastSync.hashCode);
    _$hash = $jc(_$hash, config.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Integration')
          ..add('service', service)
          ..add('status', status)
          ..add('lastSync', lastSync)
          ..add('config', config))
        .toString();
  }
}

class IntegrationBuilder implements Builder<Integration, IntegrationBuilder> {
  _$Integration? _$v;

  String? _service;
  String? get service => _$this._service;
  set service(String? service) => _$this._service = service;

  IntegrationStatusEnum? _status;
  IntegrationStatusEnum? get status => _$this._status;
  set status(IntegrationStatusEnum? status) => _$this._status = status;

  DateTime? _lastSync;
  DateTime? get lastSync => _$this._lastSync;
  set lastSync(DateTime? lastSync) => _$this._lastSync = lastSync;

  MapBuilder<String, String>? _config;
  MapBuilder<String, String> get config =>
      _$this._config ??= MapBuilder<String, String>();
  set config(MapBuilder<String, String>? config) => _$this._config = config;

  IntegrationBuilder() {
    Integration._defaults(this);
  }

  IntegrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _service = $v.service;
      _status = $v.status;
      _lastSync = $v.lastSync;
      _config = $v.config?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Integration other) {
    _$v = other as _$Integration;
  }

  @override
  void update(void Function(IntegrationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Integration build() => _build();

  _$Integration _build() {
    _$Integration _$result;
    try {
      _$result =
          _$v ??
          _$Integration._(
            service: service,
            status: status,
            lastSync: lastSync,
            config: _config?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'config';
        _config?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'Integration',
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
