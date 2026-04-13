// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KycBatchRequestStatusEnum _$kycBatchRequestStatusEnum_approved =
    const KycBatchRequestStatusEnum._('approved');
const KycBatchRequestStatusEnum _$kycBatchRequestStatusEnum_rejected =
    const KycBatchRequestStatusEnum._('rejected');

KycBatchRequestStatusEnum _$kycBatchRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'approved':
      return _$kycBatchRequestStatusEnum_approved;
    case 'rejected':
      return _$kycBatchRequestStatusEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KycBatchRequestStatusEnum> _$kycBatchRequestStatusEnumValues =
    BuiltSet<KycBatchRequestStatusEnum>(const <KycBatchRequestStatusEnum>[
  _$kycBatchRequestStatusEnum_approved,
  _$kycBatchRequestStatusEnum_rejected,
]);

Serializer<KycBatchRequestStatusEnum> _$kycBatchRequestStatusEnumSerializer =
    _$KycBatchRequestStatusEnumSerializer();

class _$KycBatchRequestStatusEnumSerializer
    implements PrimitiveSerializer<KycBatchRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'approved': 'approved',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'approved': 'approved',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[KycBatchRequestStatusEnum];
  @override
  final String wireName = 'KycBatchRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, KycBatchRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  KycBatchRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      KycBatchRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$KycBatchRequest extends KycBatchRequest {
  @override
  final BuiltList<String> ids;
  @override
  final KycBatchRequestStatusEnum status;

  factory _$KycBatchRequest([void Function(KycBatchRequestBuilder)? updates]) =>
      (KycBatchRequestBuilder()..update(updates))._build();

  _$KycBatchRequest._({required this.ids, required this.status}) : super._();
  @override
  KycBatchRequest rebuild(void Function(KycBatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KycBatchRequestBuilder toBuilder() => KycBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KycBatchRequest &&
        ids == other.ids &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KycBatchRequest')
          ..add('ids', ids)
          ..add('status', status))
        .toString();
  }
}

class KycBatchRequestBuilder
    implements Builder<KycBatchRequest, KycBatchRequestBuilder> {
  _$KycBatchRequest? _$v;

  ListBuilder<String>? _ids;
  ListBuilder<String> get ids => _$this._ids ??= ListBuilder<String>();
  set ids(ListBuilder<String>? ids) => _$this._ids = ids;

  KycBatchRequestStatusEnum? _status;
  KycBatchRequestStatusEnum? get status => _$this._status;
  set status(KycBatchRequestStatusEnum? status) => _$this._status = status;

  KycBatchRequestBuilder() {
    KycBatchRequest._defaults(this);
  }

  KycBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ids = $v.ids.toBuilder();
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KycBatchRequest other) {
    _$v = other as _$KycBatchRequest;
  }

  @override
  void update(void Function(KycBatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KycBatchRequest build() => _build();

  _$KycBatchRequest _build() {
    _$KycBatchRequest _$result;
    try {
      _$result = _$v ??
          _$KycBatchRequest._(
            ids: ids.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'KycBatchRequest', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        ids.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'KycBatchRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
