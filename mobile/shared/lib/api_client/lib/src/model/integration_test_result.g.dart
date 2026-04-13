// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration_test_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IntegrationTestResultStatusEnum _$integrationTestResultStatusEnum_ok =
    const IntegrationTestResultStatusEnum._('ok');
const IntegrationTestResultStatusEnum _$integrationTestResultStatusEnum_failed =
    const IntegrationTestResultStatusEnum._('failed');

IntegrationTestResultStatusEnum _$integrationTestResultStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'ok':
      return _$integrationTestResultStatusEnum_ok;
    case 'failed':
      return _$integrationTestResultStatusEnum_failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IntegrationTestResultStatusEnum>
_$integrationTestResultStatusEnumValues =
    BuiltSet<IntegrationTestResultStatusEnum>(
      const <IntegrationTestResultStatusEnum>[
        _$integrationTestResultStatusEnum_ok,
        _$integrationTestResultStatusEnum_failed,
      ],
    );

Serializer<IntegrationTestResultStatusEnum>
_$integrationTestResultStatusEnumSerializer =
    _$IntegrationTestResultStatusEnumSerializer();

class _$IntegrationTestResultStatusEnumSerializer
    implements PrimitiveSerializer<IntegrationTestResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[IntegrationTestResultStatusEnum];
  @override
  final String wireName = 'IntegrationTestResultStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    IntegrationTestResultStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  IntegrationTestResultStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => IntegrationTestResultStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$IntegrationTestResult extends IntegrationTestResult {
  @override
  final String? service;
  @override
  final IntegrationTestResultStatusEnum? status;
  @override
  final int? latencyMs;
  @override
  final String? message;

  factory _$IntegrationTestResult([
    void Function(IntegrationTestResultBuilder)? updates,
  ]) => (IntegrationTestResultBuilder()..update(updates))._build();

  _$IntegrationTestResult._({
    this.service,
    this.status,
    this.latencyMs,
    this.message,
  }) : super._();
  @override
  IntegrationTestResult rebuild(
    void Function(IntegrationTestResultBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  IntegrationTestResultBuilder toBuilder() =>
      IntegrationTestResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IntegrationTestResult &&
        service == other.service &&
        status == other.status &&
        latencyMs == other.latencyMs &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, service.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, latencyMs.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IntegrationTestResult')
          ..add('service', service)
          ..add('status', status)
          ..add('latencyMs', latencyMs)
          ..add('message', message))
        .toString();
  }
}

class IntegrationTestResultBuilder
    implements Builder<IntegrationTestResult, IntegrationTestResultBuilder> {
  _$IntegrationTestResult? _$v;

  String? _service;
  String? get service => _$this._service;
  set service(String? service) => _$this._service = service;

  IntegrationTestResultStatusEnum? _status;
  IntegrationTestResultStatusEnum? get status => _$this._status;
  set status(IntegrationTestResultStatusEnum? status) =>
      _$this._status = status;

  int? _latencyMs;
  int? get latencyMs => _$this._latencyMs;
  set latencyMs(int? latencyMs) => _$this._latencyMs = latencyMs;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  IntegrationTestResultBuilder() {
    IntegrationTestResult._defaults(this);
  }

  IntegrationTestResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _service = $v.service;
      _status = $v.status;
      _latencyMs = $v.latencyMs;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IntegrationTestResult other) {
    _$v = other as _$IntegrationTestResult;
  }

  @override
  void update(void Function(IntegrationTestResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IntegrationTestResult build() => _build();

  _$IntegrationTestResult _build() {
    final _$result =
        _$v ??
        _$IntegrationTestResult._(
          service: service,
          status: status,
          latencyMs: latencyMs,
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
