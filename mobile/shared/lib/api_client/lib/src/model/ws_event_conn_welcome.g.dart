// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_event_conn_welcome.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WsEventConnWelcome extends WsEventConnWelcome {
  @override
  final String? protocol;
  @override
  final int v;

  factory _$WsEventConnWelcome([
    void Function(WsEventConnWelcomeBuilder)? updates,
  ]) => (WsEventConnWelcomeBuilder()..update(updates))._build();

  _$WsEventConnWelcome._({this.protocol, required this.v}) : super._();
  @override
  WsEventConnWelcome rebuild(
    void Function(WsEventConnWelcomeBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WsEventConnWelcomeBuilder toBuilder() =>
      WsEventConnWelcomeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WsEventConnWelcome &&
        protocol == other.protocol &&
        v == other.v;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, protocol.hashCode);
    _$hash = $jc(_$hash, v.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WsEventConnWelcome')
          ..add('protocol', protocol)
          ..add('v', v))
        .toString();
  }
}

class WsEventConnWelcomeBuilder
    implements Builder<WsEventConnWelcome, WsEventConnWelcomeBuilder> {
  _$WsEventConnWelcome? _$v;

  String? _protocol;
  String? get protocol => _$this._protocol;
  set protocol(String? protocol) => _$this._protocol = protocol;

  int? _v;
  int? get v => _$this._v;
  set v(int? v) => _$this._v = v;

  WsEventConnWelcomeBuilder() {
    WsEventConnWelcome._defaults(this);
  }

  WsEventConnWelcomeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _protocol = $v.protocol;
      _v = $v.v;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WsEventConnWelcome other) {
    _$v = other as _$WsEventConnWelcome;
  }

  @override
  void update(void Function(WsEventConnWelcomeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WsEventConnWelcome build() => _build();

  _$WsEventConnWelcome _build() {
    final _$result =
        _$v ??
        _$WsEventConnWelcome._(
          protocol: protocol,
          v: BuiltValueNullFieldError.checkNotNull(
            v,
            r'WsEventConnWelcome',
            'v',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
