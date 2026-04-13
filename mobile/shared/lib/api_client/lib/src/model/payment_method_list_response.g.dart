// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentMethodListResponse extends PaymentMethodListResponse {
  @override
  final BuiltList<PaymentMethodDetails> data;

  factory _$PaymentMethodListResponse(
          [void Function(PaymentMethodListResponseBuilder)? updates]) =>
      (PaymentMethodListResponseBuilder()..update(updates))._build();

  _$PaymentMethodListResponse._({required this.data}) : super._();
  @override
  PaymentMethodListResponse rebuild(
          void Function(PaymentMethodListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentMethodListResponseBuilder toBuilder() =>
      PaymentMethodListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentMethodListResponse && data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentMethodListResponse')
          ..add('data', data))
        .toString();
  }
}

class PaymentMethodListResponseBuilder
    implements
        Builder<PaymentMethodListResponse, PaymentMethodListResponseBuilder> {
  _$PaymentMethodListResponse? _$v;

  ListBuilder<PaymentMethodDetails>? _data;
  ListBuilder<PaymentMethodDetails> get data =>
      _$this._data ??= ListBuilder<PaymentMethodDetails>();
  set data(ListBuilder<PaymentMethodDetails>? data) => _$this._data = data;

  PaymentMethodListResponseBuilder() {
    PaymentMethodListResponse._defaults(this);
  }

  PaymentMethodListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentMethodListResponse other) {
    _$v = other as _$PaymentMethodListResponse;
  }

  @override
  void update(void Function(PaymentMethodListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentMethodListResponse build() => _build();

  _$PaymentMethodListResponse _build() {
    _$PaymentMethodListResponse _$result;
    try {
      _$result = _$v ??
          _$PaymentMethodListResponse._(
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentMethodListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
