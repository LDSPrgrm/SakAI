// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ride_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UserRideItemPaymentMethodEnum _$userRideItemPaymentMethodEnum_cash =
    const UserRideItemPaymentMethodEnum._('cash');
const UserRideItemPaymentMethodEnum _$userRideItemPaymentMethodEnum_card =
    const UserRideItemPaymentMethodEnum._('card');

UserRideItemPaymentMethodEnum _$userRideItemPaymentMethodEnumValueOf(
    String name) {
  switch (name) {
    case 'cash':
      return _$userRideItemPaymentMethodEnum_cash;
    case 'card':
      return _$userRideItemPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UserRideItemPaymentMethodEnum>
    _$userRideItemPaymentMethodEnumValues = BuiltSet<
        UserRideItemPaymentMethodEnum>(const <UserRideItemPaymentMethodEnum>[
  _$userRideItemPaymentMethodEnum_cash,
  _$userRideItemPaymentMethodEnum_card,
]);

Serializer<UserRideItemPaymentMethodEnum>
    _$userRideItemPaymentMethodEnumSerializer =
    _$UserRideItemPaymentMethodEnumSerializer();

class _$UserRideItemPaymentMethodEnumSerializer
    implements PrimitiveSerializer<UserRideItemPaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'card': 'card',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'card': 'card',
  };

  @override
  final Iterable<Type> types = const <Type>[UserRideItemPaymentMethodEnum];
  @override
  final String wireName = 'UserRideItemPaymentMethodEnum';

  @override
  Object serialize(
          Serializers serializers, UserRideItemPaymentMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UserRideItemPaymentMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UserRideItemPaymentMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UserRideItem extends UserRideItem {
  @override
  final String id;
  @override
  final RideStatus status;
  @override
  final String originAddress;
  @override
  final String destinationAddress;
  @override
  final double? fare;
  @override
  final double estimatedFare;
  @override
  final DriverSummary? driver;
  @override
  final UserRideItemPaymentMethodEnum paymentMethod;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$UserRideItem([void Function(UserRideItemBuilder)? updates]) =>
      (UserRideItemBuilder()..update(updates))._build();

  _$UserRideItem._(
      {required this.id,
      required this.status,
      required this.originAddress,
      required this.destinationAddress,
      this.fare,
      required this.estimatedFare,
      this.driver,
      required this.paymentMethod,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  UserRideItem rebuild(void Function(UserRideItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserRideItemBuilder toBuilder() => UserRideItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserRideItem &&
        id == other.id &&
        status == other.status &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        fare == other.fare &&
        estimatedFare == other.estimatedFare &&
        driver == other.driver &&
        paymentMethod == other.paymentMethod &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, fare.hashCode);
    _$hash = $jc(_$hash, estimatedFare.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserRideItem')
          ..add('id', id)
          ..add('status', status)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('fare', fare)
          ..add('estimatedFare', estimatedFare)
          ..add('driver', driver)
          ..add('paymentMethod', paymentMethod)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class UserRideItemBuilder
    implements Builder<UserRideItem, UserRideItemBuilder> {
  _$UserRideItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  RideStatus? _status;
  RideStatus? get status => _$this._status;
  set status(RideStatus? status) => _$this._status = status;

  String? _originAddress;
  String? get originAddress => _$this._originAddress;
  set originAddress(String? originAddress) =>
      _$this._originAddress = originAddress;

  String? _destinationAddress;
  String? get destinationAddress => _$this._destinationAddress;
  set destinationAddress(String? destinationAddress) =>
      _$this._destinationAddress = destinationAddress;

  double? _fare;
  double? get fare => _$this._fare;
  set fare(double? fare) => _$this._fare = fare;

  double? _estimatedFare;
  double? get estimatedFare => _$this._estimatedFare;
  set estimatedFare(double? estimatedFare) =>
      _$this._estimatedFare = estimatedFare;

  DriverSummaryBuilder? _driver;
  DriverSummaryBuilder get driver => _$this._driver ??= DriverSummaryBuilder();
  set driver(DriverSummaryBuilder? driver) => _$this._driver = driver;

  UserRideItemPaymentMethodEnum? _paymentMethod;
  UserRideItemPaymentMethodEnum? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(UserRideItemPaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserRideItemBuilder() {
    UserRideItem._defaults(this);
  }

  UserRideItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _fare = $v.fare;
      _estimatedFare = $v.estimatedFare;
      _driver = $v.driver?.toBuilder();
      _paymentMethod = $v.paymentMethod;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserRideItem other) {
    _$v = other as _$UserRideItem;
  }

  @override
  void update(void Function(UserRideItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserRideItem build() => _build();

  _$UserRideItem _build() {
    _$UserRideItem _$result;
    try {
      _$result = _$v ??
          _$UserRideItem._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserRideItem', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'UserRideItem', 'status'),
            originAddress: BuiltValueNullFieldError.checkNotNull(
                originAddress, r'UserRideItem', 'originAddress'),
            destinationAddress: BuiltValueNullFieldError.checkNotNull(
                destinationAddress, r'UserRideItem', 'destinationAddress'),
            fare: fare,
            estimatedFare: BuiltValueNullFieldError.checkNotNull(
                estimatedFare, r'UserRideItem', 'estimatedFare'),
            driver: _driver?.build(),
            paymentMethod: BuiltValueNullFieldError.checkNotNull(
                paymentMethod, r'UserRideItem', 'paymentMethod'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'UserRideItem', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'UserRideItem', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driver';
        _driver?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserRideItem', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
