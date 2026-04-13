// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLog extends AuditLog {
  @override
  final String? id;
  @override
  final DateTime? timestamp;
  @override
  final String? actorId;
  @override
  final String? ipAddress;
  @override
  final String? action;
  @override
  final String? resourceType;
  @override
  final String? resourceId;
  @override
  final JsonObject? beforeState;
  @override
  final JsonObject? afterState;
  @override
  final String? reason;

  factory _$AuditLog([void Function(AuditLogBuilder)? updates]) =>
      (AuditLogBuilder()..update(updates))._build();

  _$AuditLog._(
      {this.id,
      this.timestamp,
      this.actorId,
      this.ipAddress,
      this.action,
      this.resourceType,
      this.resourceId,
      this.beforeState,
      this.afterState,
      this.reason})
      : super._();
  @override
  AuditLog rebuild(void Function(AuditLogBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogBuilder toBuilder() => AuditLogBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLog &&
        id == other.id &&
        timestamp == other.timestamp &&
        actorId == other.actorId &&
        ipAddress == other.ipAddress &&
        action == other.action &&
        resourceType == other.resourceType &&
        resourceId == other.resourceId &&
        beforeState == other.beforeState &&
        afterState == other.afterState &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, ipAddress.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, resourceType.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, beforeState.hashCode);
    _$hash = $jc(_$hash, afterState.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLog')
          ..add('id', id)
          ..add('timestamp', timestamp)
          ..add('actorId', actorId)
          ..add('ipAddress', ipAddress)
          ..add('action', action)
          ..add('resourceType', resourceType)
          ..add('resourceId', resourceId)
          ..add('beforeState', beforeState)
          ..add('afterState', afterState)
          ..add('reason', reason))
        .toString();
  }
}

class AuditLogBuilder implements Builder<AuditLog, AuditLogBuilder> {
  _$AuditLog? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  String? _actorId;
  String? get actorId => _$this._actorId;
  set actorId(String? actorId) => _$this._actorId = actorId;

  String? _ipAddress;
  String? get ipAddress => _$this._ipAddress;
  set ipAddress(String? ipAddress) => _$this._ipAddress = ipAddress;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _resourceType;
  String? get resourceType => _$this._resourceType;
  set resourceType(String? resourceType) => _$this._resourceType = resourceType;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  JsonObject? _beforeState;
  JsonObject? get beforeState => _$this._beforeState;
  set beforeState(JsonObject? beforeState) => _$this._beforeState = beforeState;

  JsonObject? _afterState;
  JsonObject? get afterState => _$this._afterState;
  set afterState(JsonObject? afterState) => _$this._afterState = afterState;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  AuditLogBuilder() {
    AuditLog._defaults(this);
  }

  AuditLogBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _timestamp = $v.timestamp;
      _actorId = $v.actorId;
      _ipAddress = $v.ipAddress;
      _action = $v.action;
      _resourceType = $v.resourceType;
      _resourceId = $v.resourceId;
      _beforeState = $v.beforeState;
      _afterState = $v.afterState;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLog other) {
    _$v = other as _$AuditLog;
  }

  @override
  void update(void Function(AuditLogBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLog build() => _build();

  _$AuditLog _build() {
    final _$result = _$v ??
        _$AuditLog._(
          id: id,
          timestamp: timestamp,
          actorId: actorId,
          ipAddress: ipAddress,
          action: action,
          resourceType: resourceType,
          resourceId: resourceId,
          beforeState: beforeState,
          afterState: afterState,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
