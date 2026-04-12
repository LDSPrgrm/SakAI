//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_status.g.dart';

class RideStatus extends EnumClass {

  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'requested')
  static const RideStatus requested = _$requested;
  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'accepted')
  static const RideStatus accepted = _$accepted;
  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'arrived')
  static const RideStatus arrived = _$arrived;
  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const RideStatus inProgress = _$inProgress;
  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'completed')
  static const RideStatus completed = _$completed;
  /// Ride state machine: ``` requested → accepted → arrived → in_progress → completed      ↘          ↙       ↙        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RideStatus cancelled = _$cancelled;

  static Serializer<RideStatus> get serializer => _$rideStatusSerializer;

  const RideStatus._(String name): super(name);

  static BuiltSet<RideStatus> get values => _$values;
  static RideStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RideStatusMixin = Object with _$RideStatusMixin;

