//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sakai_api_client/src/model/role_permission.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'service_area.g.dart';

/// ServiceArea
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [description] 
/// * [isSystem] - True for built-in roles that cannot be deleted
/// * [permissions] 
/// * [adminCount] - Number of active admins with this role
/// * [createdBy] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class ServiceArea implements Built<ServiceArea, ServiceAreaBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  /// True for built-in roles that cannot be deleted
  @BuiltValueField(wireName: r'is_system')
  bool? get isSystem;

  @BuiltValueField(wireName: r'permissions')
  BuiltList<RolePermission>? get permissions;

  /// Number of active admins with this role
  @BuiltValueField(wireName: r'admin_count')
  int? get adminCount;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  ServiceArea._();

  factory ServiceArea([void updates(ServiceAreaBuilder b)]) = _$ServiceArea;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ServiceAreaBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ServiceArea> get serializer => _$ServiceAreaSerializer();
}

class _$ServiceAreaSerializer implements PrimitiveSerializer<ServiceArea> {
  @override
  final Iterable<Type> types = const [ServiceArea, _$ServiceArea];

  @override
  final String wireName = r'ServiceArea';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ServiceArea object, {
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
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.isSystem != null) {
      yield r'is_system';
      yield serializers.serialize(
        object.isSystem,
        specifiedType: const FullType(bool),
      );
    }
    if (object.permissions != null) {
      yield r'permissions';
      yield serializers.serialize(
        object.permissions,
        specifiedType: const FullType(BuiltList, [FullType(RolePermission)]),
      );
    }
    if (object.adminCount != null) {
      yield r'admin_count';
      yield serializers.serialize(
        object.adminCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.createdBy != null) {
      yield r'created_by';
      yield serializers.serialize(
        object.createdBy,
        specifiedType: const FullType(String),
      );
    }
    if (object.createdAt != null) {
      yield r'created_at';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.updatedAt != null) {
      yield r'updated_at';
      yield serializers.serialize(
        object.updatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ServiceArea object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ServiceAreaBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'is_system':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSystem = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RolePermission)]),
          ) as BuiltList<RolePermission>;
          result.permissions.replace(valueDes);
          break;
        case r'admin_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.adminCount = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdBy = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ServiceArea deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ServiceAreaBuilder();
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

