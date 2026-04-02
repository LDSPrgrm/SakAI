import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../domain/auth_repository.dart';
import '../presentation/auth/login_screen.dart';

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  static final SakaiThemeConfig _config = SakaiThemeConfig.passenger();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakAI Passenger',
      theme: SakaiTheme.light(_config),
      darkTheme: SakaiTheme.dark(_config),
      themeMode: ThemeMode.system,
      home: LoginScreen(authRepository: authRepository),
    );
  }
}
