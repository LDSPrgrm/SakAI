// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_place_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SavedPlaceCreateRequestTypeEnum _$savedPlaceCreateRequestTypeEnum_home =
    const SavedPlaceCreateRequestTypeEnum._('home');
const SavedPlaceCreateRequestTypeEnum _$savedPlaceCreateRequestTypeEnum_work =
    const SavedPlaceCreateRequestTypeEnum._('work');
const SavedPlaceCreateRequestTypeEnum _$savedPlaceCreateRequestTypeEnum_other =
    const SavedPlaceCreateRequestTypeEnum._('other');

SavedPlaceCreateRequestTypeEnum _$savedPlaceCreateRequestTypeEnumValueOf(
  String name,
) {
  switch (name) {
    case 'home':
      return _$savedPlaceCreateRequestTypeEnum_home;
    case 'work':
      return _$savedPlaceCreateRequestTypeEnum_work;
    case 'other':
      return _$savedPlaceCreateRequestTypeEnum_other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SavedPlaceCreateRequestTypeEnum>
_$savedPlaceCreateRequestTypeEnumValues =
    BuiltSet<SavedPlaceCreateRequestTypeEnum>(
      const <SavedPlaceCreateRequestTypeEnum>[
        _$savedPlaceCreateRequestTypeEnum_home,
        _$savedPlaceCreateRequestTypeEnum_work,
        _$savedPlaceCreateRequestTypeEnum_other,
      ],
    );

Serializer<SavedPlaceCreateRequestTypeEnum>
_$savedPlaceCreateRequestTypeEnumSerializer =
    _$SavedPlaceCreateRequestTypeEnumSerializer();

class _$SavedPlaceCreateRequestTypeEnumSerializer
    implements PrimitiveSerializer<SavedPlaceCreateRequestTypeEnum> {
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
  final Iterable<Type> types = const <Type>[SavedPlaceCreateRequestTypeEnum];
  @override
  final String wireName = 'SavedPlaceCreateRequestTypeEnum';

  @override
  Object serialize(
    Serializers serializers,
    SavedPlaceCreateRequestTypeEnum object, {
    FullType specifiedType = FullType.unspecified,
  }) => _toWire[object.name] ?? object.name;

  @override
  SavedPlaceCreateRequestTypeEnum deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) => SavedPlaceCreateRequestTypeEnum.valueOf(
    _fromWire[serialized] ?? (serialized is String ? serialized : ''),
  );
}

class _$SavedPlaceCreateRequest extends SavedPlaceCreateRequest {
  @override
  final String name;
  @override
  final String address;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final SavedPlaceCreateRequestTypeEnum? type;

  factory _$SavedPlaceCreateRequest([
    void Function(SavedPlaceCreateRequestBuilder)? updates,
  ]) => (SavedPlaceCreateRequestBuilder()..update(updates))._build();

  _$SavedPlaceCreateRequest._({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
  }) : super._();
  @override
  SavedPlaceCreateRequest rebuild(
    void Function(SavedPlaceCreateRequestBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SavedPlaceCreateRequestBuilder toBuilder() =>
      SavedPlaceCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SavedPlaceCreateRequest &&
        name == other.name &&
        address == other.address &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SavedPlaceCreateRequest')
          ..add('name', name)
          ..add('address', address)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('type', type))
        .toString();
  }
}

class SavedPlaceCreateRequestBuilder
    implements
        Builder<SavedPlaceCreateRequest, SavedPlaceCreateRequestBuilder> {
  _$SavedPlaceCreateRequest? _$v;

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

  SavedPlaceCreateRequestTypeEnum? _type;
  SavedPlaceCreateRequestTypeEnum? get type => _$this._type;
  set type(SavedPlaceCreateRequestTypeEnum? type) => _$this._type = type;

  SavedPlaceCreateRequestBuilder() {
    SavedPlaceCreateRequest._defaults(this);
  }

  SavedPlaceCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _address = $v.address;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SavedPlaceCreateRequest other) {
    _$v = other as _$SavedPlaceCreateRequest;
  }

  @override
  void update(void Function(SavedPlaceCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SavedPlaceCreateRequest build() => _build();

  _$SavedPlaceCreateRequest _build() {
    final _$result =
        _$v ??
        _$SavedPlaceCreateRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'SavedPlaceCreateRequest',
            'name',
          ),
          address: BuiltValueNullFieldError.checkNotNull(
            address,
            r'SavedPlaceCreateRequest',
            'address',
          ),
          latitude: BuiltValueNullFieldError.checkNotNull(
            latitude,
            r'SavedPlaceCreateRequest',
            'latitude',
          ),
          longitude: BuiltValueNullFieldError.checkNotNull(
            longitude,
            r'SavedPlaceCreateRequest',
            'longitude',
          ),
          type: type,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
