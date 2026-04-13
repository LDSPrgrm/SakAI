//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'document_type.g.dart';

class DocumentType extends EnumClass {
  /// Type of driver verification document
  @BuiltValueEnumConst(wireName: r'license')
  static const DocumentType license = _$license;

  /// Type of driver verification document
  @BuiltValueEnumConst(wireName: r'registration')
  static const DocumentType registration = _$registration;

  /// Type of driver verification document
  @BuiltValueEnumConst(wireName: r'insurance')
  static const DocumentType insurance = _$insurance;

  static Serializer<DocumentType> get serializer => _$documentTypeSerializer;

  const DocumentType._(String name) : super(name);

  static BuiltSet<DocumentType> get values => _$values;
  static DocumentType valueOf(String name) => _$valueOf(name);
}
