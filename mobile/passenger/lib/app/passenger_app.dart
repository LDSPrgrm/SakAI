import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/repositories/auth_repository.dart';
import '../features/auth/views/login_screen.dart';
import '../features/ride/repositories/ride_repository.dart';

class PassengerApp extends StatelessWidget {
  const PassengerApp({
    super.key,
    required this.authRepository,
    required this.rideRepository,
  });

  final AuthRepository authRepository;
  final RideRepository rideRepository;

  static final SakaiThemeConfig _config = SakaiThemeConfig.passenger();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakAI Rider',
      theme: SakaiTheme.light(_config),
      darkTheme: SakaiTheme.dark(_config),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(
        authRepository: authRepository,
        rideRepository: rideRepository,
      ),
    );
  }
}
