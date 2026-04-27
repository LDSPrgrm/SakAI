// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_status_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentStatusEvent extends IncidentStatusEvent {
  @override
  final String id;
  @override
  final String? fromStatus;
  @override
  final String toStatus;
  @override
  final String? fromAssignee;
  @override
  final String? toAssignee;
  @override
  final String? actorId;
  @override
  final String? actorName;
  @override
  final String? note;
  @override
  final DateTime occurredAt;

  factory _$IncidentStatusEvent([
    void Function(IncidentStatusEventBuilder)? updates,
  ]) => (IncidentStatusEventBuilder()..update(updates))._build();

  _$IncidentStatusEvent._({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.fromAssignee,
    this.toAssignee,
    this.actorId,
    this.actorName,
    this.note,
    required this.occurredAt,
  }) : super._();
  @override
  IncidentStatusEvent rebuild(
    void Function(IncidentStatusEventBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  IncidentStatusEventBuilder toBuilder() =>
      IncidentStatusEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentStatusEvent &&
        id == other.id &&
        fromStatus == other.fromStatus &&
        toStatus == other.toStatus &&
        fromAssignee == other.fromAssignee &&
        toAssignee == other.toAssignee &&
        actorId == other.actorId &&
        actorName == other.actorName &&
        note == other.note &&
        occurredAt == other.occurredAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fromStatus.hashCode);
    _$hash = $jc(_$hash, toStatus.hashCode);
    _$hash = $jc(_$hash, fromAssignee.hashCode);
    _$hash = $jc(_$hash, toAssignee.hashCode);
    _$hash = $jc(_$hash, actorId.hashCode);
    _$hash = $jc(_$hash, actorName.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, occurredAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IncidentStatusEvent')
          ..add('id', id)
          ..add('fromStatus', fromStatus)
          ..add('toStatus', toStatus)
          ..add('fromAssignee', fromAssignee)
          ..add('toAssignee', toAssignee)
          ..add('actorId', actorId)
          ..add('actorName', actorName)
          ..add('note', note)
          ..add('occurredAt', occurredAt))
        .toString();
  }
}

class IncidentStatusEventBuilder
    implements Builder<IncidentStatusEvent, IncidentStatusEventBuilder> {
  _$IncidentStatusEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fromStatus;
  String? get fromStatus => _$this._fromStatus;
  set fromStatus(String? fromStatus) => _$this._fromStatus = fromStatus;

  String? _toStatus;
  String? get toStatus => _$this._toStatus;
  set toStatus(String? toStatus) => _$this._toStatus = toStatus;

  String? _fromAssignee;
  String? get fromAssignee => _$this._fromAssignee;
  set fromAssignee(String? fromAssignee) => _$this._fromAssignee = fromAssignee;

  String? _toAssignee;
  String? get toAssignee => _$this._toAssignee;
  set toAssignee(String? toAssignee) => _$this._toAssignee = toAssignee;

  String? _actorId;
  String? get actorId => _$this._actorId;
  set actorId(String? actorId) => _$this._actorId = actorId;

  String? _actorName;
  String? get actorName => _$this._actorName;
  set actorName(String? actorName) => _$this._actorName = actorName;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  DateTime? _occurredAt;
  DateTime? get occurredAt => _$this._occurredAt;
  set occurredAt(DateTime? occurredAt) => _$this._occurredAt = occurredAt;

  IncidentStatusEventBuilder() {
    IncidentStatusEvent._defaults(this);
  }

  IncidentStatusEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _fromStatus = $v.fromStatus;
      _toStatus = $v.toStatus;
      _fromAssignee = $v.fromAssignee;
      _toAssignee = $v.toAssignee;
      _actorId = $v.actorId;
      _actorName = $v.actorName;
      _note = $v.note;
      _occurredAt = $v.occurredAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentStatusEvent other) {
    _$v = other as _$IncidentStatusEvent;
  }

  @override
  void update(void Function(IncidentStatusEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentStatusEvent build() => _build();

  _$IncidentStatusEvent _build() {
    final _$result =
        _$v ??
        _$IncidentStatusEvent._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'IncidentStatusEvent',
            'id',
          ),
          fromStatus: fromStatus,
          toStatus: BuiltValueNullFieldError.checkNotNull(
            toStatus,
            r'IncidentStatusEvent',
            'toStatus',
          ),
          fromAssignee: fromAssignee,
          toAssignee: toAssignee,
          actorId: actorId,
          actorName: actorName,
          note: note,
          occurredAt: BuiltValueNullFieldError.checkNotNull(
            occurredAt,
            r'IncidentStatusEvent',
            'occurredAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
