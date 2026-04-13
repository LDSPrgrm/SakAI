// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blackout_hour.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BlackoutHour extends BlackoutHour {
  @override
  final int? dayOfWeek;
  @override
  final String? startTime;
  @override
  final String? endTime;

  factory _$BlackoutHour([void Function(BlackoutHourBuilder)? updates]) =>
      (BlackoutHourBuilder()..update(updates))._build();

  _$BlackoutHour._({this.dayOfWeek, this.startTime, this.endTime}) : super._();
  @override
  BlackoutHour rebuild(void Function(BlackoutHourBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BlackoutHourBuilder toBuilder() => BlackoutHourBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BlackoutHour &&
        dayOfWeek == other.dayOfWeek &&
        startTime == other.startTime &&
        endTime == other.endTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dayOfWeek.hashCode);
    _$hash = $jc(_$hash, startTime.hashCode);
    _$hash = $jc(_$hash, endTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BlackoutHour')
          ..add('dayOfWeek', dayOfWeek)
          ..add('startTime', startTime)
          ..add('endTime', endTime))
        .toString();
  }
}

class BlackoutHourBuilder
    implements Builder<BlackoutHour, BlackoutHourBuilder> {
  _$BlackoutHour? _$v;

  int? _dayOfWeek;
  int? get dayOfWeek => _$this._dayOfWeek;
  set dayOfWeek(int? dayOfWeek) => _$this._dayOfWeek = dayOfWeek;

  String? _startTime;
  String? get startTime => _$this._startTime;
  set startTime(String? startTime) => _$this._startTime = startTime;

  String? _endTime;
  String? get endTime => _$this._endTime;
  set endTime(String? endTime) => _$this._endTime = endTime;

  BlackoutHourBuilder() {
    BlackoutHour._defaults(this);
  }

  BlackoutHourBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dayOfWeek = $v.dayOfWeek;
      _startTime = $v.startTime;
      _endTime = $v.endTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BlackoutHour other) {
    _$v = other as _$BlackoutHour;
  }

  @override
  void update(void Function(BlackoutHourBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BlackoutHour build() => _build();

  _$BlackoutHour _build() {
    final _$result = _$v ??
        _$BlackoutHour._(
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
