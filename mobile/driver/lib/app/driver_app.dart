import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../presentation/home/driver_home_screen.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  static final SakaiThemeConfig _config = SakaiThemeConfig.driver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SakAI Driver',
      theme: SakaiTheme.light(_config),
      darkTheme: SakaiTheme.dark(_config),
      themeMode: ThemeMode.system,
      home: const DriverHomeScreen(),
    );
  }
}

