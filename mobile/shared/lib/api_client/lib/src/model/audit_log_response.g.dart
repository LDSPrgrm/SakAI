// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditLogResponse extends AuditLogResponse {
  @override
  final BuiltList<AuditLog>? logs;
  @override
  final int? total;

  factory _$AuditLogResponse(
          [void Function(AuditLogResponseBuilder)? updates]) =>
      (AuditLogResponseBuilder()..update(updates))._build();

  _$AuditLogResponse._({this.logs, this.total}) : super._();
  @override
  AuditLogResponse rebuild(void Function(AuditLogResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditLogResponseBuilder toBuilder() =>
      AuditLogResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditLogResponse &&
        logs == other.logs &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, logs.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditLogResponse')
          ..add('logs', logs)
          ..add('total', total))
        .toString();
  }
}

class AuditLogResponseBuilder
    implements Builder<AuditLogResponse, AuditLogResponseBuilder> {
  _$AuditLogResponse? _$v;

  ListBuilder<AuditLog>? _logs;
  ListBuilder<AuditLog> get logs => _$this._logs ??= ListBuilder<AuditLog>();
  set logs(ListBuilder<AuditLog>? logs) => _$this._logs = logs;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  AuditLogResponseBuilder() {
    AuditLogResponse._defaults(this);
  }

  AuditLogResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _logs = $v.logs?.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditLogResponse other) {
    _$v = other as _$AuditLogResponse;
  }

  @override
  void update(void Function(AuditLogResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditLogResponse build() => _build();

  _$AuditLogResponse _build() {
    _$AuditLogResponse _$result;
    try {
      _$result = _$v ??
          _$AuditLogResponse._(
            logs: _logs?.build(),
            total: total,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'logs';
        _logs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditLogResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
