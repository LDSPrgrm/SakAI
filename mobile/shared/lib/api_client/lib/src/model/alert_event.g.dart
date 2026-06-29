// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AlertEvent extends AlertEvent {
  @override
  final String id;
  @override
  final String? ruleId;
  @override
  final DateTime firedAt;
  @override
  final String? subjectType;
  @override
  final String? subjectId;
  @override
  final BuiltMap<String, JsonObject?> payload;

  factory _$AlertEvent([void Function(AlertEventBuilder)? updates]) =>
      (AlertEventBuilder()..update(updates))._build();

  _$AlertEvent._({
    required this.id,
    this.ruleId,
    required this.firedAt,
    this.subjectType,
    this.subjectId,
    required this.payload,
  }) : super._();
  @override
  AlertEvent rebuild(void Function(AlertEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AlertEventBuilder toBuilder() => AlertEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AlertEvent &&
        id == other.id &&
        ruleId == other.ruleId &&
        firedAt == other.firedAt &&
        subjectType == other.subjectType &&
        subjectId == other.subjectId &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ruleId.hashCode);
    _$hash = $jc(_$hash, firedAt.hashCode);
    _$hash = $jc(_$hash, subjectType.hashCode);
    _$hash = $jc(_$hash, subjectId.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AlertEvent')
          ..add('id', id)
          ..add('ruleId', ruleId)
          ..add('firedAt', firedAt)
          ..add('subjectType', subjectType)
          ..add('subjectId', subjectId)
          ..add('payload', payload))
        .toString();
  }
}

class AlertEventBuilder implements Builder<AlertEvent, AlertEventBuilder> {
  _$AlertEvent? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ruleId;
  String? get ruleId => _$this._ruleId;
  set ruleId(String? ruleId) => _$this._ruleId = ruleId;

  DateTime? _firedAt;
  DateTime? get firedAt => _$this._firedAt;
  set firedAt(DateTime? firedAt) => _$this._firedAt = firedAt;

  String? _subjectType;
  String? get subjectType => _$this._subjectType;
  set subjectType(String? subjectType) => _$this._subjectType = subjectType;

  String? _subjectId;
  String? get subjectId => _$this._subjectId;
  set subjectId(String? subjectId) => _$this._subjectId = subjectId;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  AlertEventBuilder() {
    AlertEvent._defaults(this);
  }

  AlertEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ruleId = $v.ruleId;
      _firedAt = $v.firedAt;
      _subjectType = $v.subjectType;
      _subjectId = $v.subjectId;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AlertEvent other) {
    _$v = other as _$AlertEvent;
  }

  @override
  void update(void Function(AlertEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AlertEvent build() => _build();

  _$AlertEvent _build() {
    _$AlertEvent _$result;
    try {
      _$result =
          _$v ??
          _$AlertEvent._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'AlertEvent', 'id'),
            ruleId: ruleId,
            firedAt: BuiltValueNullFieldError.checkNotNull(
              firedAt,
              r'AlertEvent',
              'firedAt',
            ),
            subjectType: subjectType,
            subjectId: subjectId,
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AlertEvent',
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
