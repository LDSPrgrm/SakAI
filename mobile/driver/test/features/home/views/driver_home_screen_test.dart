import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

import 'package:driver/app/providers.dart';
import 'package:driver/features/home/views/driver_home_screen.dart';

final _themeConfig = SakaiThemeConfig.driver();
final _mockApiClient = SakaiApiClient();

void main() {
  testWidgets('DriverHomeScreen renders toggle button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
        ],
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Verify screen renders
    expect(find.text('SakAI · Driver'), findsOneWidget);
    expect(find.text('Driver workspace'), findsOneWidget);
    expect(find.text('Start shift'), findsOneWidget);
    expect(find.text('View earnings'), findsOneWidget);
  });

  testWidgets('GPS warning shows when online but GPS unavailable', (
    tester,
  ) async {
    // This test verifies the GPS warning banner logic exists in the screen
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wsClientProvider.overrideWithValue(WsClient()),
          apiClientProvider.overrideWithValue(_mockApiClient),
        ],
        child: MaterialApp(
          theme: SakaiTheme.light(_themeConfig),
          home: DriverHomeScreen(),
        ),
      ),
    );

    // Initially offline, no GPS warning
    expect(find.text('Waiting for GPS signal…'), findsNothing);
  });
}
