// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_incident_assigned.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventIncidentAssigned extends WsEventIncidentAssigned {
  @override
  final String rideId;
  @override
  final String incidentId;
  @override
  final String? assigneeId;
  @override
  final String? assigneeName;
  @override
  final DateTime assignedAt;

  factory _$WsEventIncidentAssigned([
    void Function(WsEventIncidentAssignedBuilder)? updates,
  ]) => (WsEventIncidentAssignedBuilder()..update(updates))._build();

  _$WsEventIncidentAssigned._({
    required this.rideId,
    required this.incidentId,
    this.assigneeId,
    this.assigneeName,
    required this.assignedAt,
  }) : super._();
  @override
  WsEventIncidentAssigned rebuild(
    void Function(WsEventIncidentAssignedBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventIncidentAssignedBuilder toBuilder() =>
      WsEventIncidentAssignedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventIncidentAssigned &&
        rideId == other.rideId &&
        incidentId == other.incidentId &&
        assigneeId == other.assigneeId &&
        assigneeName == other.assigneeName &&
        assignedAt == other.assignedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, incidentId.hashCode);
    _$hash = $jc(_$hash, assigneeId.hashCode);
    _$hash = $jc(_$hash, assigneeName.hashCode);
    _$hash = $jc(_$hash, assignedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventIncidentAssigned')
          ..add('rideId', rideId)
          ..add('incidentId', incidentId)
          ..add('assigneeId', assigneeId)
          ..add('assigneeName', assigneeName)
          ..add('assignedAt', assignedAt))
        .toString();
  }
}

class WsEventIncidentAssignedBuilder
    implements
        Builder<WsEventIncidentAssigned, WsEventIncidentAssignedBuilder> {
  _$WsEventIncidentAssigned? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _incidentId;
  String? get incidentId => _$this._incidentId;
  set incidentId(String? incidentId) => _$this._incidentId = incidentId;

  String? _assigneeId;
  String? get assigneeId => _$this._assigneeId;
  set assigneeId(String? assigneeId) => _$this._assigneeId = assigneeId;

  String? _assigneeName;
  String? get assigneeName => _$this._assigneeName;
  set assigneeName(String? assigneeName) => _$this._assigneeName = assigneeName;

  DateTime? _assignedAt;
  DateTime? get assignedAt => _$this._assignedAt;
  set assignedAt(DateTime? assignedAt) => _$this._assignedAt = assignedAt;

  WsEventIncidentAssignedBuilder() {
    WsEventIncidentAssigned._defaults(this);
  }

  WsEventIncidentAssignedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _incidentId = $v.incidentId;
      _assigneeId = $v.assigneeId;
      _assigneeName = $v.assigneeName;
      _assignedAt = $v.assignedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventIncidentAssigned other) {
    _$v = other as _$WsEventIncidentAssigned;
  }

  @override
  void update(void Function(WsEventIncidentAssignedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventIncidentAssigned build() => _build();

  _$WsEventIncidentAssigned _build() {
    final _$result =
        _$v ??
        _$WsEventIncidentAssigned._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventIncidentAssigned',
            'rideId',
          ),
          incidentId: BuiltValueNullFieldError.checkNotNull(
            incidentId,
            r'WsEventIncidentAssigned',
            'incidentId',
          ),
          assigneeId: assigneeId,
          assigneeName: assigneeName,
          assignedAt: BuiltValueNullFieldError.checkNotNull(
            assignedAt,
            r'WsEventIncidentAssigned',
            'assignedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
