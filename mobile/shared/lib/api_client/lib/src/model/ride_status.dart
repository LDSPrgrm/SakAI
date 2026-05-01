// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ride_status.g.dart';

class RideStatus extends EnumClass {

  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'requested')
  static const RideStatus requested = _$requested;
  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'accepted')
  static const RideStatus accepted = _$accepted;
  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'arrived')
  static const RideStatus arrived = _$arrived;
  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const RideStatus inProgress = _$inProgress;
  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'completed')
  static const RideStatus completed = _$completed;
  /// Ride state machine: ``` requested â†’ accepted â†’ arrived â†’ in_progress â†’ completed      â†˜          â†™       â†™        cancelled  (not from in_progress) ``` Terminal states: `completed`, `cancelled` 
  @BuiltValueEnumConst(wireName: r'cancelled')
  static const RideStatus cancelled = _$cancelled;

  static Serializer<RideStatus> get serializer => _$rideStatusSerializer;

  const RideStatus._(String name): super(name);

  static BuiltSet<RideStatus> get values => _$values;
  static RideStatus valueOf(String name) => _$valueOf(name);
}

