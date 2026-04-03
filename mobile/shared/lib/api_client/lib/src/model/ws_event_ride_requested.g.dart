// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_ride_requested.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventRideRequested extends WsEventRideRequested {
  @override
  final String rideId;
  @override
  final UserProfile passenger;
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
  @override
  final DateTime expiresAt;

  factory _$WsEventRideRequested([
    void Function(WsEventRideRequestedBuilder)? updates,
  ]) => (WsEventRideRequestedBuilder()..update(updates))._build();

  _$WsEventRideRequested._({
    required this.rideId,
    required this.passenger,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
    this.notes,
    required this.expiresAt,
  }) : super._();
  @override
  WsEventRideRequested rebuild(
    void Function(WsEventRideRequestedBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventRideRequestedBuilder toBuilder() =>
      WsEventRideRequestedBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventRideRequested &&
        rideId == other.rideId &&
        passenger == other.passenger &&
        origin == other.origin &&
        destination == other.destination &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        notes == other.notes &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rideId.hashCode);
    _$hash = $jc(_$hash, passenger.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventRideRequested')
          ..add('rideId', rideId)
          ..add('passenger', passenger)
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('notes', notes)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class WsEventRideRequestedBuilder
    implements Builder<WsEventRideRequested, WsEventRideRequestedBuilder> {
  _$WsEventRideRequested? _$v;

  String? _rideId;
  String? get rideId => _$this._rideId;
  set rideId(String? rideId) => _$this._rideId = rideId;

  UserProfileBuilder? _passenger;
  UserProfileBuilder get passenger =>
      _$this._passenger ??= UserProfileBuilder();
  set passenger(UserProfileBuilder? passenger) => _$this._passenger = passenger;

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

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  WsEventRideRequestedBuilder() {
    WsEventRideRequested._defaults(this);
  }

  WsEventRideRequestedBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rideId = $v.rideId;
      _passenger = $v.passenger.toBuilder();
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _notes = $v.notes;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventRideRequested other) {
    _$v = other as _$WsEventRideRequested;
  }

  @override
  void update(void Function(WsEventRideRequestedBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventRideRequested build() => _build();

  _$WsEventRideRequested _build() {
    _$WsEventRideRequested _$result;
    try {
      _$result =
          _$v ??
          _$WsEventRideRequested._(
            rideId: BuiltValueNullFieldError.checkNotNull(
              rideId,
              r'WsEventRideRequested',
              'rideId',
            ),
            passenger: passenger.build(),
            origin: origin.build(),
            destination: destination.build(),
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            notes: notes,
            expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt,
              r'WsEventRideRequested',
              'expiresAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'passenger';
        passenger.build();
        _$failedField = 'origin';
        origin.build();
        _$failedField = 'destination';
        destination.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'WsEventRideRequested',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
