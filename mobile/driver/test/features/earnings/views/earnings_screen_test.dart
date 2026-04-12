import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'package:driver/features/earnings/views/earnings_screen.dart';

final _themeConfig = SakaiThemeConfig.driver();

void main() {
  testWidgets('EarningsScreen shows empty state initially', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: EarningsScreen(),
        ),
      ),
    );

    expect(find.text('Earnings — Current Shift'), findsOneWidget);
    expect(find.text('No rides completed yet'), findsOneWidget);
  });
}
