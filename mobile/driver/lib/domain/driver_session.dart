/// Domain model for the driver (placeholder).
///
/// Domain layer should hold entities + ports (interfaces) that are independent
/// from Flutter and networking concerns.
class DriverSession {
  const DriverSession({
    required this.vehiclePlate,
  });

  final String vehiclePlate;
}

