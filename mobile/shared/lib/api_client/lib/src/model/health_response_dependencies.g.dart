// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_response_dependencies.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const HealthResponseDependenciesDatabaseEnum
_$healthResponseDependenciesDatabaseEnum_ok =
    const HealthResponseDependenciesDatabaseEnum._('ok');
const HealthResponseDependenciesDatabaseEnum
_$healthResponseDependenciesDatabaseEnum_down =
    const HealthResponseDependenciesDatabaseEnum._('down');

HealthResponseDependenciesDatabaseEnum
_$healthResponseDependenciesDatabaseEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$healthResponseDependenciesDatabaseEnum_ok;
    case 'down':
      return _$healthResponseDependenciesDatabaseEnum_down;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HealthResponseDependenciesDatabaseEnum>
_$healthResponseDependenciesDatabaseEnumValues =
    BuiltSet<HealthResponseDependenciesDatabaseEnum>(
      const <HealthResponseDependenciesDatabaseEnum>[
        _$healthResponseDependenciesDatabaseEnum_ok,
        _$healthResponseDependenciesDatabaseEnum_down,
      ],
    );

const HealthResponseDependenciesRedisEnum
_$healthResponseDependenciesRedisEnum_ok =
    const HealthResponseDependenciesRedisEnum._('ok');
const HealthResponseDependenciesRedisEnum
_$healthResponseDependenciesRedisEnum_down =
    const HealthResponseDependenciesRedisEnum._('down');

HealthResponseDependenciesRedisEnum
_$healthResponseDependenciesRedisEnumValueOf(String name) {
  switch (name) {
    case 'ok':
      return _$healthResponseDependenciesRedisEnum_ok;
    case 'down':
      return _$healthResponseDependenciesRedisEnum_down;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<HealthResponseDependenciesRedisEnum>
_$healthResponseDependenciesRedisEnumValues =
    BuiltSet<HealthResponseDependenciesRedisEnum>(
      const <HealthResponseDependenciesRedisEnum>[
        _$healthResponseDependenciesRedisEnum_ok,
        _$healthResponseDependenciesRedisEnum_down,
      ],
    );

Serializer<HealthResponseDependenciesDatabaseEnum>
_$healthResponseDependenciesDatabaseEnumSerializer =
    _$HealthResponseDependenciesDatabaseEnumSerializer();
Serializer<HealthResponseDependenciesRedisEnum>
_$healthResponseDependenciesRedisEnumSerializer =
    _$HealthResponseDependenciesRedisEnumSerializer();

class _$HealthResponseDependenciesDatabaseEnumSerializer
    implements PrimitiveSerializer<HealthResponseDependenciesDatabaseEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'down': 'down',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'down': 'down',
  };

  @override
  final Iterable<Type> types = const <Type>[
    HealthResponseDependenciesDatabaseEnum,
  ];
  @override
  final String wireName = 'HealthResponseDependenciesDatabaseEnum';

  @override
  Object serialize(
    Serializers serializers,
    HealthResponseDependenciesDatabaseEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HealthResponseDependenciesDatabaseEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HealthResponseDependenciesDatabaseEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HealthResponseDependenciesRedisEnumSerializer
    implements PrimitiveSerializer<HealthResponseDependenciesRedisEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ok': 'ok',
    'down': 'down',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ok': 'ok',
    'down': 'down',
  };

  @override
  final Iterable<Type> types = const <Type>[
    HealthResponseDependenciesRedisEnum,
  ];
  @override
  final String wireName = 'HealthResponseDependenciesRedisEnum';

  @override
  Object serialize(
    Serializers serializers,
    HealthResponseDependenciesRedisEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  HealthResponseDependenciesRedisEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => HealthResponseDependenciesRedisEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$HealthResponseDependencies extends HealthResponseDependencies {
  @override
  final HealthResponseDependenciesDatabaseEnum? database;
  @override
  final HealthResponseDependenciesRedisEnum? redis;

  factory _$HealthResponseDependencies([
    void Function(HealthResponseDependenciesBuilder)? updates,
  ]) => (HealthResponseDependenciesBuilder()..update(updates))._build();

  _$HealthResponseDependencies._({this.database, this.redis}) : super._();
  @override
  HealthResponseDependencies rebuild(
    void Function(HealthResponseDependenciesBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  HealthResponseDependenciesBuilder toBuilder() =>
      HealthResponseDependenciesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HealthResponseDependencies &&
        database == other.database &&
        redis == other.redis;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, database.hashCode);
    _$hash = $jc(_$hash, redis.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HealthResponseDependencies')
          ..add('database', database)
          ..add('redis', redis))
        .toString();
  }
}

class HealthResponseDependenciesBuilder
    implements
        Builder<HealthResponseDependencies, HealthResponseDependenciesBuilder> {
  _$HealthResponseDependencies? _$v;

  HealthResponseDependenciesDatabaseEnum? _database;
  HealthResponseDependenciesDatabaseEnum? get database => _$this._database;
  set database(HealthResponseDependenciesDatabaseEnum? database) =>
      _$this._database = database;

  HealthResponseDependenciesRedisEnum? _redis;
  HealthResponseDependenciesRedisEnum? get redis => _$this._redis;
  set redis(HealthResponseDependenciesRedisEnum? redis) =>
      _$this._redis = redis;

  HealthResponseDependenciesBuilder() {
    HealthResponseDependencies._defaults(this);
  }

  HealthResponseDependenciesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _database = $v.database;
      _redis = $v.redis;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HealthResponseDependencies other) {
    _$v = other as _$HealthResponseDependencies;
  }

  @override
  void update(void Function(HealthResponseDependenciesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HealthResponseDependencies build() => _build();

  _$HealthResponseDependencies _build() {
    final _$result =
        _$v ?? _$HealthResponseDependencies._(database: database, redis: redis);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
