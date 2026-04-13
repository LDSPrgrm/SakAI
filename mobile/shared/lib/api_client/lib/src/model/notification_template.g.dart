// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_template.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationTemplateChannelEnum _$notificationTemplateChannelEnum_email =
    const NotificationTemplateChannelEnum._('email');
const NotificationTemplateChannelEnum _$notificationTemplateChannelEnum_sms =
    const NotificationTemplateChannelEnum._('sms');
const NotificationTemplateChannelEnum _$notificationTemplateChannelEnum_push =
    const NotificationTemplateChannelEnum._('push');

NotificationTemplateChannelEnum _$notificationTemplateChannelEnumValueOf(
  String name,
) {
  switch (name) {
    case 'email':
      return _$notificationTemplateChannelEnum_email;
    case 'sms':
      return _$notificationTemplateChannelEnum_sms;
    case 'push':
      return _$notificationTemplateChannelEnum_push;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NotificationTemplateChannelEnum>
_$notificationTemplateChannelEnumValues =
    BuiltSet<NotificationTemplateChannelEnum>(
      const <NotificationTemplateChannelEnum>[
        _$notificationTemplateChannelEnum_email,
        _$notificationTemplateChannelEnum_sms,
        _$notificationTemplateChannelEnum_push,
      ],
    );

Serializer<NotificationTemplateChannelEnum>
_$notificationTemplateChannelEnumSerializer =
    _$NotificationTemplateChannelEnumSerializer();

class _$NotificationTemplateChannelEnumSerializer
    implements PrimitiveSerializer<NotificationTemplateChannelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'email': 'email',
    'sms': 'sms',
    'push': 'push',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'email': 'email',
    'sms': 'sms',
    'push': 'push',
  };

  @override
  final Iterable<Type> types = const <Type>[NotificationTemplateChannelEnum];
  @override
  final String wireName = 'NotificationTemplateChannelEnum';

  @override
  Object serialize(
    Serializers serializers,
    NotificationTemplateChannelEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  NotificationTemplateChannelEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => NotificationTemplateChannelEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$NotificationTemplate extends NotificationTemplate {
  @override
  final String? event;
  @override
  final NotificationTemplateChannelEnum? channel;
  @override
  final String? subject;
  @override
  final String? body;

  factory _$NotificationTemplate([
    void Function(NotificationTemplateBuilder)? updates,
  ]) => (NotificationTemplateBuilder()..update(updates))._build();

  _$NotificationTemplate._({this.event, this.channel, this.subject, this.body})
    : super._();
  @override
  NotificationTemplate rebuild(
    void Function(NotificationTemplateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  NotificationTemplateBuilder toBuilder() =>
      NotificationTemplateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationTemplate &&
        event == other.event &&
        channel == other.channel &&
        subject == other.subject &&
        body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, subject.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationTemplate')
          ..add('event', event)
          ..add('channel', channel)
          ..add('subject', subject)
          ..add('body', body))
        .toString();
  }
}

class NotificationTemplateBuilder
    implements Builder<NotificationTemplate, NotificationTemplateBuilder> {
  _$NotificationTemplate? _$v;

  String? _event;
  String? get event => _$this._event;
  set event(String? event) => _$this._event = event;

  NotificationTemplateChannelEnum? _channel;
  NotificationTemplateChannelEnum? get channel => _$this._channel;
  set channel(NotificationTemplateChannelEnum? channel) =>
      _$this._channel = channel;

  String? _subject;
  String? get subject => _$this._subject;
  set subject(String? subject) => _$this._subject = subject;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  NotificationTemplateBuilder() {
    NotificationTemplate._defaults(this);
  }

  NotificationTemplateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _event = $v.event;
      _channel = $v.channel;
      _subject = $v.subject;
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationTemplate other) {
    _$v = other as _$NotificationTemplate;
  }

  @override
  void update(void Function(NotificationTemplateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationTemplate build() => _build();

  _$NotificationTemplate _build() {
    final _$result =
        _$v ??
        _$NotificationTemplate._(
          event: event,
          channel: channel,
          subject: subject,
          body: body,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
