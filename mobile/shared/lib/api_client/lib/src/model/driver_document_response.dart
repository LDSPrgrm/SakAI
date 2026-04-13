// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/date.dart';
import 'package:sakai_api_client/src/model/upload_status.dart';
import 'package:sakai_api_client/src/model/document_type.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'driver_document_response.g.dart';

/// DriverDocumentResponse
///
/// Properties:
/// * [id] 
/// * [driverId] 
/// * [documentType] 
/// * [documentNumber] - Document identifier (license
/// * [imageUrl] - URL of uploaded document image
/// * [expiryDate] - Document expiration date
/// * [uploadStatus] 
/// * [rejectionReason] 
/// * [uploadedAt] 
/// * [reviewedAt] 
@BuiltValue()
abstract class DriverDocumentResponse implements Built<DriverDocumentResponse, DriverDocumentResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'driverId')
  String get driverId;

  @BuiltValueField(wireName: r'documentType')
  DocumentType get documentType;
  // enum documentTypeEnum {  license,  registration,  insurance,  };

  /// Document identifier (license
  @BuiltValueField(wireName: r'documentNumber')
  String get documentNumber;

  /// URL of uploaded document image
  @BuiltValueField(wireName: r'imageUrl')
  String get imageUrl;

  /// Document expiration date
  @BuiltValueField(wireName: r'expiryDate')
  Date? get expiryDate;

  @BuiltValueField(wireName: r'uploadStatus')
  UploadStatus get uploadStatus;
  // enum uploadStatusEnum {  uploaded,  under_review,  approved,  rejected,  };

  @BuiltValueField(wireName: r'rejectionReason')
  String? get rejectionReason;

  @BuiltValueField(wireName: r'uploadedAt')
  DateTime get uploadedAt;

  @BuiltValueField(wireName: r'reviewedAt')
  DateTime? get reviewedAt;

  DriverDocumentResponse._();

  factory DriverDocumentResponse([void updates(DriverDocumentResponseBuilder b)]) = _$DriverDocumentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DriverDocumentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DriverDocumentResponse> get serializer => _$DriverDocumentResponseSerializer();
}

class _$DriverDocumentResponseSerializer implements PrimitiveSerializer<DriverDocumentResponse> {
  @override
  final Iterable<Type> types = const [DriverDocumentResponse, _$DriverDocumentResponse];

  @override
  final String wireName = r'DriverDocumentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DriverDocumentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'driverId';
    yield serializers.serialize(
      object.driverId,
      specifiedType: const FullType(String),
    );
    yield r'documentType';
    yield serializers.serialize(
      object.documentType,
      specifiedType: const FullType(DocumentType),
    );
    yield r'documentNumber';
    yield serializers.serialize(
      object.documentNumber,
      specifiedType: const FullType(String),
    );
    yield r'imageUrl';
    yield serializers.serialize(
      object.imageUrl,
      specifiedType: const FullType(String),
    );
    if (object.expiryDate != null) {
      yield r'expiryDate';
      yield serializers.serialize(
        object.expiryDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
    yield r'uploadStatus';
    yield serializers.serialize(
      object.uploadStatus,
      specifiedType: const FullType(UploadStatus),
    );
    if (object.rejectionReason != null) {
      yield r'rejectionReason';
      yield serializers.serialize(
        object.rejectionReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'uploadedAt';
    yield serializers.serialize(
      object.uploadedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.reviewedAt != null) {
      yield r'reviewedAt';
      yield serializers.serialize(
        object.reviewedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DriverDocumentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DriverDocumentResponseBuilder result,
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
        case r'driverId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.driverId = valueDes;
          break;
        case r'documentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DocumentType),
          ) as DocumentType;
          result.documentType = valueDes;
          break;
        case r'documentNumber':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.documentNumber = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
          break;
        case r'expiryDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.expiryDate = valueDes;
          break;
        case r'uploadStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UploadStatus),
          ) as UploadStatus;
          result.uploadStatus = valueDes;
          break;
        case r'rejectionReason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rejectionReason = valueDes;
          break;
        case r'uploadedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.uploadedAt = valueDes;
          break;
        case r'reviewedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.reviewedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DriverDocumentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DriverDocumentResponseBuilder();
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

