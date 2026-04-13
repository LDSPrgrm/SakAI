// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_simulation_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareSimulationResponse extends FareSimulationResponse {
  @override
  final num? estimatedFare;

  factory _$FareSimulationResponse([
    void Function(FareSimulationResponseBuilder)? updates,
  ]) => (FareSimulationResponseBuilder()..update(updates))._build();

  _$FareSimulationResponse._({this.estimatedFare}) : super._();
  @override
  FareSimulationResponse rebuild(
    void Function(FareSimulationResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  FareSimulationResponseBuilder toBuilder() =>
      FareSimulationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareSimulationResponse &&
        estimatedFare == other.estimatedFare;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, estimatedFare.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'FareSimulationResponse',
    )..add('estimatedFare', estimatedFare)).toString();
  }
}

class FareSimulationResponseBuilder
    implements Builder<FareSimulationResponse, FareSimulationResponseBuilder> {
  _$FareSimulationResponse? _$v;

  num? _estimatedFare;
  num? get estimatedFare => _$this._estimatedFare;
  set estimatedFare(num? estimatedFare) =>
      _$this._estimatedFare = estimatedFare;

  FareSimulationResponseBuilder() {
    FareSimulationResponse._defaults(this);
  }

  FareSimulationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _estimatedFare = $v.estimatedFare;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareSimulationResponse other) {
    _$v = other as _$FareSimulationResponse;
  }

  @override
  void update(void Function(FareSimulationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareSimulationResponse build() => _build();

  _$FareSimulationResponse _build() {
    final _$result =
        _$v ?? _$FareSimulationResponse._(estimatedFare: estimatedFare);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
