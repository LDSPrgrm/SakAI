import 'package:sakai_shared/sakai_shared.dart';

class RideTypeOption {
  final VehicleType type;
  final double estimatedFare;
  final Duration estimatedDuration;
  final int availableDrivers;

  const RideTypeOption({
    required this.type,
    required this.estimatedFare,
    required this.estimatedDuration,
    required this.availableDrivers,
  });

  bool get isAvailable => availableDrivers > 0;
}
