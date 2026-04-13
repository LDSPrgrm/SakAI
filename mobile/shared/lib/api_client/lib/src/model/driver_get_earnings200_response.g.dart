// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_get_earnings200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverGetEarnings200Response extends DriverGetEarnings200Response {
  @override
  final BuiltList<EarningsItem>? data;
  @override
  final PaginationMeta? pagination;

  factory _$DriverGetEarnings200Response([
    void Function(DriverGetEarnings200ResponseBuilder)? updates,
  ]) => (DriverGetEarnings200ResponseBuilder()..update(updates))._build();

  _$DriverGetEarnings200Response._({this.data, this.pagination}) : super._();
  @override
  DriverGetEarnings200Response rebuild(
    void Function(DriverGetEarnings200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  DriverGetEarnings200ResponseBuilder toBuilder() =>
      DriverGetEarnings200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverGetEarnings200Response &&
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
    return (newBuiltValueToStringHelper(r'DriverGetEarnings200Response')
          ..add('data', data)
          ..add('pagination', pagination))
        .toString();
  }
}

class DriverGetEarnings200ResponseBuilder
    implements
        Builder<
          DriverGetEarnings200Response,
          DriverGetEarnings200ResponseBuilder
        > {
  _$DriverGetEarnings200Response? _$v;

  ListBuilder<EarningsItem>? _data;
  ListBuilder<EarningsItem> get data =>
      _$this._data ??= ListBuilder<EarningsItem>();
  set data(ListBuilder<EarningsItem>? data) => _$this._data = data;

  PaginationMetaBuilder? _pagination;
  PaginationMetaBuilder get pagination =>
      _$this._pagination ??= PaginationMetaBuilder();
  set pagination(PaginationMetaBuilder? pagination) =>
      _$this._pagination = pagination;

  DriverGetEarnings200ResponseBuilder() {
    DriverGetEarnings200Response._defaults(this);
  }

  DriverGetEarnings200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data?.toBuilder();
      _pagination = $v.pagination?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverGetEarnings200Response other) {
    _$v = other as _$DriverGetEarnings200Response;
  }

  @override
  void update(void Function(DriverGetEarnings200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverGetEarnings200Response build() => _build();

  _$DriverGetEarnings200Response _build() {
    _$DriverGetEarnings200Response _$result;
    try {
      _$result =
          _$v ??
          _$DriverGetEarnings200Response._(
            data: _data?.build(),
            pagination: _pagination?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        _data?.build();
        _$failedField = 'pagination';
        _pagination?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'DriverGetEarnings200Response',
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
