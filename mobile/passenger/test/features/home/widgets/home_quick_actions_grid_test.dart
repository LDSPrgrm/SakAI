import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passenger/app/routes.dart';
import 'package:passenger/features/home/views/widgets/home_quick_actions_grid.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '_test_helpers.dart';

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('renders 4 quick action tiles with correct labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: routedScaffold(child: const HomeQuickActionsGrid()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Saved Places'), findsOneWidget);
    expect(find.text('Schedule Ride'), findsOneWidget);
    expect(find.text('Promotions'), findsOneWidget);
    expect(find.text('Ride History'), findsOneWidget);
  });

  testWidgets(
    'tap Schedule Ride navigates to /coming-soon with feature name',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: routedScaffold(
            child: const HomeQuickActionsGrid(),
            extraRoutes: [
              GoRoute(
                path: Routes.comingSoon,
                builder: (_, state) {
                  final feature = state.extra as String? ?? 'unknown';
                  return Scaffold(body: Text('CS:$feature'));
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('home_qa_schedule_ride')));
      await tester.pumpAndSettle();

      expect(find.text('CS:Schedule Ride'), findsOneWidget);
    },
  );
}
