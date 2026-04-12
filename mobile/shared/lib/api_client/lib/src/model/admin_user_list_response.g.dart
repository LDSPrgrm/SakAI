// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminUserListResponse extends AdminUserListResponse {
  @override
  final BuiltList<UserProfile>? items;
  @override
  final PaginationMeta? meta;

  factory _$AdminUserListResponse([
    void Function(AdminUserListResponseBuilder)? updates,
  ]) => (AdminUserListResponseBuilder()..update(updates))._build();

  _$AdminUserListResponse._({this.items, this.meta}) : super._();
  @override
  AdminUserListResponse rebuild(
    void Function(AdminUserListResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminUserListResponseBuilder toBuilder() =>
      AdminUserListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUserListResponse &&
        items == other.items &&
        meta == other.meta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, meta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminUserListResponse')
          ..add('items', items)
          ..add('meta', meta))
        .toString();
  }
}

class AdminUserListResponseBuilder
    implements Builder<AdminUserListResponse, AdminUserListResponseBuilder> {
  _$AdminUserListResponse? _$v;

  ListBuilder<UserProfile>? _items;
  ListBuilder<UserProfile> get items =>
      _$this._items ??= ListBuilder<UserProfile>();
  set items(ListBuilder<UserProfile>? items) => _$this._items = items;

  PaginationMetaBuilder? _meta;
  PaginationMetaBuilder get meta => _$this._meta ??= PaginationMetaBuilder();
  set meta(PaginationMetaBuilder? meta) => _$this._meta = meta;

  AdminUserListResponseBuilder() {
    AdminUserListResponse._defaults(this);
  }

  AdminUserListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUserListResponse other) {
    _$v = other as _$AdminUserListResponse;
  }

  @override
  void update(void Function(AdminUserListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUserListResponse build() => _build();

  _$AdminUserListResponse _build() {
    _$AdminUserListResponse _$result;
    try {
      _$result =
          _$v ??
          _$AdminUserListResponse._(
            items: _items?.build(),
            meta: _meta?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
        _$failedField = 'meta';
        _meta?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminUserListResponse',
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
