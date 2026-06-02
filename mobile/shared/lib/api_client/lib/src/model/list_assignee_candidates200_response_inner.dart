// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_assignee_candidates200_response_inner.g.dart';

/// ListAssigneeCandidates200ResponseInner
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [role] - Admin role slug (e.g. superadmin, support, operations).
@BuiltValue()
abstract class ListAssigneeCandidates200ResponseInner implements Built<ListAssigneeCandidates200ResponseInner, ListAssigneeCandidates200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Admin role slug (e.g. superadmin, support, operations).
  @BuiltValueField(wireName: r'role')
  String get role;

  ListAssigneeCandidates200ResponseInner._();

  factory ListAssigneeCandidates200ResponseInner([void updates(ListAssigneeCandidates200ResponseInnerBuilder b)]) = _$ListAssigneeCandidates200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListAssigneeCandidates200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAssigneeCandidates200ResponseInner> get serializer => _$ListAssigneeCandidates200ResponseInnerSerializer();
}

class _$ListAssigneeCandidates200ResponseInnerSerializer implements PrimitiveSerializer<ListAssigneeCandidates200ResponseInner> {
  @override
  final Iterable<Type> types = const [ListAssigneeCandidates200ResponseInner, _$ListAssigneeCandidates200ResponseInner];

  @override
  final String wireName = r'ListAssigneeCandidates200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAssigneeCandidates200ResponseInner object, {
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
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListAssigneeCandidates200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListAssigneeCandidates200ResponseInnerBuilder result,
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
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListAssigneeCandidates200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAssigneeCandidates200ResponseInnerBuilder();
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

