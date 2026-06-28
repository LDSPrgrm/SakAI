// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$KycDocument extends KycDocument {
  @override
  final String? type;
  @override
  final String? label;
  @override
  final String? url;

  factory _$KycDocument([void Function(KycDocumentBuilder)? updates]) =>
      (KycDocumentBuilder()..update(updates))._build();

  _$KycDocument._({this.type, this.label, this.url}) : super._();
  @override
  KycDocument rebuild(void Function(KycDocumentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  KycDocumentBuilder toBuilder() => KycDocumentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is KycDocument &&
        type == other.type &&
        label == other.label &&
        url == other.url;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'KycDocument')
          ..add('type', type)
          ..add('label', label)
          ..add('url', url))
        .toString();
  }
}

class KycDocumentBuilder implements Builder<KycDocument, KycDocumentBuilder> {
  _$KycDocument? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  KycDocumentBuilder() {
    KycDocument._defaults(this);
  }

  KycDocumentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _label = $v.label;
      _url = $v.url;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(KycDocument other) {
    _$v = other as _$KycDocument;
  }

  @override
  void update(void Function(KycDocumentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  KycDocument build() => _build();

  _$KycDocument _build() {
    final _$result = _$v ?? _$KycDocument._(type: type, label: label, url: url);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
