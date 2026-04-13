// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnum_driverTooFar =
    const CancelRequestReasonCodeEnum._('driverTooFar');
const CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnum_changedPlans =
    const CancelRequestReasonCodeEnum._('changedPlans');
const CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnum_wrongPickup =
    const CancelRequestReasonCodeEnum._('wrongPickup');
const CancelRequestReasonCodeEnum
    _$cancelRequestReasonCodeEnum_driverNotMoving =
    const CancelRequestReasonCodeEnum._('driverNotMoving');
const CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnum_safetyConcern =
    const CancelRequestReasonCodeEnum._('safetyConcern');
const CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnum_other =
    const CancelRequestReasonCodeEnum._('other');

CancelRequestReasonCodeEnum _$cancelRequestReasonCodeEnumValueOf(String name) {
  switch (name) {
    case 'driverTooFar':
      return _$cancelRequestReasonCodeEnum_driverTooFar;
    case 'changedPlans':
      return _$cancelRequestReasonCodeEnum_changedPlans;
    case 'wrongPickup':
      return _$cancelRequestReasonCodeEnum_wrongPickup;
    case 'driverNotMoving':
      return _$cancelRequestReasonCodeEnum_driverNotMoving;
    case 'safetyConcern':
      return _$cancelRequestReasonCodeEnum_safetyConcern;
    case 'other':
      return _$cancelRequestReasonCodeEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CancelRequestReasonCodeEnum>
    _$cancelRequestReasonCodeEnumValues =
    BuiltSet<CancelRequestReasonCodeEnum>(const <CancelRequestReasonCodeEnum>[
  _$cancelRequestReasonCodeEnum_driverTooFar,
  _$cancelRequestReasonCodeEnum_changedPlans,
  _$cancelRequestReasonCodeEnum_wrongPickup,
  _$cancelRequestReasonCodeEnum_driverNotMoving,
  _$cancelRequestReasonCodeEnum_safetyConcern,
  _$cancelRequestReasonCodeEnum_other,
]);

Serializer<CancelRequestReasonCodeEnum>
    _$cancelRequestReasonCodeEnumSerializer =
    _$CancelRequestReasonCodeEnumSerializer();

class _$CancelRequestReasonCodeEnumSerializer
    implements PrimitiveSerializer<CancelRequestReasonCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'driverTooFar': 'driver_too_far',
    'changedPlans': 'changed_plans',
    'wrongPickup': 'wrong_pickup',
    'driverNotMoving': 'driver_not_moving',
    'safetyConcern': 'safety_concern',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'driver_too_far': 'driverTooFar',
    'changed_plans': 'changedPlans',
    'wrong_pickup': 'wrongPickup',
    'driver_not_moving': 'driverNotMoving',
    'safety_concern': 'safetyConcern',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[CancelRequestReasonCodeEnum];
  @override
  final String wireName = 'CancelRequestReasonCodeEnum';

  @override
  Object serialize(Serializers serializers, CancelRequestReasonCodeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CancelRequestReasonCodeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CancelRequestReasonCodeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CancelRequest extends CancelRequest {
  @override
  final CancelRequestReasonCodeEnum reasonCode;
  @override
  final String? reasonText;

  factory _$CancelRequest([void Function(CancelRequestBuilder)? updates]) =>
      (CancelRequestBuilder()..update(updates))._build();

  _$CancelRequest._({required this.reasonCode, this.reasonText}) : super._();
  @override
  CancelRequest rebuild(void Function(CancelRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CancelRequestBuilder toBuilder() => CancelRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CancelRequest &&
        reasonCode == other.reasonCode &&
        reasonText == other.reasonText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, reasonText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CancelRequest')
          ..add('reasonCode', reasonCode)
          ..add('reasonText', reasonText))
        .toString();
  }
}

class CancelRequestBuilder
    implements Builder<CancelRequest, CancelRequestBuilder> {
  _$CancelRequest? _$v;

  CancelRequestReasonCodeEnum? _reasonCode;
  CancelRequestReasonCodeEnum? get reasonCode => _$this._reasonCode;
  set reasonCode(CancelRequestReasonCodeEnum? reasonCode) =>
      _$this._reasonCode = reasonCode;

  String? _reasonText;
  String? get reasonText => _$this._reasonText;
  set reasonText(String? reasonText) => _$this._reasonText = reasonText;

  CancelRequestBuilder() {
    CancelRequest._defaults(this);
  }

  CancelRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reasonCode = $v.reasonCode;
      _reasonText = $v.reasonText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CancelRequest other) {
    _$v = other as _$CancelRequest;
  }

  @override
  void update(void Function(CancelRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CancelRequest build() => _build();

  _$CancelRequest _build() {
    final _$result = _$v ??
        _$CancelRequest._(
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'CancelRequest', 'reasonCode'),
          reasonText: reasonText,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
