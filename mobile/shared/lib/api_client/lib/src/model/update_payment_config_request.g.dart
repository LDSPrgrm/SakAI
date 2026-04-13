// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_payment_config_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdatePaymentConfigRequest extends UpdatePaymentConfigRequest {
  @override
  final BuiltMap<String, String>? configFields;
  @override
  final bool? isActive;

  factory _$UpdatePaymentConfigRequest([
    void Function(UpdatePaymentConfigRequestBuilder)? updates,
  ]) => (UpdatePaymentConfigRequestBuilder()..update(updates))._build();

  _$UpdatePaymentConfigRequest._({this.configFields, this.isActive})
    : super._();
  @override
  UpdatePaymentConfigRequest rebuild(
    void Function(UpdatePaymentConfigRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  UpdatePaymentConfigRequestBuilder toBuilder() =>
      UpdatePaymentConfigRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdatePaymentConfigRequest &&
        configFields == other.configFields &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configFields.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdatePaymentConfigRequest')
          ..add('configFields', configFields)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdatePaymentConfigRequestBuilder
    implements
        Builder<UpdatePaymentConfigRequest, UpdatePaymentConfigRequestBuilder> {
  _$UpdatePaymentConfigRequest? _$v;

  MapBuilder<String, String>? _configFields;
  MapBuilder<String, String> get configFields =>
      _$this._configFields ??= MapBuilder<String, String>();
  set configFields(MapBuilder<String, String>? configFields) =>
      _$this._configFields = configFields;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  UpdatePaymentConfigRequestBuilder() {
    UpdatePaymentConfigRequest._defaults(this);
  }

  UpdatePaymentConfigRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configFields = $v.configFields?.toBuilder();
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdatePaymentConfigRequest other) {
    _$v = other as _$UpdatePaymentConfigRequest;
  }

  @override
  void update(void Function(UpdatePaymentConfigRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdatePaymentConfigRequest build() => _build();

  _$UpdatePaymentConfigRequest _build() {
    _$UpdatePaymentConfigRequest _$result;
    try {
      _$result =
          _$v ??
          _$UpdatePaymentConfigRequest._(
            configFields: _configFields?.build(),
            isActive: isActive,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'configFields';
        _configFields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'UpdatePaymentConfigRequest',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
