// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ride_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminRideListResponse extends AdminRideListResponse {
  @override
  final BuiltList<AdminRideItem>? items;
  @override
  final PaginationMeta? meta;

  factory _$AdminRideListResponse([
    void Function(AdminRideListResponseBuilder)? updates,
  ]) => (AdminRideListResponseBuilder()..update(updates))._build();

  _$AdminRideListResponse._({this.items, this.meta}) : super._();
  @override
  AdminRideListResponse rebuild(
    void Function(AdminRideListResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminRideListResponseBuilder toBuilder() =>
      AdminRideListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminRideListResponse &&
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
    return (newBuiltValueToStringHelper(r'AdminRideListResponse')
          ..add('items', items)
          ..add('meta', meta))
        .toString();
  }
}

class AdminRideListResponseBuilder
    implements Builder<AdminRideListResponse, AdminRideListResponseBuilder> {
  _$AdminRideListResponse? _$v;

  ListBuilder<AdminRideItem>? _items;
  ListBuilder<AdminRideItem> get items =>
      _$this._items ??= ListBuilder<AdminRideItem>();
  set items(ListBuilder<AdminRideItem>? items) => _$this._items = items;

  PaginationMetaBuilder? _meta;
  PaginationMetaBuilder get meta => _$this._meta ??= PaginationMetaBuilder();
  set meta(PaginationMetaBuilder? meta) => _$this._meta = meta;

  AdminRideListResponseBuilder() {
    AdminRideListResponse._defaults(this);
  }

  AdminRideListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _meta = $v.meta?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminRideListResponse other) {
    _$v = other as _$AdminRideListResponse;
  }

  @override
  void update(void Function(AdminRideListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminRideListResponse build() => _build();

  _$AdminRideListResponse _build() {
    _$AdminRideListResponse _$result;
    try {
      _$result =
          _$v ??
          _$AdminRideListResponse._(
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
          r'AdminRideListResponse',
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
