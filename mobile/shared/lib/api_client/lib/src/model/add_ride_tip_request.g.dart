// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_ride_tip_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AddRideTipRequest extends AddRideTipRequest {
  @override
  final double tipAmount;

  factory _$AddRideTipRequest(
          [void Function(AddRideTipRequestBuilder)? updates]) =>
      (AddRideTipRequestBuilder()..update(updates))._build();

  _$AddRideTipRequest._({required this.tipAmount}) : super._();
  @override
  AddRideTipRequest rebuild(void Function(AddRideTipRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddRideTipRequestBuilder toBuilder() =>
      AddRideTipRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AddRideTipRequest && tipAmount == other.tipAmount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tipAmount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AddRideTipRequest')
          ..add('tipAmount', tipAmount))
        .toString();
  }
}

class AddRideTipRequestBuilder
    implements Builder<AddRideTipRequest, AddRideTipRequestBuilder> {
  _$AddRideTipRequest? _$v;

  double? _tipAmount;
  double? get tipAmount => _$this._tipAmount;
  set tipAmount(double? tipAmount) => _$this._tipAmount = tipAmount;

  AddRideTipRequestBuilder() {
    AddRideTipRequest._defaults(this);
  }

  AddRideTipRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tipAmount = $v.tipAmount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AddRideTipRequest other) {
    _$v = other as _$AddRideTipRequest;
  }

  @override
  void update(void Function(AddRideTipRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AddRideTipRequest build() => _build();

  _$AddRideTipRequest _build() {
    final _$result = _$v ??
        _$AddRideTipRequest._(
          tipAmount: BuiltValueNullFieldError.checkNotNull(
              tipAmount, r'AddRideTipRequest', 'tipAmount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
