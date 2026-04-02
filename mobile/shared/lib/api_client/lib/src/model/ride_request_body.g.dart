// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RideRequestBody extends RideRequestBody {
  @override
  final LatLng origin;
  @override
  final LatLng destination;
  @override
  final String? originAddress;
  @override
  final String? destinationAddress;
  @override
  final String? notes;

  factory _$RideRequestBody([void Function(RideRequestBodyBuilder)? updates]) =>
      (RideRequestBodyBuilder()..update(updates))._build();

  _$RideRequestBody._(
      {required this.origin,
      required this.destination,
      this.originAddress,
      this.destinationAddress,
      this.notes})
      : super._();
  @override
  RideRequestBody rebuild(void Function(RideRequestBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RideRequestBodyBuilder toBuilder() => RideRequestBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RideRequestBody &&
        origin == other.origin &&
        destination == other.destination &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RideRequestBody')
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('notes', notes))
        .toString();
  }
}

class RideRequestBodyBuilder
    implements Builder<RideRequestBody, RideRequestBodyBuilder> {
  _$RideRequestBody? _$v;

  LatLngBuilder? _origin;
  LatLngBuilder get origin => _$this._origin ??= LatLngBuilder();
  set origin(LatLngBuilder? origin) => _$this._origin = origin;

  LatLngBuilder? _destination;
  LatLngBuilder get destination => _$this._destination ??= LatLngBuilder();
  set destination(LatLngBuilder? destination) =>
      _$this._destination = destination;

  String? _originAddress;
  String? get originAddress => _$this._originAddress;
  set originAddress(String? originAddress) =>
      _$this._originAddress = originAddress;

  String? _destinationAddress;
  String? get destinationAddress => _$this._destinationAddress;
  set destinationAddress(String? destinationAddress) =>
      _$this._destinationAddress = destinationAddress;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  RideRequestBodyBuilder() {
    RideRequestBody._defaults(this);
  }

  RideRequestBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RideRequestBody other) {
    _$v = other as _$RideRequestBody;
  }

  @override
  void update(void Function(RideRequestBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RideRequestBody build() => _build();

  _$RideRequestBody _build() {
    _$RideRequestBody _$result;
    try {
      _$result = _$v ??
          _$RideRequestBody._(
            origin: origin.build(),
            destination: destination.build(),
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            notes: notes,
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
            r'RideRequestBody', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
