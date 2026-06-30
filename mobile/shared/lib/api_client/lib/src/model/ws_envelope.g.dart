// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEnvelope extends WsEnvelope {
  @override
  final WsEventType event;
  @override
  final WsEnvelopePayload payload;
  @override
  final DateTime? timestamp;
  @override
  final String? eventId;
  @override
  final int? v;
  @override
  final int? seq;
  @override
  final String? corrId;
  @override
  final bool? ackRequired;

  factory _$WsEnvelope([void Function(WsEnvelopeBuilder)? updates]) =>
      (WsEnvelopeBuilder()..update(updates))._build();

  _$WsEnvelope._({
    required this.event,
    required this.payload,
    this.timestamp,
    this.eventId,
    this.v,
    this.seq,
    this.corrId,
    this.ackRequired,
  }) : super._();
  @override
  WsEnvelope rebuild(void Function(WsEnvelopeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEnvelopeBuilder toBuilder() => WsEnvelopeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEnvelope &&
        event == other.event &&
        payload == other.payload &&
        timestamp == other.timestamp &&
        eventId == other.eventId &&
        v == other.v &&
        seq == other.seq &&
        corrId == other.corrId &&
        ackRequired == other.ackRequired;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, timestamp.hashCode);
    _$hash = $jc(_$hash, eventId.hashCode);
    _$hash = $jc(_$hash, v.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, corrId.hashCode);
    _$hash = $jc(_$hash, ackRequired.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEnvelope')
          ..add('event', event)
          ..add('payload', payload)
          ..add('timestamp', timestamp)
          ..add('eventId', eventId)
          ..add('v', v)
          ..add('seq', seq)
          ..add('corrId', corrId)
          ..add('ackRequired', ackRequired))
        .toString();
  }
}

class WsEnvelopeBuilder implements Builder<WsEnvelope, WsEnvelopeBuilder> {
  _$WsEnvelope? _$v;

  WsEventType? _event;
  WsEventType? get event => _$this._event;
  set event(WsEventType? event) => _$this._event = event;

  WsEnvelopePayloadBuilder? _payload;
  WsEnvelopePayloadBuilder get payload =>
      _$this._payload ??= WsEnvelopePayloadBuilder();
  set payload(WsEnvelopePayloadBuilder? payload) => _$this._payload = payload;

  DateTime? _timestamp;
  DateTime? get timestamp => _$this._timestamp;
  set timestamp(DateTime? timestamp) => _$this._timestamp = timestamp;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  int? _v;
  int? get v => _$this._v;
  set v(int? v) => _$this._v = v;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(int? seq) => _$this._seq = seq;

  String? _corrId;
  String? get corrId => _$this._corrId;
  set corrId(String? corrId) => _$this._corrId = corrId;

  bool? _ackRequired;
  bool? get ackRequired => _$this._ackRequired;
  set ackRequired(bool? ackRequired) => _$this._ackRequired = ackRequired;

  WsEnvelopeBuilder() {
    WsEnvelope._defaults(this);
  }

  WsEnvelopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _payload = $v.payload.toBuilder();
      _timestamp = $v.timestamp;
      _eventId = $v.eventId;
      _v = $v.v;
      _seq = $v.seq;
      _corrId = $v.corrId;
      _ackRequired = $v.ackRequired;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEnvelope other) {
    _$v = other as _$WsEnvelope;
  }

  @override
  void update(void Function(WsEnvelopeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEnvelope build() => _build();

  _$WsEnvelope _build() {
    _$WsEnvelope _$result;
    try {
      _$result =
          _$v ??
          _$WsEnvelope._(
            event: BuiltValueNullFieldError.checkNotNull(
              event,
              r'WsEnvelope',
              'event',
            ),
            payload: payload.build(),
            timestamp: timestamp,
            eventId: eventId,
            v: v,
            seq: seq,
            corrId: corrId,
            ackRequired: ackRequired,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'WsEnvelope',
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
