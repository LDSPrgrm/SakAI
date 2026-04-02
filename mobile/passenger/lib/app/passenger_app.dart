import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../domain/auth_repository.dart';
import '../domain/ride_repository.dart';
import '../presentation/auth/login_screen.dart';

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
