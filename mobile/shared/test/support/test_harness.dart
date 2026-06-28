import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Wraps [child] in a [MaterialApp] themed with the SakAI passenger config.
///
/// Centralises the boilerplate that widget tests used to repeat (`_wrap`,
/// `_harness`) so the theme + scaffolding stays consistent across the suite.
/// Set [wrapInScaffold] when the child needs `Scaffold` ancestors (most do,
/// e.g. `SnackBar`, `BottomSheet`, anything reading `ScaffoldMessenger`).
Widget sakaiHarness(
  Widget child, {
  Brightness brightness = Brightness.light,
  bool wrapInScaffold = false,
}) {
  final config = SakaiThemeConfig.passenger();
  final theme = brightness == Brightness.light
      ? SakaiTheme.light(config)
      : SakaiTheme.dark(config);
  final body = wrapInScaffold ? Scaffold(body: child) : child;
  return MaterialApp(
    theme: theme,
    debugShowCheckedModeBanner: false,
    home: body,
  );
}

/// Convenience: pumps [child] inside [sakaiHarness].
Future<void> pumpSakai(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  bool wrapInScaffold = false,
}) =>
    tester.pumpWidget(
      sakaiHarness(
        child,
        brightness: brightness,
        wrapInScaffold: wrapInScaffold,
      ),
    );
