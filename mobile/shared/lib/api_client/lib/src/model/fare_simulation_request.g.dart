// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_simulation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareSimulationRequest extends FareSimulationRequest {
  @override
  final String vehicleType;
  @override
  final LatLng origin;
  @override
  final LatLng destination;

  factory _$FareSimulationRequest(
          [void Function(FareSimulationRequestBuilder)? updates]) =>
      (FareSimulationRequestBuilder()..update(updates))._build();

  _$FareSimulationRequest._(
      {required this.vehicleType,
      required this.origin,
      required this.destination})
      : super._();
  @override
  FareSimulationRequest rebuild(
          void Function(FareSimulationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareSimulationRequestBuilder toBuilder() =>
      FareSimulationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareSimulationRequest &&
        vehicleType == other.vehicleType &&
        origin == other.origin &&
        destination == other.destination;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareSimulationRequest')
          ..add('vehicleType', vehicleType)
          ..add('origin', origin)
          ..add('destination', destination))
        .toString();
  }
}

class FareSimulationRequestBuilder
    implements Builder<FareSimulationRequest, FareSimulationRequestBuilder> {
  _$FareSimulationRequest? _$v;

  String? _vehicleType;
  String? get vehicleType => _$this._vehicleType;
  set vehicleType(String? vehicleType) => _$this._vehicleType = vehicleType;

  LatLngBuilder? _origin;
  LatLngBuilder get origin => _$this._origin ??= LatLngBuilder();
  set origin(LatLngBuilder? origin) => _$this._origin = origin;

  LatLngBuilder? _destination;
  LatLngBuilder get destination => _$this._destination ??= LatLngBuilder();
  set destination(LatLngBuilder? destination) =>
      _$this._destination = destination;

  FareSimulationRequestBuilder() {
    FareSimulationRequest._defaults(this);
  }

  FareSimulationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vehicleType = $v.vehicleType;
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareSimulationRequest other) {
    _$v = other as _$FareSimulationRequest;
  }

  @override
  void update(void Function(FareSimulationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareSimulationRequest build() => _build();

  _$FareSimulationRequest _build() {
    _$FareSimulationRequest _$result;
    try {
      _$result = _$v ??
          _$FareSimulationRequest._(
            vehicleType: BuiltValueNullFieldError.checkNotNull(
                vehicleType, r'FareSimulationRequest', 'vehicleType'),
            origin: origin.build(),
            destination: destination.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'origin';
        origin.build();
        _$failedField = 'destination';
        destination.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FareSimulationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
