// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_batch_kyc200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminBatchKyc200Response extends AdminBatchKyc200Response {
  @override
  final int? processed;

  factory _$AdminBatchKyc200Response([
    void Function(AdminBatchKyc200ResponseBuilder)? updates,
  ]) => (AdminBatchKyc200ResponseBuilder()..update(updates))._build();

  _$AdminBatchKyc200Response._({this.processed}) : super._();
  @override
  AdminBatchKyc200Response rebuild(
    void Function(AdminBatchKyc200ResponseBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminBatchKyc200ResponseBuilder toBuilder() =>
      AdminBatchKyc200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminBatchKyc200Response && processed == other.processed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, processed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminBatchKyc200Response',
    )..add('processed', processed)).toString();
  }
}

class AdminBatchKyc200ResponseBuilder
    implements
        Builder<AdminBatchKyc200Response, AdminBatchKyc200ResponseBuilder> {
  _$AdminBatchKyc200Response? _$v;

  int? _processed;
  int? get processed => _$this._processed;
  set processed(int? processed) => _$this._processed = processed;

  AdminBatchKyc200ResponseBuilder() {
    AdminBatchKyc200Response._defaults(this);
  }

  AdminBatchKyc200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _processed = $v.processed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminBatchKyc200Response other) {
    _$v = other as _$AdminBatchKyc200Response;
  }

  @override
  void update(void Function(AdminBatchKyc200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminBatchKyc200Response build() => _build();

  _$AdminBatchKyc200Response _build() {
    final _$result = _$v ?? _$AdminBatchKyc200Response._(processed: processed);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
