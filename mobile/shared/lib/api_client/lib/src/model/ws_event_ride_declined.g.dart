// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_declined.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideDeclined extends WsEventRideDeclined {
  @override
  final String rideId;
  @override
  final String? message;

  factory _$WsEventRideDeclined([
    void Function(WsEventRideDeclinedBuilder)? updates,
  ]) => (WsEventRideDeclinedBuilder()..update(updates))._build();

  _$WsEventRideDeclined._({required this.rideId, this.message}) : super._();
  @override
  WsEventRideDeclined rebuild(
    void Function(WsEventRideDeclinedBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideDeclinedBuilder toBuilder() =>
      WsEventRideDeclinedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideDeclined &&
        rideId == other.rideId &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideDeclined')
          ..add('rideId', rideId)
          ..add('message', message))
        .toString();
  }
}

class WsEventRideDeclinedBuilder
    implements Builder<WsEventRideDeclined, WsEventRideDeclinedBuilder> {
  _$WsEventRideDeclined? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  WsEventRideDeclinedBuilder() {
    WsEventRideDeclined._defaults(this);
  }

  WsEventRideDeclinedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideDeclined other) {
    _$v = other as _$WsEventRideDeclined;
  }

  @override
  void update(void Function(WsEventRideDeclinedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideDeclined build() => _build();

  _$WsEventRideDeclined _build() {
    final _$result =
        _$v ??
        _$WsEventRideDeclined._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventRideDeclined',
            'rideId',
          ),
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
