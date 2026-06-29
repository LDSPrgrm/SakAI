// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trigger_sos_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TriggerSOSRequest extends TriggerSOSRequest {
  @override
  final String reason;
  @override
  final double? lat;
  @override
  final double? lng;

  factory _$TriggerSOSRequest([
    void Function(TriggerSOSRequestBuilder)? updates,
  ]) => (TriggerSOSRequestBuilder()..update(updates))._build();

  _$TriggerSOSRequest._({required this.reason, this.lat, this.lng}) : super._();
  @override
  TriggerSOSRequest rebuild(void Function(TriggerSOSRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TriggerSOSRequestBuilder toBuilder() =>
      TriggerSOSRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TriggerSOSRequest &&
        reason == other.reason &&
        lat == other.lat &&
        lng == other.lng;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TriggerSOSRequest')
          ..add('reason', reason)
          ..add('lat', lat)
          ..add('lng', lng))
        .toString();
  }
}

class TriggerSOSRequestBuilder
    implements Builder<TriggerSOSRequest, TriggerSOSRequestBuilder> {
  _$TriggerSOSRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  double? _lat;
  double? get lat => _$this._lat;
  set lat(double? lat) => _$this._lat = lat;

  double? _lng;
  double? get lng => _$this._lng;
  set lng(double? lng) => _$this._lng = lng;

  TriggerSOSRequestBuilder() {
    TriggerSOSRequest._defaults(this);
  }

  TriggerSOSRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _lat = $v.lat;
      _lng = $v.lng;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TriggerSOSRequest other) {
    _$v = other as _$TriggerSOSRequest;
  }

  @override
  void update(void Function(TriggerSOSRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TriggerSOSRequest build() => _build();

  _$TriggerSOSRequest _build() {
    final _$result =
        _$v ??
        _$TriggerSOSRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
            reason,
            r'TriggerSOSRequest',
            'reason',
          ),
          lat: lat,
          lng: lng,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
