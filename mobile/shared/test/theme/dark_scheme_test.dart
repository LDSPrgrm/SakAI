import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  // Calling SakaiTheme.dark/light triggers GoogleFonts.plusJakartaSansTextTheme,
  // which requires an initialized binding (see sakai_shared_test.dart). Use
  // testWidgets so TestWidgetsFlutterBinding is set up, matching the rest of
  // the suite's convention for exercising SakaiTheme directly.
  testWidgets('driver dark scheme maps navy page bg + slate containers', (
    tester,
  ) async {
    final cs = SakaiTheme.dark(SakaiThemeConfig.driver()).colorScheme;
    expect(cs.surface, const Color(0xFF0F172A));
    expect(cs.surfaceContainerHigh, const Color(0xFF1E293B));
    expect(cs.surfaceContainer, const Color(0xFF1E293B));
    expect(cs.scrim, const Color(0xFF0F172A));
  });
}
