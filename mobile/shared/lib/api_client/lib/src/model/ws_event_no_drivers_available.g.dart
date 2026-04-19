// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_no_drivers_available.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventNoDriversAvailable extends WsEventNoDriversAvailable {
  @override
  final String rideId;
  @override
  final String? message;

  factory _$WsEventNoDriversAvailable([
    void Function(WsEventNoDriversAvailableBuilder)? updates,
  ]) => (WsEventNoDriversAvailableBuilder()..update(updates))._build();

  _$WsEventNoDriversAvailable._({required this.rideId, this.message})
    : super._();
  @override
  WsEventNoDriversAvailable rebuild(
    void Function(WsEventNoDriversAvailableBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventNoDriversAvailableBuilder toBuilder() =>
      WsEventNoDriversAvailableBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventNoDriversAvailable &&
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
    return (newBuiltValueToStringHelper(r'WsEventNoDriversAvailable')
          ..add('rideId', rideId)
          ..add('message', message))
        .toString();
  }
}

class WsEventNoDriversAvailableBuilder
    implements
        Builder<WsEventNoDriversAvailable, WsEventNoDriversAvailableBuilder> {
  _$WsEventNoDriversAvailable? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  WsEventNoDriversAvailableBuilder() {
    WsEventNoDriversAvailable._defaults(this);
  }

  WsEventNoDriversAvailableBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventNoDriversAvailable other) {
    _$v = other as _$WsEventNoDriversAvailable;
  }

  @override
  void update(void Function(WsEventNoDriversAvailableBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventNoDriversAvailable build() => _build();

  _$WsEventNoDriversAvailable _build() {
    final _$result =
        _$v ??
        _$WsEventNoDriversAvailable._(
          rideId: BuiltValueNullFieldError.checkNotNull(
            rideId,
            r'WsEventNoDriversAvailable',
            'rideId',
          ),
          message: message,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
