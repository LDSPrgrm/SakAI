// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLog extends AuditLog {
  @override
  final String? id;
  @override
  final int? seq;
  @override
  final String? displayId;
  @override
  final DateTime? timestamp;
  @override
  final String? actorId;
  @override
  final String? actorDisplayId;
  @override
  final String? actorName;
  @override
  final String? ipAddress;
  @override
  final String? action;
  @override
  final String? resourceType;
  @override
  final String? resourceId;
  @override
  final BuiltMap<String, JsonObject?>? beforeState;
  @override
  final BuiltMap<String, JsonObject?>? afterState;
  @override
  final String? reason;

  factory _$AuditLog([void Function(AuditLogBuilder)? updates]) =>
      (AuditLogBuilder()..update(updates))._build();

  _$AuditLog._({
    this.id,
    this.seq,
    this.displayId,
    this.timestamp,
    this.actorId,
    this.actorDisplayId,
    this.actorName,
    this.ipAddress,
    this.action,
    this.resourceType,
    this.resourceId,
    this.beforeState,
    this.afterState,
    this.reason,
  }) : super._();
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
        seq == other.seq &&
        displayId == other.displayId &&
        timestamp == other.timestamp &&
        actorId == other.actorId &&
        actorDisplayId == other.actorDisplayId &&
        actorName == other.actorName &&
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
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, displayId.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, actorDisplayId.hashCode);
    _$hash = $jc(_$hash, actorName.hashCode);
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
          ..add('seq', seq)
          ..add('displayId', displayId)
          ..add('timestamp', timestamp)
          ..add('actorId', actorId)
          ..add('actorDisplayId', actorDisplayId)
          ..add('actorName', actorName)
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

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  String? _displayId;
  String? get displayId => _$this._displayId;
  set displayId(String? displayId) => _$this._displayId = displayId;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  String? _actorId;
  String? get actorId => _$this._actorId;
  set actorId(String? actorId) => _$this._actorId = actorId;

  String? _actorDisplayId;
  String? get actorDisplayId => _$this._actorDisplayId;
  set actorDisplayId(String? actorDisplayId) =>
      _$this._actorDisplayId = actorDisplayId;

  String? _actorName;
  String? get actorName => _$this._actorName;
  set actorName(String? actorName) => _$this._actorName = actorName;

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

  MapBuilder<String, JsonObject?>? _beforeState;
  MapBuilder<String, JsonObject?> get beforeState =>
      _$this._beforeState ??= MapBuilder<String, JsonObject?>();
  set beforeState(MapBuilder<String, JsonObject?>? beforeState) =>
      _$this._beforeState = beforeState;

  MapBuilder<String, JsonObject?>? _afterState;
  MapBuilder<String, JsonObject?> get afterState =>
      _$this._afterState ??= MapBuilder<String, JsonObject?>();
  set afterState(MapBuilder<String, JsonObject?>? afterState) =>
      _$this._afterState = afterState;

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
      _seq = $v.seq;
      _displayId = $v.displayId;
      _timestamp = $v.timestamp;
      _actorId = $v.actorId;
      _actorDisplayId = $v.actorDisplayId;
      _actorName = $v.actorName;
      _ipAddress = $v.ipAddress;
      _action = $v.action;
      _resourceType = $v.resourceType;
      _resourceId = $v.resourceId;
      _beforeState = $v.beforeState?.toBuilder();
      _afterState = $v.afterState?.toBuilder();
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
    _$AuditLog _$result;
    try {
      _$result =
          _$v ??
          _$AuditLog._(
            id: id,
            seq: seq,
            displayId: displayId,
            timestamp: timestamp,
            actorId: actorId,
            actorDisplayId: actorDisplayId,
            actorName: actorName,
            ipAddress: ipAddress,
            action: action,
            resourceType: resourceType,
            resourceId: resourceId,
            beforeState: _beforeState?.build(),
            afterState: _afterState?.build(),
            reason: reason,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'beforeState';
        _beforeState?.build();
        _$failedField = 'afterState';
        _afterState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AuditLog',
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
