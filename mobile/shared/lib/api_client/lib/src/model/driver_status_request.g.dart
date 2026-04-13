// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_status_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DriverStatusRequestStatusEnum _$driverStatusRequestStatusEnum_online =
    const DriverStatusRequestStatusEnum._('online');
const DriverStatusRequestStatusEnum _$driverStatusRequestStatusEnum_offline =
    const DriverStatusRequestStatusEnum._('offline');

DriverStatusRequestStatusEnum _$driverStatusRequestStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'online':
      return _$driverStatusRequestStatusEnum_online;
    case 'offline':
      return _$driverStatusRequestStatusEnum_offline;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DriverStatusRequestStatusEnum>
    _$driverStatusRequestStatusEnumValues = BuiltSet<
        DriverStatusRequestStatusEnum>(const <DriverStatusRequestStatusEnum>[
  _$driverStatusRequestStatusEnum_online,
  _$driverStatusRequestStatusEnum_offline,
]);

Serializer<DriverStatusRequestStatusEnum>
    _$driverStatusRequestStatusEnumSerializer =
    _$DriverStatusRequestStatusEnumSerializer();

class _$DriverStatusRequestStatusEnumSerializer
    implements PrimitiveSerializer<DriverStatusRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'online': 'online',
    'offline': 'offline',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'online': 'online',
    'offline': 'offline',
  };

  @override
  final Iterable<Type> types = const <Type>[DriverStatusRequestStatusEnum];
  @override
  final String wireName = 'DriverStatusRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, DriverStatusRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DriverStatusRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DriverStatusRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DriverStatusRequest extends DriverStatusRequest {
  @override
  final DriverStatusRequestStatusEnum status;

  factory _$DriverStatusRequest(
          [void Function(DriverStatusRequestBuilder)? updates]) =>
      (DriverStatusRequestBuilder()..update(updates))._build();

  _$DriverStatusRequest._({required this.status}) : super._();
  @override
  DriverStatusRequest rebuild(
          void Function(DriverStatusRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverStatusRequestBuilder toBuilder() =>
      DriverStatusRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverStatusRequest && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverStatusRequest')
          ..add('status', status))
        .toString();
  }
}

class DriverStatusRequestBuilder
    implements Builder<DriverStatusRequest, DriverStatusRequestBuilder> {
  _$DriverStatusRequest? _$v;

  DriverStatusRequestStatusEnum? _status;
  DriverStatusRequestStatusEnum? get status => _$this._status;
  set status(DriverStatusRequestStatusEnum? status) => _$this._status = status;

  DriverStatusRequestBuilder() {
    DriverStatusRequest._defaults(this);
  }

  DriverStatusRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverStatusRequest other) {
    _$v = other as _$DriverStatusRequest;
  }

  @override
  void update(void Function(DriverStatusRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverStatusRequest build() => _build();

  _$DriverStatusRequest _build() {
    final _$result = _$v ??
        _$DriverStatusRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'DriverStatusRequest', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
