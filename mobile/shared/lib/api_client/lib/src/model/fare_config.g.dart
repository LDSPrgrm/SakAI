// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fare_config.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FareConfig extends FareConfig {
  @override
  final String? id;
  @override
  final String? vehicleType;
  @override
  final num? baseFare;
  @override
  final num? perKmRate;
  @override
  final num? perMinRate;
  @override
  final num? minimumFare;
  @override
  final num? bookingFee;
  @override
  final num? cancellationFee;
  @override
  final DateTime? updatedAt;
  @override
  final String? updatedBy;
  @override
  final String? updatedByName;

  factory _$FareConfig([void Function(FareConfigBuilder)? updates]) =>
      (FareConfigBuilder()..update(updates))._build();

  _$FareConfig._({
    this.id,
    this.vehicleType,
    this.baseFare,
    this.perKmRate,
    this.perMinRate,
    this.minimumFare,
    this.bookingFee,
    this.cancellationFee,
    this.updatedAt,
    this.updatedBy,
    this.updatedByName,
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
        id == other.id &&
        vehicleType == other.vehicleType &&
        baseFare == other.baseFare &&
        perKmRate == other.perKmRate &&
        perMinRate == other.perMinRate &&
        minimumFare == other.minimumFare &&
        bookingFee == other.bookingFee &&
        cancellationFee == other.cancellationFee &&
        updatedAt == other.updatedAt &&
        updatedBy == other.updatedBy &&
        updatedByName == other.updatedByName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, vehicleType.hashCode);
    _$hash = $jc(_$hash, baseFare.hashCode);
    _$hash = $jc(_$hash, perKmRate.hashCode);
    _$hash = $jc(_$hash, perMinRate.hashCode);
    _$hash = $jc(_$hash, minimumFare.hashCode);
    _$hash = $jc(_$hash, bookingFee.hashCode);
    _$hash = $jc(_$hash, cancellationFee.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jc(_$hash, updatedByName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FareConfig')
          ..add('id', id)
          ..add('vehicleType', vehicleType)
          ..add('baseFare', baseFare)
          ..add('perKmRate', perKmRate)
          ..add('perMinRate', perMinRate)
          ..add('minimumFare', minimumFare)
          ..add('bookingFee', bookingFee)
          ..add('cancellationFee', cancellationFee)
          ..add('updatedAt', updatedAt)
          ..add('updatedBy', updatedBy)
          ..add('updatedByName', updatedByName))
        .toString();
  }
}

class FareConfigBuilder implements Builder<FareConfig, FareConfigBuilder> {
  _$FareConfig? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  String? _updatedByName;
  String? get updatedByName => _$this._updatedByName;
  set updatedByName(String? updatedByName) =>
      _$this._updatedByName = updatedByName;

  FareConfigBuilder() {
    FareConfig._defaults(this);
  }

  FareConfigBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _vehicleType = $v.vehicleType;
      _baseFare = $v.baseFare;
      _perKmRate = $v.perKmRate;
      _perMinRate = $v.perMinRate;
      _minimumFare = $v.minimumFare;
      _bookingFee = $v.bookingFee;
      _cancellationFee = $v.cancellationFee;
      _updatedAt = $v.updatedAt;
      _updatedBy = $v.updatedBy;
      _updatedByName = $v.updatedByName;
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
          id: id,
          vehicleType: vehicleType,
          baseFare: baseFare,
          perKmRate: perKmRate,
          perMinRate: perMinRate,
          minimumFare: minimumFare,
          bookingFee: bookingFee,
          cancellationFee: cancellationFee,
          updatedAt: updatedAt,
          updatedBy: updatedBy,
          updatedByName: updatedByName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
