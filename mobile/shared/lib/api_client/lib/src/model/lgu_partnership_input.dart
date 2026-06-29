// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lgu_partnership_input.g.dart';

/// LGUPartnershipInput
///
/// Properties:
/// * [serviceAreaId] 
/// * [lguName] 
/// * [contactName] 
/// * [contactEmail] 
/// * [contactPhone] 
/// * [agreementStart] 
/// * [agreementEnd] 
/// * [status] 
/// * [notes] 
@BuiltValue()
abstract class LGUPartnershipInput implements Built<LGUPartnershipInput, LGUPartnershipInputBuilder> {
  @BuiltValueField(wireName: r'service_area_id')
  String? get serviceAreaId;

  @BuiltValueField(wireName: r'lgu_name')
  String get lguName;

  @BuiltValueField(wireName: r'contact_name')
  String? get contactName;

  @BuiltValueField(wireName: r'contact_email')
  String? get contactEmail;

  @BuiltValueField(wireName: r'contact_phone')
  String? get contactPhone;

  @BuiltValueField(wireName: r'agreement_start')
  Date? get agreementStart;

  @BuiltValueField(wireName: r'agreement_end')
  Date? get agreementEnd;

  @BuiltValueField(wireName: r'status')
  LGUPartnershipInputStatusEnum? get status;
  // enum statusEnum {  active,  pending,  expired,  terminated,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  LGUPartnershipInput._();

  factory LGUPartnershipInput([void updates(LGUPartnershipInputBuilder b)]) = _$LGUPartnershipInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LGUPartnershipInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LGUPartnershipInput> get serializer => _$LGUPartnershipInputSerializer();
}

class _$LGUPartnershipInputSerializer implements PrimitiveSerializer<LGUPartnershipInput> {
  @override
  final Iterable<Type> types = const [LGUPartnershipInput, _$LGUPartnershipInput];

  @override
  final String wireName = r'LGUPartnershipInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LGUPartnershipInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.serviceAreaId != null) {
      yield r'service_area_id';
      yield serializers.serialize(
        object.serviceAreaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'lgu_name';
    yield serializers.serialize(
      object.lguName,
      specifiedType: const FullType(String),
    );
    if (object.contactName != null) {
      yield r'contact_name';
      yield serializers.serialize(
        object.contactName,
        specifiedType: const FullType(String),
      );
    }
    if (object.contactEmail != null) {
      yield r'contact_email';
      yield serializers.serialize(
        object.contactEmail,
        specifiedType: const FullType(String),
      );
    }
    if (object.contactPhone != null) {
      yield r'contact_phone';
      yield serializers.serialize(
        object.contactPhone,
        specifiedType: const FullType(String),
      );
    }
    if (object.agreementStart != null) {
      yield r'agreement_start';
      yield serializers.serialize(
        object.agreementStart,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.agreementEnd != null) {
      yield r'agreement_end';
      yield serializers.serialize(
        object.agreementEnd,
        specifiedType: const FullType.nullable(Date),
      );
    }
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(LGUPartnershipInputStatusEnum),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LGUPartnershipInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LGUPartnershipInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'service_area_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serviceAreaId = valueDes;
          break;
        case r'lgu_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lguName = valueDes;
          break;
        case r'contact_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contactName = valueDes;
          break;
        case r'contact_email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contactEmail = valueDes;
          break;
        case r'contact_phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contactPhone = valueDes;
          break;
        case r'agreement_start':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.agreementStart = valueDes;
          break;
        case r'agreement_end':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.agreementEnd = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LGUPartnershipInputStatusEnum),
          ) as LGUPartnershipInputStatusEnum;
          result.status = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LGUPartnershipInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LGUPartnershipInputBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class LGUPartnershipInputStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const LGUPartnershipInputStatusEnum active = _$lGUPartnershipInputStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'pending')
  static const LGUPartnershipInputStatusEnum pending = _$lGUPartnershipInputStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'expired')
  static const LGUPartnershipInputStatusEnum expired = _$lGUPartnershipInputStatusEnum_expired;
  @BuiltValueEnumConst(wireName: r'terminated')
  static const LGUPartnershipInputStatusEnum terminated = _$lGUPartnershipInputStatusEnum_terminated;

  static Serializer<LGUPartnershipInputStatusEnum> get serializer => _$lGUPartnershipInputStatusEnumSerializer;

  const LGUPartnershipInputStatusEnum._(String name): super(name);

  static BuiltSet<LGUPartnershipInputStatusEnum> get values => _$lGUPartnershipInputStatusEnumValues;
  static LGUPartnershipInputStatusEnum valueOf(String name) => _$lGUPartnershipInputStatusEnumValueOf(name);
}

