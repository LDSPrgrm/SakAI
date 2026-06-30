// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lgu_partnership_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LGUPartnershipInputStatusEnum _$lGUPartnershipInputStatusEnum_active =
    const LGUPartnershipInputStatusEnum._('active');
const LGUPartnershipInputStatusEnum _$lGUPartnershipInputStatusEnum_pending =
    const LGUPartnershipInputStatusEnum._('pending');
const LGUPartnershipInputStatusEnum _$lGUPartnershipInputStatusEnum_expired =
    const LGUPartnershipInputStatusEnum._('expired');
const LGUPartnershipInputStatusEnum _$lGUPartnershipInputStatusEnum_terminated =
    const LGUPartnershipInputStatusEnum._('terminated');

LGUPartnershipInputStatusEnum _$lGUPartnershipInputStatusEnumValueOf(
  String name,
) {
  switch (name) {
    case 'active':
      return _$lGUPartnershipInputStatusEnum_active;
    case 'pending':
      return _$lGUPartnershipInputStatusEnum_pending;
    case 'expired':
      return _$lGUPartnershipInputStatusEnum_expired;
    case 'terminated':
      return _$lGUPartnershipInputStatusEnum_terminated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LGUPartnershipInputStatusEnum>
_$lGUPartnershipInputStatusEnumValues = BuiltSet<LGUPartnershipInputStatusEnum>(
  const <LGUPartnershipInputStatusEnum>[
    _$lGUPartnershipInputStatusEnum_active,
    _$lGUPartnershipInputStatusEnum_pending,
    _$lGUPartnershipInputStatusEnum_expired,
    _$lGUPartnershipInputStatusEnum_terminated,
  ],
);

Serializer<LGUPartnershipInputStatusEnum>
_$lGUPartnershipInputStatusEnumSerializer =
    _$LGUPartnershipInputStatusEnumSerializer();

class _$LGUPartnershipInputStatusEnumSerializer
    implements PrimitiveSerializer<LGUPartnershipInputStatusEnum> {
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
  final Iterable<Type> types = const <Type>[LGUPartnershipInputStatusEnum];
  @override
  final String wireName = 'LGUPartnershipInputStatusEnum';

  @override
  Object serialize(
    Serializers serializers,
    LGUPartnershipInputStatusEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  LGUPartnershipInputStatusEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => LGUPartnershipInputStatusEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$LGUPartnershipInput extends LGUPartnershipInput {
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
  final LGUPartnershipInputStatusEnum? status;
  @override
  final String? notes;

  factory _$LGUPartnershipInput([
    void Function(LGUPartnershipInputBuilder)? updates,
  ]) => (LGUPartnershipInputBuilder()..update(updates))._build();

  _$LGUPartnershipInput._({
    this.serviceAreaId,
    required this.lguName,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.agreementStart,
    this.agreementEnd,
    this.status,
    this.notes,
  }) : super._();
  @override
  LGUPartnershipInput rebuild(
    void Function(LGUPartnershipInputBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  LGUPartnershipInputBuilder toBuilder() =>
      LGUPartnershipInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LGUPartnershipInput &&
        serviceAreaId == other.serviceAreaId &&
        lguName == other.lguName &&
        contactName == other.contactName &&
        contactEmail == other.contactEmail &&
        contactPhone == other.contactPhone &&
        agreementStart == other.agreementStart &&
        agreementEnd == other.agreementEnd &&
        status == other.status &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, serviceAreaId.hashCode);
    _$hash = $jc(_$hash, lguName.hashCode);
    _$hash = $jc(_$hash, contactName.hashCode);
    _$hash = $jc(_$hash, contactEmail.hashCode);
    _$hash = $jc(_$hash, contactPhone.hashCode);
    _$hash = $jc(_$hash, agreementStart.hashCode);
    _$hash = $jc(_$hash, agreementEnd.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LGUPartnershipInput')
          ..add('serviceAreaId', serviceAreaId)
          ..add('lguName', lguName)
          ..add('contactName', contactName)
          ..add('contactEmail', contactEmail)
          ..add('contactPhone', contactPhone)
          ..add('agreementStart', agreementStart)
          ..add('agreementEnd', agreementEnd)
          ..add('status', status)
          ..add('notes', notes))
        .toString();
  }
}

class LGUPartnershipInputBuilder
    implements Builder<LGUPartnershipInput, LGUPartnershipInputBuilder> {
  _$LGUPartnershipInput? _$v;

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

  LGUPartnershipInputStatusEnum? _status;
  LGUPartnershipInputStatusEnum? get status => _$this._status;
  set status(LGUPartnershipInputStatusEnum? status) => _$this._status = status;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  LGUPartnershipInputBuilder() {
    LGUPartnershipInput._defaults(this);
  }

  LGUPartnershipInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _serviceAreaId = $v.serviceAreaId;
      _lguName = $v.lguName;
      _contactName = $v.contactName;
      _contactEmail = $v.contactEmail;
      _contactPhone = $v.contactPhone;
      _agreementStart = $v.agreementStart;
      _agreementEnd = $v.agreementEnd;
      _status = $v.status;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LGUPartnershipInput other) {
    _$v = other as _$LGUPartnershipInput;
  }

  @override
  void update(void Function(LGUPartnershipInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LGUPartnershipInput build() => _build();

  _$LGUPartnershipInput _build() {
    final _$result =
        _$v ??
        _$LGUPartnershipInput._(
          serviceAreaId: serviceAreaId,
          lguName: BuiltValueNullFieldError.checkNotNull(
            lguName,
            r'LGUPartnershipInput',
            'lguName',
          ),
          contactName: contactName,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          agreementStart: agreementStart,
          agreementEnd: agreementEnd,
          status: status,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
