// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ride_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminRideItemRideTypeEnum _$adminRideItemRideTypeEnum_motorcycle =
    const AdminRideItemRideTypeEnum._('motorcycle');
const AdminRideItemRideTypeEnum _$adminRideItemRideTypeEnum_car =
    const AdminRideItemRideTypeEnum._('car');
const AdminRideItemRideTypeEnum _$adminRideItemRideTypeEnum_tricycle =
    const AdminRideItemRideTypeEnum._('tricycle');

AdminRideItemRideTypeEnum _$adminRideItemRideTypeEnumValueOf(String name) {
  switch (name) {
    case 'motorcycle':
      return _$adminRideItemRideTypeEnum_motorcycle;
    case 'car':
      return _$adminRideItemRideTypeEnum_car;
    case 'tricycle':
      return _$adminRideItemRideTypeEnum_tricycle;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminRideItemRideTypeEnum> _$adminRideItemRideTypeEnumValues =
    BuiltSet<AdminRideItemRideTypeEnum>(const <AdminRideItemRideTypeEnum>[
      _$adminRideItemRideTypeEnum_motorcycle,
      _$adminRideItemRideTypeEnum_car,
      _$adminRideItemRideTypeEnum_tricycle,
    ]);

const AdminRideItemPaymentMethodEnum _$adminRideItemPaymentMethodEnum_cash =
    const AdminRideItemPaymentMethodEnum._('cash');
const AdminRideItemPaymentMethodEnum _$adminRideItemPaymentMethodEnum_gcash =
    const AdminRideItemPaymentMethodEnum._('gcash');
const AdminRideItemPaymentMethodEnum _$adminRideItemPaymentMethodEnum_paymaya =
    const AdminRideItemPaymentMethodEnum._('paymaya');
const AdminRideItemPaymentMethodEnum _$adminRideItemPaymentMethodEnum_card =
    const AdminRideItemPaymentMethodEnum._('card');

AdminRideItemPaymentMethodEnum _$adminRideItemPaymentMethodEnumValueOf(
  String name,
) {
  switch (name) {
    case 'cash':
      return _$adminRideItemPaymentMethodEnum_cash;
    case 'gcash':
      return _$adminRideItemPaymentMethodEnum_gcash;
    case 'paymaya':
      return _$adminRideItemPaymentMethodEnum_paymaya;
    case 'card':
      return _$adminRideItemPaymentMethodEnum_card;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminRideItemPaymentMethodEnum>
_$adminRideItemPaymentMethodEnumValues =
    BuiltSet<AdminRideItemPaymentMethodEnum>(
      const <AdminRideItemPaymentMethodEnum>[
        _$adminRideItemPaymentMethodEnum_cash,
        _$adminRideItemPaymentMethodEnum_gcash,
        _$adminRideItemPaymentMethodEnum_paymaya,
        _$adminRideItemPaymentMethodEnum_card,
      ],
    );

const AdminRideItemCancelledByEnum _$adminRideItemCancelledByEnum_passenger =
    const AdminRideItemCancelledByEnum._('passenger');
const AdminRideItemCancelledByEnum _$adminRideItemCancelledByEnum_driver =
    const AdminRideItemCancelledByEnum._('driver');

AdminRideItemCancelledByEnum _$adminRideItemCancelledByEnumValueOf(
  String name,
) {
  switch (name) {
    case 'passenger':
      return _$adminRideItemCancelledByEnum_passenger;
    case 'driver':
      return _$adminRideItemCancelledByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminRideItemCancelledByEnum>
_$adminRideItemCancelledByEnumValues = BuiltSet<AdminRideItemCancelledByEnum>(
  const <AdminRideItemCancelledByEnum>[
    _$adminRideItemCancelledByEnum_passenger,
    _$adminRideItemCancelledByEnum_driver,
  ],
);

Serializer<AdminRideItemRideTypeEnum> _$adminRideItemRideTypeEnumSerializer =
    _$AdminRideItemRideTypeEnumSerializer();
Serializer<AdminRideItemPaymentMethodEnum>
_$adminRideItemPaymentMethodEnumSerializer =
    _$AdminRideItemPaymentMethodEnumSerializer();
Serializer<AdminRideItemCancelledByEnum>
_$adminRideItemCancelledByEnumSerializer =
    _$AdminRideItemCancelledByEnumSerializer();

class _$AdminRideItemRideTypeEnumSerializer
    implements PrimitiveSerializer<AdminRideItemRideTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'motorcycle': 'motorcycle',
    'car': 'car',
    'tricycle': 'tricycle',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'motorcycle': 'motorcycle',
    'car': 'car',
    'tricycle': 'tricycle',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminRideItemRideTypeEnum];
  @override
  final String wireName = 'AdminRideItemRideTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminRideItemRideTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminRideItemRideTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminRideItemRideTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminRideItemPaymentMethodEnumSerializer
    implements PrimitiveSerializer<AdminRideItemPaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
    'card': 'card',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminRideItemPaymentMethodEnum];
  @override
  final String wireName = 'AdminRideItemPaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminRideItemPaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminRideItemPaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminRideItemPaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminRideItemCancelledByEnumSerializer
    implements PrimitiveSerializer<AdminRideItemCancelledByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[AdminRideItemCancelledByEnum];
  @override
  final String wireName = 'AdminRideItemCancelledByEnum';

  @override
  Object serialize(
    Serializers serializers,
    AdminRideItemCancelledByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  AdminRideItemCancelledByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => AdminRideItemCancelledByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$AdminRideItem extends AdminRideItem {
  @override
  final String? passengerName;
  @override
  final num? totalFare;
  @override
  final String? driverName;
  @override
  final String id;
  @override
  final int? seq;
  @override
  final String? displayId;
  @override
  final RideStatus status;
  @override
  final UserProfile passenger;
  @override
  final DriverSummary? driver;
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
  final double? fare;
  @override
  final double? estimatedFare;
  @override
  final double? actualFare;
  @override
  final BuiltMap<String, JsonObject?>? fareBreakdown;
  @override
  final RideResponseRideTypeEnum? rideType;
  @override
  final RideResponsePaymentMethodEnum? paymentMethod;
  @override
  final RideResponseCancelledByEnum? cancelledBy;
  @override
  final String? cancellationReason;
  @override
  final String? cancellationReasonText;
  @override
  final int? declineCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$AdminRideItem([void Function(AdminRideItemBuilder)? updates]) =>
      (AdminRideItemBuilder()..update(updates))._build();

  _$AdminRideItem._({
    this.passengerName,
    this.totalFare,
    this.driverName,
    required this.id,
    this.seq,
    this.displayId,
    required this.status,
    required this.passenger,
    this.driver,
    required this.origin,
    required this.destination,
    this.originAddress,
    this.destinationAddress,
    this.notes,
    this.fare,
    this.estimatedFare,
    this.actualFare,
    this.fareBreakdown,
    this.rideType,
    this.paymentMethod,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationReasonText,
    this.declineCount,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();
  @override
  AdminRideItem rebuild(void Function(AdminRideItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminRideItemBuilder toBuilder() => AdminRideItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRideItem &&
        passengerName == other.passengerName &&
        totalFare == other.totalFare &&
        driverName == other.driverName &&
        id == other.id &&
        seq == other.seq &&
        displayId == other.displayId &&
        status == other.status &&
        passenger == other.passenger &&
        driver == other.driver &&
        origin == other.origin &&
        destination == other.destination &&
        originAddress == other.originAddress &&
        destinationAddress == other.destinationAddress &&
        notes == other.notes &&
        fare == other.fare &&
        estimatedFare == other.estimatedFare &&
        actualFare == other.actualFare &&
        fareBreakdown == other.fareBreakdown &&
        rideType == other.rideType &&
        paymentMethod == other.paymentMethod &&
        cancelledBy == other.cancelledBy &&
        cancellationReason == other.cancellationReason &&
        cancellationReasonText == other.cancellationReasonText &&
        declineCount == other.declineCount &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, passengerName.hashCode);
    _$hash = $jc(_$hash, totalFare.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, seq.hashCode);
    _$hash = $jc(_$hash, displayId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, passenger.hashCode);
    _$hash = $jc(_$hash, driver.hashCode);
    _$hash = $jc(_$hash, origin.hashCode);
    _$hash = $jc(_$hash, destination.hashCode);
    _$hash = $jc(_$hash, originAddress.hashCode);
    _$hash = $jc(_$hash, destinationAddress.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, fare.hashCode);
    _$hash = $jc(_$hash, estimatedFare.hashCode);
    _$hash = $jc(_$hash, actualFare.hashCode);
    _$hash = $jc(_$hash, fareBreakdown.hashCode);
    _$hash = $jc(_$hash, rideType.hashCode);
    _$hash = $jc(_$hash, paymentMethod.hashCode);
    _$hash = $jc(_$hash, cancelledBy.hashCode);
    _$hash = $jc(_$hash, cancellationReason.hashCode);
    _$hash = $jc(_$hash, cancellationReasonText.hashCode);
    _$hash = $jc(_$hash, declineCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminRideItem')
          ..add('passengerName', passengerName)
          ..add('totalFare', totalFare)
          ..add('driverName', driverName)
          ..add('id', id)
          ..add('seq', seq)
          ..add('displayId', displayId)
          ..add('status', status)
          ..add('passenger', passenger)
          ..add('driver', driver)
          ..add('origin', origin)
          ..add('destination', destination)
          ..add('originAddress', originAddress)
          ..add('destinationAddress', destinationAddress)
          ..add('notes', notes)
          ..add('fare', fare)
          ..add('estimatedFare', estimatedFare)
          ..add('actualFare', actualFare)
          ..add('fareBreakdown', fareBreakdown)
          ..add('rideType', rideType)
          ..add('paymentMethod', paymentMethod)
          ..add('cancelledBy', cancelledBy)
          ..add('cancellationReason', cancellationReason)
          ..add('cancellationReasonText', cancellationReasonText)
          ..add('declineCount', declineCount)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AdminRideItemBuilder
    implements
        Builder<AdminRideItem, AdminRideItemBuilder>,
        RideResponseBuilder {
  _$AdminRideItem? _$v;

  String? _passengerName;
  String? get passengerName => _$this._passengerName;
  set passengerName(covariant String? passengerName) =>
      _$this._passengerName = passengerName;

  num? _totalFare;
  num? get totalFare => _$this._totalFare;
  set totalFare(covariant num? totalFare) => _$this._totalFare = totalFare;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(covariant String? driverName) =>
      _$this._driverName = driverName;

  String? _id;
  String? get id => _$this._id;
  set id(covariant String? id) => _$this._id = id;

  int? _seq;
  int? get seq => _$this._seq;
  set seq(covariant int? seq) => _$this._seq = seq;

  String? _displayId;
  String? get displayId => _$this._displayId;
  set displayId(covariant String? displayId) => _$this._displayId = displayId;

  RideStatus? _status;
  RideStatus? get status => _$this._status;
  set status(covariant RideStatus? status) => _$this._status = status;

  UserProfile? _passenger;
  UserProfile? get passenger => _$this._passenger;
  set passenger(covariant UserProfile? passenger) =>
      _$this._passenger = passenger;

  DriverSummaryBuilder? _driver;
  DriverSummaryBuilder get driver => _$this._driver ??= DriverSummaryBuilder();
  set driver(covariant DriverSummaryBuilder? driver) => _$this._driver = driver;

  LatLngBuilder? _origin;
  LatLngBuilder get origin => _$this._origin ??= LatLngBuilder();
  set origin(covariant LatLngBuilder? origin) => _$this._origin = origin;

  LatLngBuilder? _destination;
  LatLngBuilder get destination => _$this._destination ??= LatLngBuilder();
  set destination(covariant LatLngBuilder? destination) =>
      _$this._destination = destination;

  String? _originAddress;
  String? get originAddress => _$this._originAddress;
  set originAddress(covariant String? originAddress) =>
      _$this._originAddress = originAddress;

  String? _destinationAddress;
  String? get destinationAddress => _$this._destinationAddress;
  set destinationAddress(covariant String? destinationAddress) =>
      _$this._destinationAddress = destinationAddress;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(covariant String? notes) => _$this._notes = notes;

  double? _fare;
  double? get fare => _$this._fare;
  set fare(covariant double? fare) => _$this._fare = fare;

  double? _estimatedFare;
  double? get estimatedFare => _$this._estimatedFare;
  set estimatedFare(covariant double? estimatedFare) =>
      _$this._estimatedFare = estimatedFare;

  double? _actualFare;
  double? get actualFare => _$this._actualFare;
  set actualFare(covariant double? actualFare) =>
      _$this._actualFare = actualFare;

  MapBuilder<String, JsonObject?>? _fareBreakdown;
  MapBuilder<String, JsonObject?> get fareBreakdown =>
      _$this._fareBreakdown ??= MapBuilder<String, JsonObject?>();
  set fareBreakdown(covariant MapBuilder<String, JsonObject?>? fareBreakdown) =>
      _$this._fareBreakdown = fareBreakdown;

  RideResponseRideTypeEnum? _rideType;
  RideResponseRideTypeEnum? get rideType => _$this._rideType;
  set rideType(covariant RideResponseRideTypeEnum? rideType) =>
      _$this._rideType = rideType;

  RideResponsePaymentMethodEnum? _paymentMethod;
  RideResponsePaymentMethodEnum? get paymentMethod => _$this._paymentMethod;
  set paymentMethod(covariant RideResponsePaymentMethodEnum? paymentMethod) =>
      _$this._paymentMethod = paymentMethod;

  RideResponseCancelledByEnum? _cancelledBy;
  RideResponseCancelledByEnum? get cancelledBy => _$this._cancelledBy;
  set cancelledBy(covariant RideResponseCancelledByEnum? cancelledBy) =>
      _$this._cancelledBy = cancelledBy;

  String? _cancellationReason;
  String? get cancellationReason => _$this._cancellationReason;
  set cancellationReason(covariant String? cancellationReason) =>
      _$this._cancellationReason = cancellationReason;

  String? _cancellationReasonText;
  String? get cancellationReasonText => _$this._cancellationReasonText;
  set cancellationReasonText(covariant String? cancellationReasonText) =>
      _$this._cancellationReasonText = cancellationReasonText;

  int? _declineCount;
  int? get declineCount => _$this._declineCount;
  set declineCount(covariant int? declineCount) =>
      _$this._declineCount = declineCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(covariant DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(covariant DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AdminRideItemBuilder() {
    AdminRideItem._defaults(this);
  }

  AdminRideItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _passengerName = $v.passengerName;
      _totalFare = $v.totalFare;
      _driverName = $v.driverName;
      _id = $v.id;
      _seq = $v.seq;
      _displayId = $v.displayId;
      _status = $v.status;
      _passenger = $v.passenger;
      _driver = $v.driver?.toBuilder();
      _origin = $v.origin.toBuilder();
      _destination = $v.destination.toBuilder();
      _originAddress = $v.originAddress;
      _destinationAddress = $v.destinationAddress;
      _notes = $v.notes;
      _fare = $v.fare;
      _estimatedFare = $v.estimatedFare;
      _actualFare = $v.actualFare;
      _fareBreakdown = $v.fareBreakdown?.toBuilder();
      _rideType = $v.rideType;
      _paymentMethod = $v.paymentMethod;
      _cancelledBy = $v.cancelledBy;
      _cancellationReason = $v.cancellationReason;
      _cancellationReasonText = $v.cancellationReasonText;
      _declineCount = $v.declineCount;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(covariant AdminRideItem other) {
    _$v = other as _$AdminRideItem;
  }

  @override
  void update(void Function(AdminRideItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRideItem build() => _build();

  _$AdminRideItem _build() {
    _$AdminRideItem _$result;
    try {
      _$result =
          _$v ??
          _$AdminRideItem._(
            passengerName: passengerName,
            totalFare: totalFare,
            driverName: driverName,
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'AdminRideItem',
              'id',
            ),
            seq: seq,
            displayId: displayId,
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'AdminRideItem',
              'status',
            ),
            passenger: BuiltValueNullFieldError.checkNotNull(
              passenger,
              r'AdminRideItem',
              'passenger',
            ),
            driver: _driver?.build(),
            origin: origin.build(),
            destination: destination.build(),
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            notes: notes,
            fare: fare,
            estimatedFare: estimatedFare,
            actualFare: actualFare,
            fareBreakdown: _fareBreakdown?.build(),
            rideType: rideType,
            paymentMethod: paymentMethod,
            cancelledBy: cancelledBy,
            cancellationReason: cancellationReason,
            cancellationReasonText: cancellationReasonText,
            declineCount: declineCount,
            createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'AdminRideItem',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'AdminRideItem',
              'updatedAt',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driver';
        _driver?.build();
        _$failedField = 'origin';
        origin.build();
        _$failedField = 'destination';
        destination.build();

        _$failedField = 'fareBreakdown';
        _fareBreakdown?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminRideItem',
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
