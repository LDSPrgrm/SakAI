// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_meta.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaginationMeta extends PaginationMeta {
  @override
  final int? currentPage;
  @override
  final int? limit;
  @override
  final int? totalItems;
  @override
  final int? totalPages;

  factory _$PaginationMeta([void Function(PaginationMetaBuilder)? updates]) =>
      (PaginationMetaBuilder()..update(updates))._build();

  _$PaginationMeta._(
      {this.currentPage, this.limit, this.totalItems, this.totalPages})
      : super._();
  @override
  PaginationMeta rebuild(void Function(PaginationMetaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaginationMetaBuilder toBuilder() => PaginationMetaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaginationMeta &&
        currentPage == other.currentPage &&
        limit == other.limit &&
        totalItems == other.totalItems &&
        totalPages == other.totalPages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPage.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, totalItems.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaginationMeta')
          ..add('currentPage', currentPage)
          ..add('limit', limit)
          ..add('totalItems', totalItems)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class PaginationMetaBuilder
    implements Builder<PaginationMeta, PaginationMetaBuilder> {
  _$PaginationMeta? _$v;

  int? _currentPage;
  int? get currentPage => _$this._currentPage;
  set currentPage(int? currentPage) => _$this._currentPage = currentPage;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _totalItems;
  int? get totalItems => _$this._totalItems;
  set totalItems(int? totalItems) => _$this._totalItems = totalItems;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  PaginationMetaBuilder() {
    PaginationMeta._defaults(this);
  }

  PaginationMetaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPage = $v.currentPage;
      _limit = $v.limit;
      _totalItems = $v.totalItems;
      _totalPages = $v.totalPages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaginationMeta other) {
    _$v = other as _$PaginationMeta;
  }

  @override
  void update(void Function(PaginationMetaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaginationMeta build() => _build();

  _$PaginationMeta _build() {
    final _$result = _$v ??
        _$PaginationMeta._(
          currentPage: currentPage,
          limit: limit,
          totalItems: totalItems,
          totalPages: totalPages,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
