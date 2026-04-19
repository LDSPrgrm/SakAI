// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'incident_resolve_request.g.dart';

/// IncidentResolveRequest
///
/// Properties:
/// * [notes] 
@BuiltValue()
abstract class IncidentResolveRequest implements Built<IncidentResolveRequest, IncidentResolveRequestBuilder> {
  @BuiltValueField(wireName: r'notes')
  String get notes;

  IncidentResolveRequest._();

  factory IncidentResolveRequest([void updates(IncidentResolveRequestBuilder b)]) = _$IncidentResolveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IncidentResolveRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<IncidentResolveRequest> get serializer => _$IncidentResolveRequestSerializer();
}

class _$IncidentResolveRequestSerializer implements PrimitiveSerializer<IncidentResolveRequest> {
  @override
  final Iterable<Type> types = const [IncidentResolveRequest, _$IncidentResolveRequest];

  @override
  final String wireName = r'IncidentResolveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    IncidentResolveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'notes';
    yield serializers.serialize(
      object.notes,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    IncidentResolveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IncidentResolveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  IncidentResolveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IncidentResolveRequestBuilder();
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

