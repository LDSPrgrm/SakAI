// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lgu_partnership.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LGUPartnershipStatusEnum _$lGUPartnershipStatusEnum_active =
    const LGUPartnershipStatusEnum._('active');
const LGUPartnershipStatusEnum _$lGUPartnershipStatusEnum_pending =
    const LGUPartnershipStatusEnum._('pending');
const LGUPartnershipStatusEnum _$lGUPartnershipStatusEnum_expired =
    const LGUPartnershipStatusEnum._('expired');
const LGUPartnershipStatusEnum _$lGUPartnershipStatusEnum_terminated =
    const LGUPartnershipStatusEnum._('terminated');

LGUPartnershipStatusEnum _$lGUPartnershipStatusEnumValueOf(String name) {
  switch (name) {
    case 'active':
      return _$lGUPartnershipStatusEnum_active;
    case 'pending':
      return _$lGUPartnershipStatusEnum_pending;
    case 'expired':
      return _$lGUPartnershipStatusEnum_expired;
    case 'terminated':
      return _$lGUPartnershipStatusEnum_terminated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LGUPartnershipStatusEnum> _$lGUPartnershipStatusEnumValues =
    BuiltSet<LGUPartnershipStatusEnum>(const <LGUPartnershipStatusEnum>[
      _$lGUPartnershipStatusEnum_active,
      _$lGUPartnershipStatusEnum_pending,
      _$lGUPartnershipStatusEnum_expired,
      _$lGUPartnershipStatusEnum_terminated,
    ]);

Serializer<LGUPartnershipStatusEnum> _$lGUPartnershipStatusEnumSerializer =
    _$LGUPartnershipStatusEnumSerializer();

class _$LGUPartnershipStatusEnumSerializer
    implements PrimitiveSerializer<LGUPartnershipStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'pending': 'pending',
    'expired': 'expired',
    'terminated': 'terminated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'pending': 'pending',
    'expired': 'expired',
    'terminated': 'terminated',
  };

  @override
  final Iterable<Type> types = const <Type>[LGUPartnershipStatusEnum];
  @override
  final String wireName = 'LGUPartnershipStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    LGUPartnershipStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  LGUPartnershipStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => LGUPartnershipStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$LGUPartnership extends LGUPartnership {
  @override
  final String id;
  @override
  final String? serviceAreaId;
  @override
  final String lguName;
  @override
  final String? contactName;
  @override
  final String? contactEmail;
  @override
  final String? contactPhone;
  @override
  final Date? agreementStart;
  @override
  final Date? agreementEnd;
  @override
  final LGUPartnershipStatusEnum status;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  factory _$LGUPartnership([void Function(LGUPartnershipBuilder)? updates]) =>
      (LGUPartnershipBuilder()..update(updates))._build();

  _$LGUPartnership._({
    required this.id,
    this.serviceAreaId,
    required this.lguName,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.agreementStart,
    this.agreementEnd,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  }) : super._();
  @override
  LGUPartnership rebuild(void Function(LGUPartnershipBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LGUPartnershipBuilder toBuilder() => LGUPartnershipBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LGUPartnership &&
        id == other.id &&
        serviceAreaId == other.serviceAreaId &&
        lguName == other.lguName &&
        contactName == other.contactName &&
        contactEmail == other.contactEmail &&
        contactPhone == other.contactPhone &&
        agreementStart == other.agreementStart &&
        agreementEnd == other.agreementEnd &&
        status == other.status &&
        notes == other.notes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, serviceAreaId.hashCode);
    _$hash = $jc(_$hash, lguName.hashCode);
    _$hash = $jc(_$hash, contactName.hashCode);
    _$hash = $jc(_$hash, contactEmail.hashCode);
    _$hash = $jc(_$hash, contactPhone.hashCode);
    _$hash = $jc(_$hash, agreementStart.hashCode);
    _$hash = $jc(_$hash, agreementEnd.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LGUPartnership')
          ..add('id', id)
          ..add('serviceAreaId', serviceAreaId)
          ..add('lguName', lguName)
          ..add('contactName', contactName)
          ..add('contactEmail', contactEmail)
          ..add('contactPhone', contactPhone)
          ..add('agreementStart', agreementStart)
          ..add('agreementEnd', agreementEnd)
          ..add('status', status)
          ..add('notes', notes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class LGUPartnershipBuilder
    implements Builder<LGUPartnership, LGUPartnershipBuilder> {
  _$LGUPartnership? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _serviceAreaId;
  String? get serviceAreaId => _$this._serviceAreaId;
  set serviceAreaId(String? serviceAreaId) =>
      _$this._serviceAreaId = serviceAreaId;

  String? _lguName;
  String? get lguName => _$this._lguName;
  set lguName(String? lguName) => _$this._lguName = lguName;

  String? _contactName;
  String? get contactName => _$this._contactName;
  set contactName(String? contactName) => _$this._contactName = contactName;

  String? _contactEmail;
  String? get contactEmail => _$this._contactEmail;
  set contactEmail(String? contactEmail) => _$this._contactEmail = contactEmail;

  String? _contactPhone;
  String? get contactPhone => _$this._contactPhone;
  set contactPhone(String? contactPhone) => _$this._contactPhone = contactPhone;

  Date? _agreementStart;
  Date? get agreementStart => _$this._agreementStart;
  set agreementStart(Date? agreementStart) =>
      _$this._agreementStart = agreementStart;

  Date? _agreementEnd;
  Date? get agreementEnd => _$this._agreementEnd;
  set agreementEnd(Date? agreementEnd) => _$this._agreementEnd = agreementEnd;

  LGUPartnershipStatusEnum? _status;
  LGUPartnershipStatusEnum? get status => _$this._status;
  set status(LGUPartnershipStatusEnum? status) => _$this._status = status;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  LGUPartnershipBuilder() {
    LGUPartnership._defaults(this);
  }

  LGUPartnershipBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _serviceAreaId = $v.serviceAreaId;
      _lguName = $v.lguName;
      _contactName = $v.contactName;
      _contactEmail = $v.contactEmail;
      _contactPhone = $v.contactPhone;
      _agreementStart = $v.agreementStart;
      _agreementEnd = $v.agreementEnd;
      _status = $v.status;
      _notes = $v.notes;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LGUPartnership other) {
    _$v = other as _$LGUPartnership;
  }

  @override
  void update(void Function(LGUPartnershipBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LGUPartnership build() => _build();

  _$LGUPartnership _build() {
    final _$result =
        _$v ??
        _$LGUPartnership._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'LGUPartnership',
            'id',
          ),
          serviceAreaId: serviceAreaId,
          lguName: BuiltValueNullFieldError.checkNotNull(
            lguName,
            r'LGUPartnership',
            'lguName',
          ),
          contactName: contactName,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          agreementStart: agreementStart,
          agreementEnd: agreementEnd,
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'LGUPartnership',
            'status',
          ),
          notes: notes,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
