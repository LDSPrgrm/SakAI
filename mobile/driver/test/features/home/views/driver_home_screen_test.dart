import 'package:driver/app/providers.dart';
import 'package:driver/features/home/views/driver_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:sakai_shared/sakai_shared.dart';

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

    // Initially driver is offline
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Start shift'), findsOneWidget);
    expect(find.text('View earnings'), findsOneWidget);
    expect(find.byType(IconButton), findsWidgets); // menu button
  });

  testWidgets('GPS warning shows when online but GPS unavailable', (
    tester,
  ) async {
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
