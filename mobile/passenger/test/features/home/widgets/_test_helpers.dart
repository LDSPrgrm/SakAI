import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Wraps [child] in a MaterialApp with the passenger SakAI theme.
/// Tests wrap the result in `ProviderScope(overrides: [...], child: ...)`.
Widget themedScaffold({required Widget child}) {
  return MaterialApp(
    theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
    home: Scaffold(body: child),
  );
}

/// Wraps [child] in a MaterialApp.router so widgets relying on
/// `context.push(...)` resolve correctly. [extraRoutes] lets a test add stub
/// destination screens to assert navigation outcomes.
/// Tests wrap the result in `ProviderScope(overrides: [...], child: ...)`.
Widget routedScaffold({
  required Widget child,
  List<GoRoute> extraRoutes = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => Scaffold(body: child)),
      ...extraRoutes,
    ],
  );
  return MaterialApp.router(
    theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
    routerConfig: router,
  );
}
