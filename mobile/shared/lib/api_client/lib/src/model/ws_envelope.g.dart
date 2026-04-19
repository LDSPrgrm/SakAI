// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_envelope.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEnvelope extends WsEnvelope {
  @override
  final String event;
  @override
  final JsonObject payload;

  factory _$WsEnvelope([void Function(WsEnvelopeBuilder)? updates]) =>
      (WsEnvelopeBuilder()..update(updates))._build();

  _$WsEnvelope._({required this.event, required this.payload}) : super._();
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
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEnvelope')
          ..add('event', event)
          ..add('payload', payload))
        .toString();
  }
}

class WsEnvelopeBuilder implements Builder<WsEnvelope, WsEnvelopeBuilder> {
  _$WsEnvelope? _$v;

  String? _event;
  String? get event => _$this._event;
  set event(String? event) => _$this._event = event;

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  WsEnvelopeBuilder() {
    WsEnvelope._defaults(this);
  }

  WsEnvelopeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _payload = $v.payload;
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
    final _$result =
        _$v ??
        _$WsEnvelope._(
          event: BuiltValueNullFieldError.checkNotNull(
            event,
            r'WsEnvelope',
            'event',
          ),
          payload: BuiltValueNullFieldError.checkNotNull(
            payload,
            r'WsEnvelope',
            'payload',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
