// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverStatusResponseStatusEnum _$driverStatusResponseStatusEnum_online =
    const DriverStatusResponseStatusEnum._('online');
const DriverStatusResponseStatusEnum _$driverStatusResponseStatusEnum_offline =
    const DriverStatusResponseStatusEnum._('offline');

DriverStatusResponseStatusEnum _$driverStatusResponseStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'online':
      return _$driverStatusResponseStatusEnum_online;
    case 'offline':
      return _$driverStatusResponseStatusEnum_offline;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverStatusResponseStatusEnum>
_$driverStatusResponseStatusEnumValues =
    BuiltSet<DriverStatusResponseStatusEnum>(
      const <DriverStatusResponseStatusEnum>[
        _$driverStatusResponseStatusEnum_online,
        _$driverStatusResponseStatusEnum_offline,
      ],
    );

Serializer<DriverStatusResponseStatusEnum>
_$driverStatusResponseStatusEnumSerializer =
    _$DriverStatusResponseStatusEnumSerializer();

class _$DriverStatusResponseStatusEnumSerializer
    implements PrimitiveSerializer<DriverStatusResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'online': 'online',
    'offline': 'offline',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'online': 'online',
    'offline': 'offline',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverStatusResponseStatusEnum];
  @override
  final String wireName = 'DriverStatusResponseStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    DriverStatusResponseStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DriverStatusResponseStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DriverStatusResponseStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$DriverStatusResponse extends DriverStatusResponse {
  @override
  final String driverId;
  @override
  final DriverStatusResponseStatusEnum status;
  @override
  final DateTime updatedAt;

  factory _$DriverStatusResponse([
    void Function(DriverStatusResponseBuilder)? updates,
  ]) => (DriverStatusResponseBuilder()..update(updates))._build();

  _$DriverStatusResponse._({
    required this.driverId,
    required this.status,
    required this.updatedAt,
  }) : super._();
  @override
  DriverStatusResponse rebuild(
    void Function(DriverStatusResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DriverStatusResponseBuilder toBuilder() =>
      DriverStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverStatusResponse &&
        driverId == other.driverId &&
        status == other.status &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverStatusResponse')
          ..add('driverId', driverId)
          ..add('status', status)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class DriverStatusResponseBuilder
    implements Builder<DriverStatusResponse, DriverStatusResponseBuilder> {
  _$DriverStatusResponse? _$v;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  DriverStatusResponseStatusEnum? _status;
  DriverStatusResponseStatusEnum? get status => _$this._status;
  set status(DriverStatusResponseStatusEnum? status) => _$this._status = status;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DriverStatusResponseBuilder() {
    DriverStatusResponse._defaults(this);
  }

  DriverStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _driverId = $v.driverId;
      _status = $v.status;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverStatusResponse other) {
    _$v = other as _$DriverStatusResponse;
  }

  @override
  void update(void Function(DriverStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverStatusResponse build() => _build();

  _$DriverStatusResponse _build() {
    final _$result =
        _$v ??
        _$DriverStatusResponse._(
          driverId: BuiltValueNullFieldError.checkNotNull(
            driverId,
            r'DriverStatusResponse',
            'driverId',
          ),
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'DriverStatusResponse',
            'status',
          ),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
            updatedAt,
            r'DriverStatusResponse',
            'updatedAt',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
