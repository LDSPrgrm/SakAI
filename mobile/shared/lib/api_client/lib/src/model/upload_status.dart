//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_status.g.dart';

class UploadStatus extends EnumClass {

  /// Current status of document verification
  @BuiltValueEnumConst(wireName: r'uploaded')
  static const UploadStatus uploaded = _$uploaded;
  /// Current status of document verification
  @BuiltValueEnumConst(wireName: r'under_review')
  static const UploadStatus underReview = _$underReview;
  /// Current status of document verification
  @BuiltValueEnumConst(wireName: r'approved')
  static const UploadStatus approved = _$approved;
  /// Current status of document verification
  @BuiltValueEnumConst(wireName: r'rejected')
  static const UploadStatus rejected = _$rejected;

  static Serializer<UploadStatus> get serializer => _$uploadStatusSerializer;

  const UploadStatus._(String name): super(name);

  static BuiltSet<UploadStatus> get values => _$values;
  static UploadStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class UploadStatusMixin = Object with _$UploadStatusMixin;

