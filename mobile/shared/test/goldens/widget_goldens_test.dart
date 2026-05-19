import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Goldens were recorded on the Windows host. Font hinting / Skia rasterization
/// differs per OS, so byte-equal comparisons fail on Linux + macOS CI runners.
/// Skip everywhere except the recording platform until a CI-platform recording
/// workflow exists.
final Object _goldensSkip = Platform.isWindows
    ? false
    : 'Goldens recorded on Windows; skipping on ${Platform.operatingSystem}.';

/// Stable canvas sizes per widget so goldens read like the figma exports.
const _appBarCanvas = Size(360, kToolbarHeight);
const _buttonCanvas = Size(220, 56);
const _alertCanvas = Size(320, 120);
const _listTileCanvas = Size(360, 72);

/// Builds a theme that mirrors `SakaiTheme._build` but swaps the
/// `google_fonts`-backed Plus Jakarta Sans text theme for Flutter's stock
/// Roboto (`Typography.material2021`). `GoogleFonts.plusJakartaSansTextTheme()`
/// kicks off an unawaited HTTP fetch the moment it is called, which fails
/// offline and is captured as a test exception even when the resulting styles
/// are later overridden — so we have to avoid calling it in the first place.
/// All other tokens (colors, semantic extension, component themes) match
/// production so goldens stay representative.
ThemeData _testSakaiTheme(SakaiThemeConfig config, Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: config.primarySeed,
    brightness: brightness,
  );
  final scheme = config.secondarySeed != null
      ? base.copyWith(secondary: config.secondarySeed)
      : base;

  final tokens = config.tokens;
  final radii = BorderRadius.circular(tokens.radiusMd);

  final success = config.successColor ?? scheme.secondary;
  final danger = config.dangerColor ?? scheme.error;
  final warning = config.warningColor ?? const Color(0xFFFBBC04);
  final warningHsl = HSLColor.fromColor(warning);
  final warningDark = warningHsl
      .withLightness((warningHsl.lightness + 0.08).clamp(0.0, 1.0))
      .toColor();
  final accentBlue = config.secondarySeed ?? scheme.secondary;

  final darkBackground = config.darkBackgroundColor ?? scheme.surface;
  final darkSurface = config.darkSurfaceColor ?? scheme.surface;
  final darkBorder = config.darkBorderColor ?? scheme.outlineVariant;

  final schemeWithOverrides = brightness == Brightness.dark
      ? scheme.copyWith(
          error: danger,
          surface: darkSurface,
          surfaceContainerLow: darkSurface,
          surfaceContainerHighest: darkSurface,
          outlineVariant: darkBorder,
        )
      : scheme.copyWith(error: danger);

  final neutral = brightness == Brightness.dark
      ? const Color(0xFF8B949E)
      : const Color(0xFF6B7280);
  final neutralVariant = brightness == Brightness.dark
      ? const Color(0xFF6B7280)
      : const Color(0xFF9CA3AF);
  final disabledSurface = brightness == Brightness.dark
      ? const Color(0xFF21262D)
      : const Color(0xFFF3F4F6);
  final disabledOnSurface = brightness == Brightness.dark
      ? const Color(0xFF6B7280)
      : const Color(0xFF9CA3AF);

  Color tint(Color baseColor) => brightness == Brightness.dark
      ? Color.alphaBlend(baseColor.withValues(alpha: 0.24), darkSurface)
      : Color.alphaBlend(baseColor.withValues(alpha: 0.12), Colors.white);

  final semantic = SakaiSemanticColors(
    success: success,
    danger: danger,
    accentBlue: accentBlue,
    warning: warning,
    darkBackground: darkBackground,
    darkSurface: darkSurface,
    darkBorder: darkBorder,
    neutral: neutral,
    neutralVariant: neutralVariant,
    disabledSurface: disabledSurface,
    disabledOnSurface: disabledOnSurface,
    dangerSubtle: tint(danger),
    warningSubtle: tint(warning),
    successSubtle: tint(success),
    warningDark: brightness == Brightness.dark ? warningDark : null,
  );

  final scaffoldBackgroundColor = brightness == Brightness.dark
      ? darkBackground
      : schemeWithOverrides.surface;

  // Roboto text theme — production uses GoogleFonts.plusJakartaSansTextTheme.
  final typography = Typography.material2021(
    platform: TargetPlatform.android,
    colorScheme: schemeWithOverrides,
  );
  final textTheme =
      brightness == Brightness.light ? typography.black : typography.white;

  return ThemeData(
    useMaterial3: config.useMaterial3,
    colorScheme: schemeWithOverrides,
    textTheme: textTheme,
    brightness: brightness,
    extensions: <ThemeExtension<dynamic>>[tokens, semantic],
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: tokens.elevationAppBar,
      scrolledUnderElevation: 1,
      backgroundColor: schemeWithOverrides.surface,
      foregroundColor: schemeWithOverrides.onSurface,
      surfaceTintColor: schemeWithOverrides.surface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      color: schemeWithOverrides.surfaceContainerLow,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceLg,
          vertical: tokens.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceLg,
          vertical: tokens.spaceMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: schemeWithOverrides.surfaceContainerHighest.withValues(
        alpha: brightness == Brightness.dark ? 0.2 : 0.4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radii,
        borderSide: BorderSide(color: schemeWithOverrides.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radii,
        borderSide: BorderSide(color: schemeWithOverrides.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radii,
        borderSide: BorderSide(color: schemeWithOverrides.error),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spaceMd,
        vertical: tokens.spaceMd,
      ),
    ),
  );
}

