// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_update_kyc_status_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdminUpdateKycStatusRequestStatusEnum
    _$adminUpdateKycStatusRequestStatusEnum_approved =
    const AdminUpdateKycStatusRequestStatusEnum._('approved');
const AdminUpdateKycStatusRequestStatusEnum
    _$adminUpdateKycStatusRequestStatusEnum_rejected =
    const AdminUpdateKycStatusRequestStatusEnum._('rejected');

AdminUpdateKycStatusRequestStatusEnum
    _$adminUpdateKycStatusRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'approved':
      return _$adminUpdateKycStatusRequestStatusEnum_approved;
    case 'rejected':
      return _$adminUpdateKycStatusRequestStatusEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AdminUpdateKycStatusRequestStatusEnum>
    _$adminUpdateKycStatusRequestStatusEnumValues = BuiltSet<
        AdminUpdateKycStatusRequestStatusEnum>(const <AdminUpdateKycStatusRequestStatusEnum>[
  _$adminUpdateKycStatusRequestStatusEnum_approved,
  _$adminUpdateKycStatusRequestStatusEnum_rejected,
]);

Serializer<AdminUpdateKycStatusRequestStatusEnum>
    _$adminUpdateKycStatusRequestStatusEnumSerializer =
    _$AdminUpdateKycStatusRequestStatusEnumSerializer();

class _$AdminUpdateKycStatusRequestStatusEnumSerializer
    implements PrimitiveSerializer<AdminUpdateKycStatusRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'approved': 'approved',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'approved': 'approved',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AdminUpdateKycStatusRequestStatusEnum
  ];
  @override
  final String wireName = 'AdminUpdateKycStatusRequestStatusEnum';

  @override
  Object serialize(
          Serializers serializers, AdminUpdateKycStatusRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdminUpdateKycStatusRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdminUpdateKycStatusRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AdminUpdateKycStatusRequest extends AdminUpdateKycStatusRequest {
  @override
  final AdminUpdateKycStatusRequestStatusEnum status;

  factory _$AdminUpdateKycStatusRequest(
          [void Function(AdminUpdateKycStatusRequestBuilder)? updates]) =>
      (AdminUpdateKycStatusRequestBuilder()..update(updates))._build();

  _$AdminUpdateKycStatusRequest._({required this.status}) : super._();
  @override
  AdminUpdateKycStatusRequest rebuild(
          void Function(AdminUpdateKycStatusRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUpdateKycStatusRequestBuilder toBuilder() =>
      AdminUpdateKycStatusRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUpdateKycStatusRequest && status == other.status;
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
    return (newBuiltValueToStringHelper(r'AdminUpdateKycStatusRequest')
          ..add('status', status))
        .toString();
  }
}

class AdminUpdateKycStatusRequestBuilder
    implements
        Builder<AdminUpdateKycStatusRequest,
            AdminUpdateKycStatusRequestBuilder> {
  _$AdminUpdateKycStatusRequest? _$v;

  AdminUpdateKycStatusRequestStatusEnum? _status;
  AdminUpdateKycStatusRequestStatusEnum? get status => _$this._status;
  set status(AdminUpdateKycStatusRequestStatusEnum? status) =>
      _$this._status = status;

  AdminUpdateKycStatusRequestBuilder() {
    AdminUpdateKycStatusRequest._defaults(this);
  }

  AdminUpdateKycStatusRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUpdateKycStatusRequest other) {
    _$v = other as _$AdminUpdateKycStatusRequest;
  }

  @override
  void update(void Function(AdminUpdateKycStatusRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUpdateKycStatusRequest build() => _build();

  _$AdminUpdateKycStatusRequest _build() {
    final _$result = _$v ??
        _$AdminUpdateKycStatusRequest._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdminUpdateKycStatusRequest', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
