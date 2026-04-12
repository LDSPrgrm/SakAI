// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_batch_approve_payouts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminBatchApprovePayouts200Response
    extends AdminBatchApprovePayouts200Response {
  @override
  final int? approved;

  factory _$AdminBatchApprovePayouts200Response([
    void Function(AdminBatchApprovePayouts200ResponseBuilder)? updates,
  ]) =>
      (AdminBatchApprovePayouts200ResponseBuilder()..update(updates))._build();

  _$AdminBatchApprovePayouts200Response._({this.approved}) : super._();
  @override
  AdminBatchApprovePayouts200Response rebuild(
    void Function(AdminBatchApprovePayouts200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminBatchApprovePayouts200ResponseBuilder toBuilder() =>
      AdminBatchApprovePayouts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminBatchApprovePayouts200Response &&
        approved == other.approved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, approved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminBatchApprovePayouts200Response',
    )..add('approved', approved)).toString();
  }
}

class AdminBatchApprovePayouts200ResponseBuilder
    implements
        Builder<
          AdminBatchApprovePayouts200Response,
          AdminBatchApprovePayouts200ResponseBuilder
        > {
  _$AdminBatchApprovePayouts200Response? _$v;

  int? _approved;
  int? get approved => _$this._approved;
  set approved(int? approved) => _$this._approved = approved;

  AdminBatchApprovePayouts200ResponseBuilder() {
    AdminBatchApprovePayouts200Response._defaults(this);
  }

  AdminBatchApprovePayouts200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _approved = $v.approved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminBatchApprovePayouts200Response other) {
    _$v = other as _$AdminBatchApprovePayouts200Response;
  }

  @override
  void update(
    void Function(AdminBatchApprovePayouts200ResponseBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  AdminBatchApprovePayouts200Response build() => _build();

  _$AdminBatchApprovePayouts200Response _build() {
    final _$result =
        _$v ?? _$AdminBatchApprovePayouts200Response._(approved: approved);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
