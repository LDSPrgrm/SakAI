// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RideResponseRideTypeEnum _$rideResponseRideTypeEnum_motorcycle =
    const RideResponseRideTypeEnum._('motorcycle');
const RideResponseRideTypeEnum _$rideResponseRideTypeEnum_car =
    const RideResponseRideTypeEnum._('car');
const RideResponseRideTypeEnum _$rideResponseRideTypeEnum_tricycle =
    const RideResponseRideTypeEnum._('tricycle');

RideResponseRideTypeEnum _$rideResponseRideTypeEnumValueOf(String name) {
  switch (name) {
    case 'motorcycle':
      return _$rideResponseRideTypeEnum_motorcycle;
    case 'car':
      return _$rideResponseRideTypeEnum_car;
    case 'tricycle':
      return _$rideResponseRideTypeEnum_tricycle;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideResponseRideTypeEnum> _$rideResponseRideTypeEnumValues =
    BuiltSet<RideResponseRideTypeEnum>(const <RideResponseRideTypeEnum>[
      _$rideResponseRideTypeEnum_motorcycle,
      _$rideResponseRideTypeEnum_car,
      _$rideResponseRideTypeEnum_tricycle,
    ]);

const RideResponsePaymentMethodEnum _$rideResponsePaymentMethodEnum_cash =
    const RideResponsePaymentMethodEnum._('cash');
const RideResponsePaymentMethodEnum _$rideResponsePaymentMethodEnum_card =
    const RideResponsePaymentMethodEnum._('card');
const RideResponsePaymentMethodEnum _$rideResponsePaymentMethodEnum_gcash =
    const RideResponsePaymentMethodEnum._('gcash');
const RideResponsePaymentMethodEnum _$rideResponsePaymentMethodEnum_paymaya =
    const RideResponsePaymentMethodEnum._('paymaya');

RideResponsePaymentMethodEnum _$rideResponsePaymentMethodEnumValueOf(
  String name,
) {
  switch (name) {
    case 'cash':
      return _$rideResponsePaymentMethodEnum_cash;
    case 'card':
      return _$rideResponsePaymentMethodEnum_card;
    case 'gcash':
      return _$rideResponsePaymentMethodEnum_gcash;
    case 'paymaya':
      return _$rideResponsePaymentMethodEnum_paymaya;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideResponsePaymentMethodEnum>
_$rideResponsePaymentMethodEnumValues = BuiltSet<RideResponsePaymentMethodEnum>(
  const <RideResponsePaymentMethodEnum>[
    _$rideResponsePaymentMethodEnum_cash,
    _$rideResponsePaymentMethodEnum_card,
    _$rideResponsePaymentMethodEnum_gcash,
    _$rideResponsePaymentMethodEnum_paymaya,
  ],
);

const RideResponseCancelledByEnum _$rideResponseCancelledByEnum_passenger =
    const RideResponseCancelledByEnum._('passenger');
const RideResponseCancelledByEnum _$rideResponseCancelledByEnum_driver =
    const RideResponseCancelledByEnum._('driver');

RideResponseCancelledByEnum _$rideResponseCancelledByEnumValueOf(String name) {
  switch (name) {
    case 'passenger':
      return _$rideResponseCancelledByEnum_passenger;
    case 'driver':
      return _$rideResponseCancelledByEnum_driver;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RideResponseCancelledByEnum>
_$rideResponseCancelledByEnumValues = BuiltSet<RideResponseCancelledByEnum>(
  const <RideResponseCancelledByEnum>[
    _$rideResponseCancelledByEnum_passenger,
    _$rideResponseCancelledByEnum_driver,
  ],
);

Serializer<RideResponseRideTypeEnum> _$rideResponseRideTypeEnumSerializer =
    _$RideResponseRideTypeEnumSerializer();
Serializer<RideResponsePaymentMethodEnum>
_$rideResponsePaymentMethodEnumSerializer =
    _$RideResponsePaymentMethodEnumSerializer();
Serializer<RideResponseCancelledByEnum>
_$rideResponseCancelledByEnumSerializer =
    _$RideResponseCancelledByEnumSerializer();

class _$RideResponseRideTypeEnumSerializer
    implements PrimitiveSerializer<RideResponseRideTypeEnum> {
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
  final Iterable<Type> types = const <Type>[RideResponseRideTypeEnum];
  @override
  final String wireName = 'RideResponseRideTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    RideResponseRideTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideResponseRideTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideResponseRideTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RideResponsePaymentMethodEnumSerializer
    implements PrimitiveSerializer<RideResponsePaymentMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cash': 'cash',
    'card': 'card',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cash': 'cash',
    'card': 'card',
    'gcash': 'gcash',
    'paymaya': 'paymaya',
  };

  @override
  final Iterable<Type> types = const <Type>[RideResponsePaymentMethodEnum];
  @override
  final String wireName = 'RideResponsePaymentMethodEnum';

  @override
  Object serialize(
    Serializers serializers,
    RideResponsePaymentMethodEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideResponsePaymentMethodEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideResponsePaymentMethodEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$RideResponseCancelledByEnumSerializer
    implements PrimitiveSerializer<RideResponseCancelledByEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'passenger': 'passenger',
    'driver': 'driver',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'passenger': 'passenger',
    'driver': 'driver',
  };

  @override
  final Iterable<Type> types = const <Type>[RideResponseCancelledByEnum];
  @override
  final String wireName = 'RideResponseCancelledByEnum';

  @override
  Object serialize(
    Serializers serializers,
    RideResponseCancelledByEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  RideResponseCancelledByEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => RideResponseCancelledByEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

abstract mixin class RideResponseBuilder {
  void replace(RideResponse other);
  void update(void Function(RideResponseBuilder) updates);
  String? get id;
  set id(String? id);

  int? get seq;
  set seq(int? seq);

  String? get displayId;
  set displayId(String? displayId);

  RideStatus? get status;
  set status(RideStatus? status);

  UserProfile? get passenger;
  set passenger(UserProfile? passenger);

  DriverSummaryBuilder get driver;
  set driver(DriverSummaryBuilder? driver);

  LatLngBuilder get origin;
  set origin(LatLngBuilder? origin);

  LatLngBuilder get destination;
  set destination(LatLngBuilder? destination);

  String? get originAddress;
  set originAddress(String? originAddress);

  String? get destinationAddress;
  set destinationAddress(String? destinationAddress);

  String? get notes;
  set notes(String? notes);

  double? get fare;
  set fare(double? fare);

  double? get estimatedFare;
  set estimatedFare(double? estimatedFare);

  double? get actualFare;
  set actualFare(double? actualFare);

  MapBuilder<String, JsonObject?> get fareBreakdown;
  set fareBreakdown(MapBuilder<String, JsonObject?>? fareBreakdown);

  RideResponseRideTypeEnum? get rideType;
  set rideType(RideResponseRideTypeEnum? rideType);

  RideResponsePaymentMethodEnum? get paymentMethod;
  set paymentMethod(RideResponsePaymentMethodEnum? paymentMethod);

  RideResponseCancelledByEnum? get cancelledBy;
  set cancelledBy(RideResponseCancelledByEnum? cancelledBy);

  String? get cancellationReason;
  set cancellationReason(String? cancellationReason);

  String? get cancellationReasonText;
  set cancellationReasonText(String? cancellationReasonText);

  int? get declineCount;
  set declineCount(int? declineCount);

  DateTime? get createdAt;
  set createdAt(DateTime? createdAt);

  DateTime? get updatedAt;
  set updatedAt(DateTime? updatedAt);
}

class _$$RideResponse extends $RideResponse {
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

  factory _$$RideResponse([void Function($RideResponseBuilder)? updates]) =>
      ($RideResponseBuilder()..update(updates))._build();

  _$$RideResponse._({
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
  $RideResponse rebuild(void Function($RideResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  $RideResponseBuilder toBuilder() => $RideResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is $RideResponse &&
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
    return (newBuiltValueToStringHelper(r'$RideResponse')
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

class $RideResponseBuilder
    implements
        Builder<$RideResponse, $RideResponseBuilder>,
        RideResponseBuilder {
  _$$RideResponse? _$v;

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

  $RideResponseBuilder() {
    $RideResponse._defaults(this);
  }

  $RideResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(covariant $RideResponse other) {
    _$v = other as _$$RideResponse;
  }

  @override
  void update(void Function($RideResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  $RideResponse build() => _build();

  _$$RideResponse _build() {
    _$$RideResponse _$result;
    try {
      _$result =
          _$v ??
          _$$RideResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'$RideResponse',
              'id',
            ),
            seq: seq,
            displayId: displayId,
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'$RideResponse',
              'status',
            ),
            passenger: BuiltValueNullFieldError.checkNotNull(
              passenger,
              r'$RideResponse',
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
              r'$RideResponse',
              'createdAt',
            ),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'$RideResponse',
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
          r'$RideResponse',
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
