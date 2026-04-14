// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DocumentType _$license = const DocumentType._('license');
const DocumentType _$registration = const DocumentType._('registration');
const DocumentType _$insurance = const DocumentType._('insurance');

DocumentType _$valueOf(String name) {
  switch (name) {
    case 'license':
      return _$license;
    case 'registration':
      return _$registration;
    case 'insurance':
      return _$insurance;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DocumentType> _$values = BuiltSet<DocumentType>(
  const <DocumentType>[_$license, _$registration, _$insurance],
);

Serializer<DocumentType> _$documentTypeSerializer = _$DocumentTypeSerializer();

class _$DocumentTypeSerializer implements PrimitiveSerializer<DocumentType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'license': 'license',
    'registration': 'registration',
    'insurance': 'insurance',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'license': 'license',
    'registration': 'registration',
    'insurance': 'insurance',
  };

  @override
  final Iterable<Type> types = const <Type>[DocumentType];
  @override
  final String wireName = 'DocumentType';

  @override
  Object serialize(
    Serializers serializers,
    DocumentType object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  DocumentType deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => DocumentType.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
