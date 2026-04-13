// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_update_notification_template_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminUpdateNotificationTemplateRequest
    extends AdminUpdateNotificationTemplateRequest {
  @override
  final String body;

  factory _$AdminUpdateNotificationTemplateRequest(
          [void Function(AdminUpdateNotificationTemplateRequestBuilder)?
              updates]) =>
      (AdminUpdateNotificationTemplateRequestBuilder()..update(updates))
          ._build();

  _$AdminUpdateNotificationTemplateRequest._({required this.body}) : super._();
  @override
  AdminUpdateNotificationTemplateRequest rebuild(
          void Function(AdminUpdateNotificationTemplateRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminUpdateNotificationTemplateRequestBuilder toBuilder() =>
      AdminUpdateNotificationTemplateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminUpdateNotificationTemplateRequest &&
        body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AdminUpdateNotificationTemplateRequest')
          ..add('body', body))
        .toString();
  }
}

class AdminUpdateNotificationTemplateRequestBuilder
    implements
        Builder<AdminUpdateNotificationTemplateRequest,
            AdminUpdateNotificationTemplateRequestBuilder> {
  _$AdminUpdateNotificationTemplateRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  AdminUpdateNotificationTemplateRequestBuilder() {
    AdminUpdateNotificationTemplateRequest._defaults(this);
  }

  AdminUpdateNotificationTemplateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminUpdateNotificationTemplateRequest other) {
    _$v = other as _$AdminUpdateNotificationTemplateRequest;
  }

  @override
  void update(
      void Function(AdminUpdateNotificationTemplateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminUpdateNotificationTemplateRequest build() => _build();

  _$AdminUpdateNotificationTemplateRequest _build() {
    final _$result = _$v ??
        _$AdminUpdateNotificationTemplateRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'AdminUpdateNotificationTemplateRequest', 'body'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
