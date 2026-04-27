// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_list_driver_rides200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminListDriverRides200Response
    extends AdminListDriverRides200Response {
  @override
  final BuiltList<RideResponse>? rides;
  @override
  final PaginationMeta? pagination;

  factory _$AdminListDriverRides200Response([
    void Function(AdminListDriverRides200ResponseBuilder)? updates,
  ]) => (AdminListDriverRides200ResponseBuilder()..update(updates))._build();

  _$AdminListDriverRides200Response._({this.rides, this.pagination})
    : super._();
  @override
  AdminListDriverRides200Response rebuild(
    void Function(AdminListDriverRides200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminListDriverRides200ResponseBuilder toBuilder() =>
      AdminListDriverRides200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminListDriverRides200Response &&
        rides == other.rides &&
        pagination == other.pagination;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rides.hashCode);
    _$hash = $jc(_$hash, pagination.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminListDriverRides200Response')
          ..add('rides', rides)
          ..add('pagination', pagination))
        .toString();
  }
}

class AdminListDriverRides200ResponseBuilder
    implements
        Builder<
          AdminListDriverRides200Response,
          AdminListDriverRides200ResponseBuilder
        > {
  _$AdminListDriverRides200Response? _$v;

  ListBuilder<RideResponse>? _rides;
  ListBuilder<RideResponse> get rides =>
      _$this._rides ??= ListBuilder<RideResponse>();
  set rides(ListBuilder<RideResponse>? rides) => _$this._rides = rides;

  PaginationMetaBuilder? _pagination;
  PaginationMetaBuilder get pagination =>
      _$this._pagination ??= PaginationMetaBuilder();
  set pagination(PaginationMetaBuilder? pagination) =>
      _$this._pagination = pagination;

  AdminListDriverRides200ResponseBuilder() {
    AdminListDriverRides200Response._defaults(this);
  }

  AdminListDriverRides200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rides = $v.rides?.toBuilder();
      _pagination = $v.pagination?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminListDriverRides200Response other) {
    _$v = other as _$AdminListDriverRides200Response;
  }

  @override
  void update(void Function(AdminListDriverRides200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminListDriverRides200Response build() => _build();

  _$AdminListDriverRides200Response _build() {
    _$AdminListDriverRides200Response _$result;
    try {
      _$result =
          _$v ??
          _$AdminListDriverRides200Response._(
            rides: _rides?.build(),
            pagination: _pagination?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rides';
        _rides?.build();
        _$failedField = 'pagination';
        _pagination?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AdminListDriverRides200Response',
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
