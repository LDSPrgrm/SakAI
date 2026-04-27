// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const KycEntryStatusEnum _$kycEntryStatusEnum_pending =
    const KycEntryStatusEnum._('pending');
const KycEntryStatusEnum _$kycEntryStatusEnum_approved =
    const KycEntryStatusEnum._('approved');
const KycEntryStatusEnum _$kycEntryStatusEnum_rejected =
    const KycEntryStatusEnum._('rejected');
const KycEntryStatusEnum _$kycEntryStatusEnum_needsMoreInfo =
    const KycEntryStatusEnum._('needsMoreInfo');

KycEntryStatusEnum _$kycEntryStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$kycEntryStatusEnum_pending;
    case 'approved':
      return _$kycEntryStatusEnum_approved;
    case 'rejected':
      return _$kycEntryStatusEnum_rejected;
    case 'needsMoreInfo':
      return _$kycEntryStatusEnum_needsMoreInfo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<KycEntryStatusEnum> _$kycEntryStatusEnumValues =
    BuiltSet<KycEntryStatusEnum>(const <KycEntryStatusEnum>[
      _$kycEntryStatusEnum_pending,
      _$kycEntryStatusEnum_approved,
      _$kycEntryStatusEnum_rejected,
      _$kycEntryStatusEnum_needsMoreInfo,
    ]);

Serializer<KycEntryStatusEnum> _$kycEntryStatusEnumSerializer =
    _$KycEntryStatusEnumSerializer();

class _$KycEntryStatusEnumSerializer
    implements PrimitiveSerializer<KycEntryStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
    'needsMoreInfo': 'needs_more_info',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
    'needs_more_info': 'needsMoreInfo',
  };

  @override
  final Iterable<Type> types = const <Type>[KycEntryStatusEnum];
  @override
  final String wireName = 'KycEntryStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    KycEntryStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  KycEntryStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => KycEntryStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$KycEntry extends KycEntry {
  @override
  final String? id;
  @override
  final String? driverId;
  @override
  final String? driverName;
  @override
  final DateTime? submittedAt;
  @override
  final BuiltList<KycDocument>? docs;
  @override
  final KycEntryStatusEnum? status;

  factory _$KycEntry([void Function(KycEntryBuilder)? updates]) =>
      (KycEntryBuilder()..update(updates))._build();

  _$KycEntry._({
    this.id,
    this.driverId,
    this.driverName,
    this.submittedAt,
    this.docs,
    this.status,
  }) : super._();
  @override
  KycEntry rebuild(void Function(KycEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KycEntryBuilder toBuilder() => KycEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KycEntry &&
        id == other.id &&
        driverId == other.driverId &&
        driverName == other.driverName &&
        submittedAt == other.submittedAt &&
        docs == other.docs &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, driverId.hashCode);
    _$hash = $jc(_$hash, driverName.hashCode);
    _$hash = $jc(_$hash, submittedAt.hashCode);
    _$hash = $jc(_$hash, docs.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KycEntry')
          ..add('id', id)
          ..add('driverId', driverId)
          ..add('driverName', driverName)
          ..add('submittedAt', submittedAt)
          ..add('docs', docs)
          ..add('status', status))
        .toString();
  }
}

class KycEntryBuilder implements Builder<KycEntry, KycEntryBuilder> {
  _$KycEntry? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _driverId;
  String? get driverId => _$this._driverId;
  set driverId(String? driverId) => _$this._driverId = driverId;

  String? _driverName;
  String? get driverName => _$this._driverName;
  set driverName(String? driverName) => _$this._driverName = driverName;

  DateTime? _submittedAt;
  DateTime? get submittedAt => _$this._submittedAt;
  set submittedAt(DateTime? submittedAt) => _$this._submittedAt = submittedAt;

  ListBuilder<KycDocument>? _docs;
  ListBuilder<KycDocument> get docs =>
      _$this._docs ??= ListBuilder<KycDocument>();
  set docs(ListBuilder<KycDocument>? docs) => _$this._docs = docs;

  KycEntryStatusEnum? _status;
  KycEntryStatusEnum? get status => _$this._status;
  set status(KycEntryStatusEnum? status) => _$this._status = status;

  KycEntryBuilder() {
    KycEntry._defaults(this);
  }

  KycEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _driverId = $v.driverId;
      _driverName = $v.driverName;
      _submittedAt = $v.submittedAt;
      _docs = $v.docs?.toBuilder();
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KycEntry other) {
    _$v = other as _$KycEntry;
  }

  @override
  void update(void Function(KycEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KycEntry build() => _build();

  _$KycEntry _build() {
    _$KycEntry _$result;
    try {
      _$result =
          _$v ??
          _$KycEntry._(
            id: id,
            driverId: driverId,
            driverName: driverName,
            submittedAt: submittedAt,
            docs: _docs?.build(),
            status: status,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'docs';
        _docs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'KycEntry',
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
