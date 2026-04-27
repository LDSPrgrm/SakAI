// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_place.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SavedPlaceTypeEnum _$savedPlaceTypeEnum_home = const SavedPlaceTypeEnum._(
  'home',
);
const SavedPlaceTypeEnum _$savedPlaceTypeEnum_work = const SavedPlaceTypeEnum._(
  'work',
);
const SavedPlaceTypeEnum _$savedPlaceTypeEnum_other =
    const SavedPlaceTypeEnum._('other');

SavedPlaceTypeEnum _$savedPlaceTypeEnumValueOf(String name) {
  switch (name) {
    case 'home':
      return _$savedPlaceTypeEnum_home;
    case 'work':
      return _$savedPlaceTypeEnum_work;
    case 'other':
      return _$savedPlaceTypeEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SavedPlaceTypeEnum> _$savedPlaceTypeEnumValues =
    BuiltSet<SavedPlaceTypeEnum>(const <SavedPlaceTypeEnum>[
      _$savedPlaceTypeEnum_home,
      _$savedPlaceTypeEnum_work,
      _$savedPlaceTypeEnum_other,
    ]);

Serializer<SavedPlaceTypeEnum> _$savedPlaceTypeEnumSerializer =
    _$SavedPlaceTypeEnumSerializer();

class _$SavedPlaceTypeEnumSerializer
    implements PrimitiveSerializer<SavedPlaceTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'home': 'home',
    'work': 'work',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'home': 'home',
    'work': 'work',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[SavedPlaceTypeEnum];
  @override
  final String wireName = 'SavedPlaceTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SavedPlaceTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SavedPlaceTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SavedPlaceTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SavedPlace extends SavedPlace {
  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final SavedPlaceTypeEnum? type;
  @override
  final DateTime? createdAt;

  factory _$SavedPlace([void Function(SavedPlaceBuilder)? updates]) =>
      (SavedPlaceBuilder()..update(updates))._build();

  _$SavedPlace._({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
    this.createdAt,
  }) : super._();
  @override
  SavedPlace rebuild(void Function(SavedPlaceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SavedPlaceBuilder toBuilder() => SavedPlaceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SavedPlace &&
        id == other.id &&
        name == other.name &&
        address == other.address &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        type == other.type &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SavedPlace')
          ..add('id', id)
          ..add('name', name)
          ..add('address', address)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('type', type)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class SavedPlaceBuilder implements Builder<SavedPlace, SavedPlaceBuilder> {
  _$SavedPlace? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  double? _latitude;
  double? get latitude => _$this._latitude;
  set latitude(double? latitude) => _$this._latitude = latitude;

  double? _longitude;
  double? get longitude => _$this._longitude;
  set longitude(double? longitude) => _$this._longitude = longitude;

  SavedPlaceTypeEnum? _type;
  SavedPlaceTypeEnum? get type => _$this._type;
  set type(SavedPlaceTypeEnum? type) => _$this._type = type;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SavedPlaceBuilder() {
    SavedPlace._defaults(this);
  }

  SavedPlaceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _address = $v.address;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _type = $v.type;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SavedPlace other) {
    _$v = other as _$SavedPlace;
  }

  @override
  void update(void Function(SavedPlaceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SavedPlace build() => _build();

  _$SavedPlace _build() {
    final _$result =
        _$v ??
        _$SavedPlace._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'SavedPlace', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'SavedPlace',
            'name',
          ),
          address: BuiltValueNullFieldError.checkNotNull(
            address,
            r'SavedPlace',
            'address',
          ),
          latitude: BuiltValueNullFieldError.checkNotNull(
            latitude,
            r'SavedPlace',
            'latitude',
          ),
          longitude: BuiltValueNullFieldError.checkNotNull(
            longitude,
            r'SavedPlace',
            'longitude',
          ),
          type: type,
          createdAt: createdAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
