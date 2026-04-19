// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UploadStatus _$uploaded = const UploadStatus._('uploaded');
const UploadStatus _$underReview = const UploadStatus._('underReview');
const UploadStatus _$approved = const UploadStatus._('approved');
const UploadStatus _$rejected = const UploadStatus._('rejected');

UploadStatus _$valueOf(String name) {
  switch (name) {
    case 'uploaded':
      return _$uploaded;
    case 'underReview':
      return _$underReview;
    case 'approved':
      return _$approved;
    case 'rejected':
      return _$rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UploadStatus> _$values = BuiltSet<UploadStatus>(
  const <UploadStatus>[_$uploaded, _$underReview, _$approved, _$rejected],
);

Serializer<UploadStatus> _$uploadStatusSerializer = _$UploadStatusSerializer();

class _$UploadStatusSerializer implements PrimitiveSerializer<UploadStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'uploaded': 'uploaded',
    'underReview': 'under_review',
    'approved': 'approved',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'uploaded': 'uploaded',
    'under_review': 'underReview',
    'approved': 'approved',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[UploadStatus];
  @override
  final String wireName = 'UploadStatus';

  @override
  Object serialize(
    Serializers serializers,
    UploadStatus object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  UploadStatus deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => UploadStatus.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
