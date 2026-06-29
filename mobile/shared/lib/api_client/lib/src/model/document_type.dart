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

  const DocumentType._(String name): super(name);

  static BuiltSet<DocumentType> get values => _$values;
  static DocumentType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class DocumentTypeMixin = Object with _$DocumentTypeMixin;

