// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_offer_expired.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideOfferExpired extends WsEventRideOfferExpired {
  @override
  final String rideId;

  factory _$WsEventRideOfferExpired(
          [void Function(WsEventRideOfferExpiredBuilder)? updates]) =>
      (WsEventRideOfferExpiredBuilder()..update(updates))._build();

  _$WsEventRideOfferExpired._({required this.rideId}) : super._();
  @override
  WsEventRideOfferExpired rebuild(
          void Function(WsEventRideOfferExpiredBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WsEventRideOfferExpiredBuilder toBuilder() =>
      WsEventRideOfferExpiredBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideOfferExpired && rideId == other.rideId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideOfferExpired')
          ..add('rideId', rideId))
        .toString();
  }
}

class WsEventRideOfferExpiredBuilder
    implements
        Builder<WsEventRideOfferExpired, WsEventRideOfferExpiredBuilder> {
  _$WsEventRideOfferExpired? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  WsEventRideOfferExpiredBuilder() {
    WsEventRideOfferExpired._defaults(this);
  }

  WsEventRideOfferExpiredBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideOfferExpired other) {
    _$v = other as _$WsEventRideOfferExpired;
  }

  @override
  void update(void Function(WsEventRideOfferExpiredBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideOfferExpired build() => _build();

  _$WsEventRideOfferExpired _build() {
    final _$result = _$v ??
        _$WsEventRideOfferExpired._(
          rideId: BuiltValueNullFieldError.checkNotNull(
              rideId, r'WsEventRideOfferExpired', 'rideId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
