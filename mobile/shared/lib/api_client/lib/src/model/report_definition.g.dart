// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_definition.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReportDefinition extends ReportDefinition {
  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? description;

  factory _$ReportDefinition([
    void Function(ReportDefinitionBuilder)? updates,
  ]) => (ReportDefinitionBuilder()..update(updates))._build();

  _$ReportDefinition._({this.id, this.title, this.description}) : super._();
  @override
  ReportDefinition rebuild(void Function(ReportDefinitionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReportDefinitionBuilder toBuilder() =>
      ReportDefinitionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReportDefinition &&
        id == other.id &&
        title == other.title &&
        description == other.description;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReportDefinition')
          ..add('id', id)
          ..add('title', title)
          ..add('description', description))
        .toString();
  }
}

class ReportDefinitionBuilder
    implements Builder<ReportDefinition, ReportDefinitionBuilder> {
  _$ReportDefinition? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ReportDefinitionBuilder() {
    ReportDefinition._defaults(this);
  }

  ReportDefinitionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _description = $v.description;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReportDefinition other) {
    _$v = other as _$ReportDefinition;
  }

  @override
  void update(void Function(ReportDefinitionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReportDefinition build() => _build();

  _$ReportDefinition _build() {
    final _$result =
        _$v ??
        _$ReportDefinition._(id: id, title: title, description: description);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
