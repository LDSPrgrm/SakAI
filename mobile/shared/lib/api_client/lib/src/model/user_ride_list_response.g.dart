// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ride_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserRideListResponse extends UserRideListResponse {
  @override
  final BuiltList<UserRideItem> data;
  @override
  final PaginationMeta pagination;

  factory _$UserRideListResponse([
    void Function(UserRideListResponseBuilder)? updates,
  ]) => (UserRideListResponseBuilder()..update(updates))._build();

  _$UserRideListResponse._({required this.data, required this.pagination})
    : super._();
  @override
  UserRideListResponse rebuild(
    void Function(UserRideListResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UserRideListResponseBuilder toBuilder() =>
      UserRideListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserRideListResponse &&
        data == other.data &&
        pagination == other.pagination;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jc(_$hash, pagination.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserRideListResponse')
          ..add('data', data)
          ..add('pagination', pagination))
        .toString();
  }
}

class UserRideListResponseBuilder
    implements Builder<UserRideListResponse, UserRideListResponseBuilder> {
  _$UserRideListResponse? _$v;

  ListBuilder<UserRideItem>? _data;
  ListBuilder<UserRideItem> get data =>
      _$this._data ??= ListBuilder<UserRideItem>();
  set data(ListBuilder<UserRideItem>? data) => _$this._data = data;

  PaginationMetaBuilder? _pagination;
  PaginationMetaBuilder get pagination =>
      _$this._pagination ??= PaginationMetaBuilder();
  set pagination(PaginationMetaBuilder? pagination) =>
      _$this._pagination = pagination;

  UserRideListResponseBuilder() {
    UserRideListResponse._defaults(this);
  }

  UserRideListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _pagination = $v.pagination.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserRideListResponse other) {
    _$v = other as _$UserRideListResponse;
  }

  @override
  void update(void Function(UserRideListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserRideListResponse build() => _build();

  _$UserRideListResponse _build() {
    _$UserRideListResponse _$result;
    try {
      _$result =
          _$v ??
          _$UserRideListResponse._(
            data: data.build(),
            pagination: pagination.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
        _$failedField = 'pagination';
        pagination.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UserRideListResponse',
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
