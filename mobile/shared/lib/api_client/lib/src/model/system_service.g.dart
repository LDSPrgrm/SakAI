// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_service.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SystemServiceStatusEnum _$systemServiceStatusEnum_ok =
    const SystemServiceStatusEnum._('ok');
const SystemServiceStatusEnum _$systemServiceStatusEnum_degraded =
    const SystemServiceStatusEnum._('degraded');
const SystemServiceStatusEnum _$systemServiceStatusEnum_down =
    const SystemServiceStatusEnum._('down');

SystemServiceStatusEnum _$systemServiceStatusEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$systemServiceStatusEnum_ok;
    case 'degraded':
      return _$systemServiceStatusEnum_degraded;
    case 'down':
      return _$systemServiceStatusEnum_down;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SystemServiceStatusEnum> _$systemServiceStatusEnumValues =
    BuiltSet<SystemServiceStatusEnum>(const <SystemServiceStatusEnum>[
  _$systemServiceStatusEnum_ok,
  _$systemServiceStatusEnum_degraded,
  _$systemServiceStatusEnum_down,
]);

Serializer<SystemServiceStatusEnum> _$systemServiceStatusEnumSerializer =
    _$SystemServiceStatusEnumSerializer();

class _$SystemServiceStatusEnumSerializer
    implements PrimitiveSerializer<SystemServiceStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'degraded': 'degraded',
    'down': 'down',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'degraded': 'degraded',
    'down': 'down',
  };

  @override
  final Iterable<Type> types = const <Type>[SystemServiceStatusEnum];
  @override
  final String wireName = 'SystemServiceStatusEnum';

  @override
  Object serialize(Serializers serializers, SystemServiceStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SystemServiceStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SystemServiceStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SystemService extends SystemService {
  @override
  final String? name;
  @override
  final SystemServiceStatusEnum? status;
  @override
  final int? latencyMs;
  @override
  final num? uptimePct;
  @override
  final DateTime? lastChecked;

  factory _$SystemService([void Function(SystemServiceBuilder)? updates]) =>
      (SystemServiceBuilder()..update(updates))._build();

  _$SystemService._(
      {this.name,
      this.status,
      this.latencyMs,
      this.uptimePct,
      this.lastChecked})
      : super._();
  @override
  SystemService rebuild(void Function(SystemServiceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SystemServiceBuilder toBuilder() => SystemServiceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SystemService &&
        name == other.name &&
        status == other.status &&
        latencyMs == other.latencyMs &&
        uptimePct == other.uptimePct &&
        lastChecked == other.lastChecked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, latencyMs.hashCode);
    _$hash = $jc(_$hash, uptimePct.hashCode);
    _$hash = $jc(_$hash, lastChecked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SystemService')
          ..add('name', name)
          ..add('status', status)
          ..add('latencyMs', latencyMs)
          ..add('uptimePct', uptimePct)
          ..add('lastChecked', lastChecked))
        .toString();
  }
}

class SystemServiceBuilder
    implements Builder<SystemService, SystemServiceBuilder> {
  _$SystemService? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  SystemServiceStatusEnum? _status;
  SystemServiceStatusEnum? get status => _$this._status;
  set status(SystemServiceStatusEnum? status) => _$this._status = status;

  int? _latencyMs;
  int? get latencyMs => _$this._latencyMs;
  set latencyMs(int? latencyMs) => _$this._latencyMs = latencyMs;

  num? _uptimePct;
  num? get uptimePct => _$this._uptimePct;
  set uptimePct(num? uptimePct) => _$this._uptimePct = uptimePct;

  DateTime? _lastChecked;
  DateTime? get lastChecked => _$this._lastChecked;
  set lastChecked(DateTime? lastChecked) => _$this._lastChecked = lastChecked;

  SystemServiceBuilder() {
    SystemService._defaults(this);
  }

  SystemServiceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _status = $v.status;
      _latencyMs = $v.latencyMs;
      _uptimePct = $v.uptimePct;
      _lastChecked = $v.lastChecked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SystemService other) {
    _$v = other as _$SystemService;
  }

  @override
  void update(void Function(SystemServiceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SystemService build() => _build();

  _$SystemService _build() {
    final _$result = _$v ??
        _$SystemService._(
          name: name,
          status: status,
          latencyMs: latencyMs,
          uptimePct: uptimePct,
          lastChecked: lastChecked,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
