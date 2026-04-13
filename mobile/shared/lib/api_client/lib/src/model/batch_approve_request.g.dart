// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_approve_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BatchApproveRequest extends BatchApproveRequest {
  @override
  final BuiltList<String> ids;

  factory _$BatchApproveRequest(
          [void Function(BatchApproveRequestBuilder)? updates]) =>
      (BatchApproveRequestBuilder()..update(updates))._build();

  _$BatchApproveRequest._({required this.ids}) : super._();
  @override
  BatchApproveRequest rebuild(
          void Function(BatchApproveRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BatchApproveRequestBuilder toBuilder() =>
      BatchApproveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BatchApproveRequest && ids == other.ids;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BatchApproveRequest')
          ..add('ids', ids))
        .toString();
  }
}

class BatchApproveRequestBuilder
    implements Builder<BatchApproveRequest, BatchApproveRequestBuilder> {
  _$BatchApproveRequest? _$v;

  ListBuilder<String>? _ids;
  ListBuilder<String> get ids => _$this._ids ??= ListBuilder<String>();
  set ids(ListBuilder<String>? ids) => _$this._ids = ids;

  BatchApproveRequestBuilder() {
    BatchApproveRequest._defaults(this);
  }

  BatchApproveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ids = $v.ids.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BatchApproveRequest other) {
    _$v = other as _$BatchApproveRequest;
  }

  @override
  void update(void Function(BatchApproveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BatchApproveRequest build() => _build();

  _$BatchApproveRequest _build() {
    _$BatchApproveRequest _$result;
    try {
      _$result = _$v ??
          _$BatchApproveRequest._(
            ids: ids.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        ids.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BatchApproveRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
