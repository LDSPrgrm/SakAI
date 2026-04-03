// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_resolve_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IncidentResolveRequest extends IncidentResolveRequest {
  @override
  final String notes;

  factory _$IncidentResolveRequest([
    void Function(IncidentResolveRequestBuilder)? updates,
  ]) => (IncidentResolveRequestBuilder()..update(updates))._build();

  _$IncidentResolveRequest._({required this.notes}) : super._();
  @override
  IncidentResolveRequest rebuild(
    void Function(IncidentResolveRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  IncidentResolveRequestBuilder toBuilder() =>
      IncidentResolveRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IncidentResolveRequest && notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'IncidentResolveRequest',
    )..add('notes', notes)).toString();
  }
}

class IncidentResolveRequestBuilder
    implements Builder<IncidentResolveRequest, IncidentResolveRequestBuilder> {
  _$IncidentResolveRequest? _$v;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  IncidentResolveRequestBuilder() {
    IncidentResolveRequest._defaults(this);
  }

  IncidentResolveRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IncidentResolveRequest other) {
    _$v = other as _$IncidentResolveRequest;
  }

  @override
  void update(void Function(IncidentResolveRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IncidentResolveRequest build() => _build();

  _$IncidentResolveRequest _build() {
    final _$result =
        _$v ??
        _$IncidentResolveRequest._(
          notes: BuiltValueNullFieldError.checkNotNull(
            notes,
            r'IncidentResolveRequest',
            'notes',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
