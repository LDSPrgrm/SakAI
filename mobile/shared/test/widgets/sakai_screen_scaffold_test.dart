import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiScreenScaffold', () {
    // Mirrors mobile/driver/lib/features/documents/views/document_list_view.dart:
    // title + actions (IconButton) + fab.
    testWidgets('renders like DocumentListView (title + actions + fab)',
        (tester) async {
      await pumpSakai(
        tester,
        SakaiScreenScaffold(
          title: 'Documents',
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
          ],
          fab: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          body: const Center(child: Text('No documents uploaded yet')),
        ),
      );

      expect(find.text('Documents'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('No documents uploaded yet'), findsOneWidget);
      // The internal bar is now a SakaiAppBar (which renders a Material AppBar).
      expect(find.byType(SakaiAppBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // Mirrors mobile/passenger/lib/features/support/views/support_screen.dart:
    // title + body only, no actions/fab.
    testWidgets('renders like SupportScreen (title + body only)',
        (tester) async {
      await pumpSakai(
        tester,
        SakaiScreenScaffold(
          title: 'Support & Help',
          body: const Text('Send a Message'),
        ),
      );

      expect(find.text('Support & Help'), findsOneWidget);
      expect(find.text('Send a Message'), findsOneWidget);
      expect(find.byType(SakaiAppBar), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      // No back stack in this standalone pump, so SakaiAppBar's default
      // showBack/leading resolution should yield no leading widget.
      expect(appBar.leading, isNull);
    });

    testWidgets('renders correctly under dark theme (driver consumer)',
        (tester) async {
      await pumpSakai(
        tester,
        SakaiScreenScaffold(
          title: 'Documents',
          body: const SizedBox.shrink(),
        ),
        brightness: Brightness.dark,
      );

      expect(find.text('Documents'), findsOneWidget);
      expect(find.byType(SakaiAppBar), findsOneWidget);
    });
  });
}
