import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'router.dart';

class DriverApp extends ConsumerWidget {
  const DriverApp({super.key});

  static final SakaiThemeConfig _config = SakaiThemeConfig.driver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SakAI Driver',
      theme: SakaiTheme.light(_config),
      darkTheme: SakaiTheme.dark(_config),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
