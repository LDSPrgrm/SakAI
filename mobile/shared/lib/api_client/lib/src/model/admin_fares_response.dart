//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/fare_config.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sakai_api_client/src/model/surge_config.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_fares_response.g.dart';

/// AdminFaresResponse
///
/// Properties:
/// * [fares] 
/// * [surge] 
@BuiltValue()
abstract class AdminFaresResponse implements Built<AdminFaresResponse, AdminFaresResponseBuilder> {
  @BuiltValueField(wireName: r'fares')
  BuiltList<FareConfig>? get fares;

  @BuiltValueField(wireName: r'surge')
  SurgeConfig? get surge;

  AdminFaresResponse._();

  factory AdminFaresResponse([void updates(AdminFaresResponseBuilder b)]) = _$AdminFaresResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminFaresResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminFaresResponse> get serializer => _$AdminFaresResponseSerializer();
}

class _$AdminFaresResponseSerializer implements PrimitiveSerializer<AdminFaresResponse> {
  @override
  final Iterable<Type> types = const [AdminFaresResponse, _$AdminFaresResponse];

  @override
  final String wireName = r'AdminFaresResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminFaresResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.fares != null) {
      yield r'fares';
      yield serializers.serialize(
        object.fares,
        specifiedType: const FullType(BuiltList, [FullType(FareConfig)]),
      );
    }
    if (object.surge != null) {
      yield r'surge';
      yield serializers.serialize(
        object.surge,
        specifiedType: const FullType(SurgeConfig),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminFaresResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminFaresResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fares':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FareConfig)]),
          ) as BuiltList<FareConfig>;
          result.fares.replace(valueDes);
          break;
        case r'surge':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SurgeConfig),
          ) as SurgeConfig;
          result.surge.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminFaresResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminFaresResponseBuilder();
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

