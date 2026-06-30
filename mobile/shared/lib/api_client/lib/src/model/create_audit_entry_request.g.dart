// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_audit_entry_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_create =
    const CreateAuditEntryRequestActionEnum._('create');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_update =
    const CreateAuditEntryRequestActionEnum._('update');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_delete =
    const CreateAuditEntryRequestActionEnum._('delete');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_approve =
    const CreateAuditEntryRequestActionEnum._('approve');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_reject =
    const CreateAuditEntryRequestActionEnum._('reject');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_login =
    const CreateAuditEntryRequestActionEnum._('login');
const CreateAuditEntryRequestActionEnum
_$createAuditEntryRequestActionEnum_logout =
    const CreateAuditEntryRequestActionEnum._('logout');

CreateAuditEntryRequestActionEnum _$createAuditEntryRequestActionEnumValueOf(
  String name,
) {
  switch (name) {
    case 'create':
      return _$createAuditEntryRequestActionEnum_create;
    case 'update':
      return _$createAuditEntryRequestActionEnum_update;
    case 'delete':
      return _$createAuditEntryRequestActionEnum_delete;
    case 'approve':
      return _$createAuditEntryRequestActionEnum_approve;
    case 'reject':
      return _$createAuditEntryRequestActionEnum_reject;
    case 'login':
      return _$createAuditEntryRequestActionEnum_login;
    case 'logout':
      return _$createAuditEntryRequestActionEnum_logout;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateAuditEntryRequestActionEnum>
_$createAuditEntryRequestActionEnumValues =
    BuiltSet<CreateAuditEntryRequestActionEnum>(
      const <CreateAuditEntryRequestActionEnum>[
        _$createAuditEntryRequestActionEnum_create,
        _$createAuditEntryRequestActionEnum_update,
        _$createAuditEntryRequestActionEnum_delete,
        _$createAuditEntryRequestActionEnum_approve,
        _$createAuditEntryRequestActionEnum_reject,
        _$createAuditEntryRequestActionEnum_login,
        _$createAuditEntryRequestActionEnum_logout,
      ],
    );

Serializer<CreateAuditEntryRequestActionEnum>
_$createAuditEntryRequestActionEnumSerializer =
    _$CreateAuditEntryRequestActionEnumSerializer();

class _$CreateAuditEntryRequestActionEnumSerializer
    implements PrimitiveSerializer<CreateAuditEntryRequestActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'create': 'create',
    'update': 'update',
    'delete': 'delete',
    'approve': 'approve',
    'reject': 'reject',
    'login': 'login',
    'logout': 'logout',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'create': 'create',
    'update': 'update',
    'delete': 'delete',
    'approve': 'approve',
    'reject': 'reject',
    'login': 'login',
    'logout': 'logout',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateAuditEntryRequestActionEnum];
  @override
  final String wireName = 'CreateAuditEntryRequestActionEnum';

  @override
  Object serialize(
    Serializers serializers,
    CreateAuditEntryRequestActionEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  CreateAuditEntryRequestActionEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => CreateAuditEntryRequestActionEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$CreateAuditEntryRequest extends CreateAuditEntryRequest {
  @override
  final String resourceType;
  @override
  final String resourceId;
  @override
  final CreateAuditEntryRequestActionEnum action;
  @override
  final BuiltMap<String, JsonObject?>? beforeState;
  @override
  final BuiltMap<String, JsonObject?>? afterState;
  @override
  final String? reason;

  factory _$CreateAuditEntryRequest([
    void Function(CreateAuditEntryRequestBuilder)? updates,
  ]) => (CreateAuditEntryRequestBuilder()..update(updates))._build();

  _$CreateAuditEntryRequest._({
    required this.resourceType,
    required this.resourceId,
    required this.action,
    this.beforeState,
    this.afterState,
    this.reason,
  }) : super._();
  @override
  CreateAuditEntryRequest rebuild(
    void Function(CreateAuditEntryRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  CreateAuditEntryRequestBuilder toBuilder() =>
      CreateAuditEntryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAuditEntryRequest &&
        resourceType == other.resourceType &&
        resourceId == other.resourceId &&
        action == other.action &&
        beforeState == other.beforeState &&
        afterState == other.afterState &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, resourceType.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, beforeState.hashCode);
    _$hash = $jc(_$hash, afterState.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAuditEntryRequest')
          ..add('resourceType', resourceType)
          ..add('resourceId', resourceId)
          ..add('action', action)
          ..add('beforeState', beforeState)
          ..add('afterState', afterState)
          ..add('reason', reason))
        .toString();
  }
}

class CreateAuditEntryRequestBuilder
    implements
        Builder<CreateAuditEntryRequest, CreateAuditEntryRequestBuilder> {
  _$CreateAuditEntryRequest? _$v;

  String? _resourceType;
  String? get resourceType => _$this._resourceType;
  set resourceType(String? resourceType) => _$this._resourceType = resourceType;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  CreateAuditEntryRequestActionEnum? _action;
  CreateAuditEntryRequestActionEnum? get action => _$this._action;
  set action(CreateAuditEntryRequestActionEnum? action) =>
      _$this._action = action;

  MapBuilder<String, JsonObject?>? _beforeState;
  MapBuilder<String, JsonObject?> get beforeState =>
      _$this._beforeState ??= MapBuilder<String, JsonObject?>();
  set beforeState(MapBuilder<String, JsonObject?>? beforeState) =>
      _$this._beforeState = beforeState;

  MapBuilder<String, JsonObject?>? _afterState;
  MapBuilder<String, JsonObject?> get afterState =>
      _$this._afterState ??= MapBuilder<String, JsonObject?>();
  set afterState(MapBuilder<String, JsonObject?>? afterState) =>
      _$this._afterState = afterState;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  CreateAuditEntryRequestBuilder() {
    CreateAuditEntryRequest._defaults(this);
  }

  CreateAuditEntryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _resourceType = $v.resourceType;
      _resourceId = $v.resourceId;
      _action = $v.action;
      _beforeState = $v.beforeState?.toBuilder();
      _afterState = $v.afterState?.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAuditEntryRequest other) {
    _$v = other as _$CreateAuditEntryRequest;
  }

  @override
  void update(void Function(CreateAuditEntryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAuditEntryRequest build() => _build();

  _$CreateAuditEntryRequest _build() {
    _$CreateAuditEntryRequest _$result;
    try {
      _$result =
          _$v ??
          _$CreateAuditEntryRequest._(
            resourceType: BuiltValueNullFieldError.checkNotNull(
              resourceType,
              r'CreateAuditEntryRequest',
              'resourceType',
            ),
            resourceId: BuiltValueNullFieldError.checkNotNull(
              resourceId,
              r'CreateAuditEntryRequest',
              'resourceId',
            ),
            action: BuiltValueNullFieldError.checkNotNull(
              action,
              r'CreateAuditEntryRequest',
              'action',
            ),
            beforeState: _beforeState?.build(),
            afterState: _afterState?.build(),
            reason: reason,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'beforeState';
        _beforeState?.build();
        _$failedField = 'afterState';
        _afterState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'CreateAuditEntryRequest',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
