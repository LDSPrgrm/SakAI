//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_export_report200_response.g.dart';

/// AdminExportReport200Response
///
/// Properties:
/// * [url] 
/// * [data] 
@BuiltValue()
abstract class AdminExportReport200Response implements Built<AdminExportReport200Response, AdminExportReport200ResponseBuilder> {
  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'data')
  String get data;

  AdminExportReport200Response._();

  factory AdminExportReport200Response([void updates(AdminExportReport200ResponseBuilder b)]) = _$AdminExportReport200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminExportReport200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminExportReport200Response> get serializer => _$AdminExportReport200ResponseSerializer();
}

class _$AdminExportReport200ResponseSerializer implements PrimitiveSerializer<AdminExportReport200Response> {
  @override
  final Iterable<Type> types = const [AdminExportReport200Response, _$AdminExportReport200Response];

  @override
  final String wireName = r'AdminExportReport200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminExportReport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminExportReport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminExportReport200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.data = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminExportReport200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminExportReport200ResponseBuilder();
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

