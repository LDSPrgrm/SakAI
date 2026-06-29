// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_assign_incident_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminAssignIncidentRequest extends AdminAssignIncidentRequest {
  @override
  final String? assigneeId;

  factory _$AdminAssignIncidentRequest([
    void Function(AdminAssignIncidentRequestBuilder)? updates,
  ]) => (AdminAssignIncidentRequestBuilder()..update(updates))._build();

  _$AdminAssignIncidentRequest._({this.assigneeId}) : super._();
  @override
  AdminAssignIncidentRequest rebuild(
    void Function(AdminAssignIncidentRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  AdminAssignIncidentRequestBuilder toBuilder() =>
      AdminAssignIncidentRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAssignIncidentRequest &&
        assigneeId == other.assigneeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assigneeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'AdminAssignIncidentRequest',
    )..add('assigneeId', assigneeId)).toString();
  }
}

class AdminAssignIncidentRequestBuilder
    implements
        Builder<AdminAssignIncidentRequest, AdminAssignIncidentRequestBuilder> {
  _$AdminAssignIncidentRequest? _$v;

  String? _assigneeId;
  String? get assigneeId => _$this._assigneeId;
  set assigneeId(String? assigneeId) => _$this._assigneeId = assigneeId;

  AdminAssignIncidentRequestBuilder() {
    AdminAssignIncidentRequest._defaults(this);
  }

  AdminAssignIncidentRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assigneeId = $v.assigneeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAssignIncidentRequest other) {
    _$v = other as _$AdminAssignIncidentRequest;
  }

  @override
  void update(void Function(AdminAssignIncidentRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAssignIncidentRequest build() => _build();

  _$AdminAssignIncidentRequest _build() {
    final _$result =
        _$v ?? _$AdminAssignIncidentRequest._(assigneeId: assigneeId);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
