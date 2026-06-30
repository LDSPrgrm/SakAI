// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'saved_place_create_request.g.dart';

/// SavedPlaceCreateRequest
///
/// Properties:
/// * [name] 
/// * [address] 
/// * [latitude] 
/// * [longitude] 
/// * [type] 
@BuiltValue()
abstract class SavedPlaceCreateRequest implements Built<SavedPlaceCreateRequest, SavedPlaceCreateRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'address')
  String get address;

  @BuiltValueField(wireName: r'latitude')
  double get latitude;

  @BuiltValueField(wireName: r'longitude')
  double get longitude;

  @BuiltValueField(wireName: r'type')
  SavedPlaceCreateRequestTypeEnum? get type;
  // enum typeEnum {  home,  work,  other,  };

  SavedPlaceCreateRequest._();

  factory SavedPlaceCreateRequest([void updates(SavedPlaceCreateRequestBuilder b)]) = _$SavedPlaceCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SavedPlaceCreateRequestBuilder b) => b
      ..type = SavedPlaceCreateRequestTypeEnum.valueOf('other');

  @BuiltValueSerializer(custom: true)
  static Serializer<SavedPlaceCreateRequest> get serializer => _$SavedPlaceCreateRequestSerializer();
}

class _$SavedPlaceCreateRequestSerializer implements PrimitiveSerializer<SavedPlaceCreateRequest> {
  @override
  final Iterable<Type> types = const [SavedPlaceCreateRequest, _$SavedPlaceCreateRequest];

  @override
  final String wireName = r'SavedPlaceCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SavedPlaceCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'address';
    yield serializers.serialize(
      object.address,
      specifiedType: const FullType(String),
    );
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(double),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(double),
    );
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(SavedPlaceCreateRequestTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SavedPlaceCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SavedPlaceCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'address':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.address = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.longitude = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SavedPlaceCreateRequestTypeEnum),
          ) as SavedPlaceCreateRequestTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SavedPlaceCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SavedPlaceCreateRequestBuilder();
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

class SavedPlaceCreateRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'home')
  static const SavedPlaceCreateRequestTypeEnum home = _$savedPlaceCreateRequestTypeEnum_home;
  @BuiltValueEnumConst(wireName: r'work')
  static const SavedPlaceCreateRequestTypeEnum work = _$savedPlaceCreateRequestTypeEnum_work;
  @BuiltValueEnumConst(wireName: r'other')
  static const SavedPlaceCreateRequestTypeEnum other = _$savedPlaceCreateRequestTypeEnum_other;

  static Serializer<SavedPlaceCreateRequestTypeEnum> get serializer => _$savedPlaceCreateRequestTypeEnumSerializer;

  const SavedPlaceCreateRequestTypeEnum._(String name): super(name);

  static BuiltSet<SavedPlaceCreateRequestTypeEnum> get values => _$savedPlaceCreateRequestTypeEnumValues;
  static SavedPlaceCreateRequestTypeEnum valueOf(String name) => _$savedPlaceCreateRequestTypeEnumValueOf(name);
}

