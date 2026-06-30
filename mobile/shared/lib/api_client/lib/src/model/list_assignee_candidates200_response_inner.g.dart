// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_assignee_candidates200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListAssigneeCandidates200ResponseInner
    extends ListAssigneeCandidates200ResponseInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final String role;

  factory _$ListAssigneeCandidates200ResponseInner([
    void Function(ListAssigneeCandidates200ResponseInnerBuilder)? updates,
  ]) => (ListAssigneeCandidates200ResponseInnerBuilder()..update(updates))
      ._build();

  _$ListAssigneeCandidates200ResponseInner._({
    required this.id,
    required this.name,
    required this.role,
  }) : super._();
  @override
  ListAssigneeCandidates200ResponseInner rebuild(
    void Function(ListAssigneeCandidates200ResponseInnerBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ListAssigneeCandidates200ResponseInnerBuilder toBuilder() =>
      ListAssigneeCandidates200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListAssigneeCandidates200ResponseInner &&
        id == other.id &&
        name == other.name &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListAssigneeCandidates200ResponseInner',
          )
          ..add('id', id)
          ..add('name', name)
          ..add('role', role))
        .toString();
  }
}

class ListAssigneeCandidates200ResponseInnerBuilder
    implements
        Builder<
          ListAssigneeCandidates200ResponseInner,
          ListAssigneeCandidates200ResponseInnerBuilder
        > {
  _$ListAssigneeCandidates200ResponseInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  ListAssigneeCandidates200ResponseInnerBuilder() {
    ListAssigneeCandidates200ResponseInner._defaults(this);
  }

  ListAssigneeCandidates200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListAssigneeCandidates200ResponseInner other) {
    _$v = other as _$ListAssigneeCandidates200ResponseInner;
  }

  @override
  void update(
    void Function(ListAssigneeCandidates200ResponseInnerBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ListAssigneeCandidates200ResponseInner build() => _build();

  _$ListAssigneeCandidates200ResponseInner _build() {
    final _$result =
        _$v ??
        _$ListAssigneeCandidates200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
            id,
            r'ListAssigneeCandidates200ResponseInner',
            'id',
          ),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'ListAssigneeCandidates200ResponseInner',
            'name',
          ),
          role: BuiltValueNullFieldError.checkNotNull(
            role,
            r'ListAssigneeCandidates200ResponseInner',
            'role',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
