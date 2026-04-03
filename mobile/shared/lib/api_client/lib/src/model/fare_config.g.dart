// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareConfig extends FareConfig {
  @override
  final String vehicleType;
  @override
  final num baseFare;
  @override
  final num perKmRate;
  @override
  final num perMinRate;
  @override
  final num minimumFare;
  @override
  final num bookingFee;
  @override
  final num cancellationFee;

  factory _$FareConfig([void Function(FareConfigBuilder)? updates]) =>
      (FareConfigBuilder()..update(updates))._build();

  _$FareConfig._({
    required this.vehicleType,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinRate,
    required this.minimumFare,
    required this.bookingFee,
    required this.cancellationFee,
  }) : super._();
  @override
  FareConfig rebuild(void Function(FareConfigBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FareConfigBuilder toBuilder() => FareConfigBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FareConfig &&
        vehicleType == other.vehicleType &&
        baseFare == other.baseFare &&
        perKmRate == other.perKmRate &&
        perMinRate == other.perMinRate &&
        minimumFare == other.minimumFare &&
        bookingFee == other.bookingFee &&
        cancellationFee == other.cancellationFee;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, baseFare.hashCode);
    _$hash = $jc(_$hash, perKmRate.hashCode);
    _$hash = $jc(_$hash, perMinRate.hashCode);
    _$hash = $jc(_$hash, minimumFare.hashCode);
    _$hash = $jc(_$hash, bookingFee.hashCode);
    _$hash = $jc(_$hash, cancellationFee.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareConfig')
          ..add('vehicleType', vehicleType)
          ..add('baseFare', baseFare)
          ..add('perKmRate', perKmRate)
          ..add('perMinRate', perMinRate)
          ..add('minimumFare', minimumFare)
          ..add('bookingFee', bookingFee)
          ..add('cancellationFee', cancellationFee))
        .toString();
  }
}

class FareConfigBuilder implements Builder<FareConfig, FareConfigBuilder> {
  _$FareConfig? _$v;

  String? _vehicleType;
  String? get vehicleType => _$this._vehicleType;
  set vehicleType(String? vehicleType) => _$this._vehicleType = vehicleType;

  num? _baseFare;
  num? get baseFare => _$this._baseFare;
  set baseFare(num? baseFare) => _$this._baseFare = baseFare;

  num? _perKmRate;
  num? get perKmRate => _$this._perKmRate;
  set perKmRate(num? perKmRate) => _$this._perKmRate = perKmRate;

  num? _perMinRate;
  num? get perMinRate => _$this._perMinRate;
  set perMinRate(num? perMinRate) => _$this._perMinRate = perMinRate;

  num? _minimumFare;
  num? get minimumFare => _$this._minimumFare;
  set minimumFare(num? minimumFare) => _$this._minimumFare = minimumFare;

  num? _bookingFee;
  num? get bookingFee => _$this._bookingFee;
  set bookingFee(num? bookingFee) => _$this._bookingFee = bookingFee;

  num? _cancellationFee;
  num? get cancellationFee => _$this._cancellationFee;
  set cancellationFee(num? cancellationFee) =>
      _$this._cancellationFee = cancellationFee;

  FareConfigBuilder() {
    FareConfig._defaults(this);
  }

  FareConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _vehicleType = $v.vehicleType;
      _baseFare = $v.baseFare;
      _perKmRate = $v.perKmRate;
      _perMinRate = $v.perMinRate;
      _minimumFare = $v.minimumFare;
      _bookingFee = $v.bookingFee;
      _cancellationFee = $v.cancellationFee;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FareConfig other) {
    _$v = other as _$FareConfig;
  }

  @override
  void update(void Function(FareConfigBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FareConfig build() => _build();

  _$FareConfig _build() {
    final _$result =
        _$v ??
        _$FareConfig._(
          vehicleType: BuiltValueNullFieldError.checkNotNull(
            vehicleType,
            r'FareConfig',
            'vehicleType',
          ),
          baseFare: BuiltValueNullFieldError.checkNotNull(
            baseFare,
            r'FareConfig',
            'baseFare',
          ),
          perKmRate: BuiltValueNullFieldError.checkNotNull(
            perKmRate,
            r'FareConfig',
            'perKmRate',
          ),
          perMinRate: BuiltValueNullFieldError.checkNotNull(
            perMinRate,
            r'FareConfig',
            'perMinRate',
          ),
          minimumFare: BuiltValueNullFieldError.checkNotNull(
            minimumFare,
            r'FareConfig',
            'minimumFare',
          ),
          bookingFee: BuiltValueNullFieldError.checkNotNull(
            bookingFee,
            r'FareConfig',
            'bookingFee',
          ),
          cancellationFee: BuiltValueNullFieldError.checkNotNull(
            cancellationFee,
            r'FareConfig',
            'cancellationFee',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
