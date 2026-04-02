import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'app/passenger_app.dart';
import 'features/auth/repositories/auth_repository_impl.dart';
import 'features/ride/repositories/ride_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final api = SakaiApiSupport.createClient();
  final authRepository = AuthRepositoryImpl(api);
  final rideRepository = RideRepositoryImpl(api);
  runApp(PassengerApp(
    authRepository: authRepository,
    rideRepository: rideRepository,
  ));
}
