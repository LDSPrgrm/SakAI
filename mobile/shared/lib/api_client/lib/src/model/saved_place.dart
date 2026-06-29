// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'saved_place.g.dart';

/// SavedPlace
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [address] 
/// * [latitude] 
/// * [longitude] 
/// * [type] 
/// * [createdAt] 
@BuiltValue()
abstract class SavedPlace implements Built<SavedPlace, SavedPlaceBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'address')
  String get address;

  @BuiltValueField(wireName: r'latitude')
  double get latitude;

  @BuiltValueField(wireName: r'longitude')
  double get longitude;

  @BuiltValueField(wireName: r'type')
  SavedPlaceTypeEnum? get type;
  // enum typeEnum {  home,  work,  other,  };

  @BuiltValueField(wireName: r'createdAt')
  DateTime? get createdAt;

  SavedPlace._();

  factory SavedPlace([void updates(SavedPlaceBuilder b)]) = _$SavedPlace;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SavedPlaceBuilder b) => b
      ..type = SavedPlaceTypeEnum.valueOf('other');

  @BuiltValueSerializer(custom: true)
  static Serializer<SavedPlace> get serializer => _$SavedPlaceSerializer();
}

class _$SavedPlaceSerializer implements PrimitiveSerializer<SavedPlace> {
  @override
  final Iterable<Type> types = const [SavedPlace, _$SavedPlace];

  @override
  final String wireName = r'SavedPlace';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SavedPlace object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
        specifiedType: const FullType(SavedPlaceTypeEnum),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SavedPlace object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SavedPlaceBuilder result,
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
            specifiedType: const FullType(SavedPlaceTypeEnum),
          ) as SavedPlaceTypeEnum;
          result.type = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SavedPlace deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SavedPlaceBuilder();
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

class SavedPlaceTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'home')
  static const SavedPlaceTypeEnum home = _$savedPlaceTypeEnum_home;
  @BuiltValueEnumConst(wireName: r'work')
  static const SavedPlaceTypeEnum work = _$savedPlaceTypeEnum_work;
  @BuiltValueEnumConst(wireName: r'other')
  static const SavedPlaceTypeEnum other = _$savedPlaceTypeEnum_other;

  static Serializer<SavedPlaceTypeEnum> get serializer => _$savedPlaceTypeEnumSerializer;

  const SavedPlaceTypeEnum._(String name): super(name);

  static BuiltSet<SavedPlaceTypeEnum> get values => _$savedPlaceTypeEnumValues;
  static SavedPlaceTypeEnum valueOf(String name) => _$savedPlaceTypeEnumValueOf(name);
}

