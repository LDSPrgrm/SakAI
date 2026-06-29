// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'kyc_document.g.dart';

/// KycDocument
///
/// Properties:
/// * [type] - Machine-readable document type (e.g. drivers_license, vehicle_registration, insurance).
/// * [label] - Human-readable name displayed in the UI.
/// * [url] - Signed URL to the uploaded image/PDF. Absent when not yet uploaded.
@BuiltValue()
abstract class KycDocument implements Built<KycDocument, KycDocumentBuilder> {
  /// Machine-readable document type (e.g. drivers_license, vehicle_registration, insurance).
  @BuiltValueField(wireName: r'type')
  String? get type;

  /// Human-readable name displayed in the UI.
  @BuiltValueField(wireName: r'label')
  String? get label;

  /// Signed URL to the uploaded image/PDF. Absent when not yet uploaded.
  @BuiltValueField(wireName: r'url')
  String? get url;

  KycDocument._();

  factory KycDocument([void updates(KycDocumentBuilder b)]) = _$KycDocument;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KycDocumentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KycDocument> get serializer => _$KycDocumentSerializer();
}

class _$KycDocumentSerializer implements PrimitiveSerializer<KycDocument> {
  @override
  final Iterable<Type> types = const [KycDocument, _$KycDocument];

  @override
  final String wireName = r'KycDocument';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KycDocument object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(String),
      );
    }
    if (object.label != null) {
      yield r'label';
      yield serializers.serialize(
        object.label,
        specifiedType: const FullType(String),
      );
    }
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    KycDocument object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required KycDocumentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  KycDocument deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KycDocumentBuilder();
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

