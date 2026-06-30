// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lgu_partnership.g.dart';

/// LGUPartnership
///
/// Properties:
/// * [id] 
/// * [serviceAreaId] 
/// * [lguName] 
/// * [contactName] 
/// * [contactEmail] 
/// * [contactPhone] 
/// * [agreementStart] 
/// * [agreementEnd] 
/// * [status] 
/// * [notes] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class LGUPartnership implements Built<LGUPartnership, LGUPartnershipBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

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
  LGUPartnershipStatusEnum get status;
  // enum statusEnum {  active,  pending,  expired,  terminated,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  LGUPartnership._();

  factory LGUPartnership([void updates(LGUPartnershipBuilder b)]) = _$LGUPartnership;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LGUPartnershipBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LGUPartnership> get serializer => _$LGUPartnershipSerializer();
}

class _$LGUPartnershipSerializer implements PrimitiveSerializer<LGUPartnership> {
  @override
  final Iterable<Type> types = const [LGUPartnership, _$LGUPartnership];

  @override
  final String wireName = r'LGUPartnership';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LGUPartnership object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(LGUPartnershipStatusEnum),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    LGUPartnership object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LGUPartnershipBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
            specifiedType: const FullType(LGUPartnershipStatusEnum),
          ) as LGUPartnershipStatusEnum;
          result.status = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LGUPartnership deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LGUPartnershipBuilder();
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

class LGUPartnershipStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const LGUPartnershipStatusEnum active = _$lGUPartnershipStatusEnum_active;
  @BuiltValueEnumConst(wireName: r'pending')
  static const LGUPartnershipStatusEnum pending = _$lGUPartnershipStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'expired')
  static const LGUPartnershipStatusEnum expired = _$lGUPartnershipStatusEnum_expired;
  @BuiltValueEnumConst(wireName: r'terminated')
  static const LGUPartnershipStatusEnum terminated = _$lGUPartnershipStatusEnum_terminated;

  static Serializer<LGUPartnershipStatusEnum> get serializer => _$lGUPartnershipStatusEnumSerializer;

  const LGUPartnershipStatusEnum._(String name): super(name);

  static BuiltSet<LGUPartnershipStatusEnum> get values => _$lGUPartnershipStatusEnumValues;
  static LGUPartnershipStatusEnum valueOf(String name) => _$lGUPartnershipStatusEnumValueOf(name);
}

