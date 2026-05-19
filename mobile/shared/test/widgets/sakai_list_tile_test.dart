import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiListTile', () {
    testWidgets('renders title text', (tester) async {
      await pumpSakai(
        tester,
        const SakaiListTile(title: Text('Profile')),
        wrapInScaffold: true,
      );

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var taps = 0;
      await pumpSakai(
        tester,
        SakaiListTile(
          title: const Text('Tap me'),
          onTap: () => taps++,
        ),
        wrapInScaffold: true,
      );

      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('selected: true tints the row background', (tester) async {
      await pumpSakai(
        tester,
        const SakaiListTile(
          title: Text('Selected row'),
          selected: true,
        ),
        wrapInScaffold: true,
      );

      final BuildContext ctx = tester.element(find.text('Selected row'));
      final tokens = SakaiDesignTokens.of(ctx);
      final scheme = Theme.of(ctx).colorScheme;
      final expected = scheme.primaryContainer
          .withValues(alpha: tokens.opacityHover * 4);

      // Find the inner Container that holds the row background.
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Selected row'),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.color, equals(expected));
      expect(container.color, isNot(equals(Colors.transparent)));
    });
  });
}
