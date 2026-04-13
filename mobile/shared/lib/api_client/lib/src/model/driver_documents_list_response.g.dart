// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_documents_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DriverDocumentsListResponse extends DriverDocumentsListResponse {
  @override
  final BuiltList<DriverDocumentResponse> documents;

  factory _$DriverDocumentsListResponse(
          [void Function(DriverDocumentsListResponseBuilder)? updates]) =>
      (DriverDocumentsListResponseBuilder()..update(updates))._build();

  _$DriverDocumentsListResponse._({required this.documents}) : super._();
  @override
  DriverDocumentsListResponse rebuild(
          void Function(DriverDocumentsListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DriverDocumentsListResponseBuilder toBuilder() =>
      DriverDocumentsListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DriverDocumentsListResponse && documents == other.documents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, documents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DriverDocumentsListResponse')
          ..add('documents', documents))
        .toString();
  }
}

class DriverDocumentsListResponseBuilder
    implements
        Builder<DriverDocumentsListResponse,
            DriverDocumentsListResponseBuilder> {
  _$DriverDocumentsListResponse? _$v;

  ListBuilder<DriverDocumentResponse>? _documents;
  ListBuilder<DriverDocumentResponse> get documents =>
      _$this._documents ??= ListBuilder<DriverDocumentResponse>();
  set documents(ListBuilder<DriverDocumentResponse>? documents) =>
      _$this._documents = documents;

  DriverDocumentsListResponseBuilder() {
    DriverDocumentsListResponse._defaults(this);
  }

  DriverDocumentsListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _documents = $v.documents.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DriverDocumentsListResponse other) {
    _$v = other as _$DriverDocumentsListResponse;
  }

  @override
  void update(void Function(DriverDocumentsListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DriverDocumentsListResponse build() => _build();

  _$DriverDocumentsListResponse _build() {
    _$DriverDocumentsListResponse _$result;
    try {
      _$result = _$v ??
          _$DriverDocumentsListResponse._(
            documents: documents.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'documents';
        documents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DriverDocumentsListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