ThemeData _theme(Brightness brightness) =>
    _testSakaiTheme(SakaiThemeConfig.passenger(), brightness);

/// Wraps an [appBar] in a sized MaterialApp + Scaffold for app-bar goldens.
Widget _wrapAppBar(PreferredSizeWidget appBar, Brightness brightness) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme(brightness),
    home: Center(
      child: SizedBox.fromSize(
        size: _appBarCanvas,
        child: Scaffold(appBar: appBar),
      ),
    ),
  );
}

/// Wraps a generic [child] in a sized MaterialApp + Scaffold body.
Widget _wrap(
  Widget child, {
  required Brightness brightness,
  required Size size,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: _theme(brightness),
    home: Scaffold(
      body: Center(
        child: SizedBox.fromSize(size: size, child: child),
      ),
    ),
  );
}

void main() {
  group('SakaiAppBar golden', skip: _goldensSkip, () {
    testWidgets('light', (tester) async {
      await tester.pumpWidget(_wrapAppBar(
        const SakaiAppBar(title: Text('Profile')),
        Brightness.light,
      ));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('widget_goldens/sakai_app_bar_light.png'),
      );
    });

    testWidgets('dark', (tester) async {
      await tester.pumpWidget(_wrapAppBar(
        const SakaiAppBar(title: Text('Profile')),
        Brightness.dark,
      ));
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('widget_goldens/sakai_app_bar_dark.png'),
      );
    });
  });

  group('SakaiPrimaryButton golden', skip: _goldensSkip, () {
    testWidgets('light', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiPrimaryButton(label: 'Confirm'),
        brightness: Brightness.light,
        size: _buttonCanvas,
      ));
      await expectLater(
        find.byType(SakaiPrimaryButton),
        matchesGoldenFile('widget_goldens/sakai_primary_button_light.png'),
      );
    });

    testWidgets('dark', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiPrimaryButton(label: 'Confirm'),
        brightness: Brightness.dark,
        size: _buttonCanvas,
      ));
      await expectLater(
        find.byType(SakaiPrimaryButton),
        matchesGoldenFile('widget_goldens/sakai_primary_button_dark.png'),
      );
    });
  });

  group('SakaiErrorAlert golden', skip: _goldensSkip, () {
    testWidgets('light', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiErrorAlert(message: 'Could not load'),
        brightness: Brightness.light,
        size: _alertCanvas,
      ));
      await expectLater(
        find.byType(SakaiErrorAlert),
        matchesGoldenFile('widget_goldens/sakai_error_alert_light.png'),
      );
    });

    testWidgets('dark', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiErrorAlert(message: 'Could not load'),
        brightness: Brightness.dark,
        size: _alertCanvas,
      ));
      await expectLater(
        find.byType(SakaiErrorAlert),
        matchesGoldenFile('widget_goldens/sakai_error_alert_dark.png'),
      );
    });
  });

  group('SakaiListTile golden', skip: _goldensSkip, () {
    testWidgets('light', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiListTile(
          leading: Icon(Icons.person),
          title: Text('Settings'),
          trailing: Icon(Icons.chevron_right),
        ),
        brightness: Brightness.light,
        size: _listTileCanvas,
      ));
      await expectLater(
        find.byType(SakaiListTile),
        matchesGoldenFile('widget_goldens/sakai_list_tile_light.png'),
      );
    });

    testWidgets('dark', (tester) async {
      await tester.pumpWidget(_wrap(
        const SakaiListTile(
          leading: Icon(Icons.person),
          title: Text('Settings'),
          trailing: Icon(Icons.chevron_right),
        ),
        brightness: Brightness.dark,
        size: _listTileCanvas,
      ));
      await expectLater(
        find.byType(SakaiListTile),
        matchesGoldenFile('widget_goldens/sakai_list_tile_dark.png'),
      );
    });
  });
}
