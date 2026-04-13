// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_export_report200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminExportReport200Response extends AdminExportReport200Response {
  @override
  final String url;
  @override
  final String data;

  factory _$AdminExportReport200Response(
          [void Function(AdminExportReport200ResponseBuilder)? updates]) =>
      (AdminExportReport200ResponseBuilder()..update(updates))._build();

  _$AdminExportReport200Response._({required this.url, required this.data})
      : super._();
  @override
  AdminExportReport200Response rebuild(
          void Function(AdminExportReport200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminExportReport200ResponseBuilder toBuilder() =>
      AdminExportReport200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminExportReport200Response &&
        url == other.url &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminExportReport200Response')
          ..add('url', url)
          ..add('data', data))
        .toString();
  }
}

class AdminExportReport200ResponseBuilder
    implements
        Builder<AdminExportReport200Response,
            AdminExportReport200ResponseBuilder> {
  _$AdminExportReport200Response? _$v;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _data;
  String? get data => _$this._data;
  set data(String? data) => _$this._data = data;

  AdminExportReport200ResponseBuilder() {
    AdminExportReport200Response._defaults(this);
  }

  AdminExportReport200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _url = $v.url;
      _data = $v.data;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminExportReport200Response other) {
    _$v = other as _$AdminExportReport200Response;
  }

  @override
  void update(void Function(AdminExportReport200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminExportReport200Response build() => _build();

  _$AdminExportReport200Response _build() {
    final _$result = _$v ??
        _$AdminExportReport200Response._(
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'AdminExportReport200Response', 'url'),
          data: BuiltValueNullFieldError.checkNotNull(
              data, r'AdminExportReport200Response', 'data'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
