// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CancelRequest extends CancelRequest {
  @override
  final String? reason;

  factory _$CancelRequest([void Function(CancelRequestBuilder)? updates]) =>
      (CancelRequestBuilder()..update(updates))._build();

  _$CancelRequest._({this.reason}) : super._();
  @override
  CancelRequest rebuild(void Function(CancelRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CancelRequestBuilder toBuilder() => CancelRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CancelRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'CancelRequest',
    )..add('reason', reason)).toString();
  }
}

class CancelRequestBuilder
    implements Builder<CancelRequest, CancelRequestBuilder> {
  _$CancelRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  CancelRequestBuilder() {
    CancelRequest._defaults(this);
  }

  CancelRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CancelRequest other) {
    _$v = other as _$CancelRequest;
  }

  @override
  void update(void Function(CancelRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CancelRequest build() => _build();

  _$CancelRequest _build() {
    final _$result = _$v ?? _$CancelRequest._(reason: reason);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
