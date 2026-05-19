import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiDivider', () {
    testWidgets('renders an inner Divider tinted with outlineVariant',
        (tester) async {
      await pumpSakai(tester, const SakaiDivider(), wrapInScaffold: true);

      final divider = tester.widget<Divider>(find.byType(Divider));
      final BuildContext ctx = tester.element(find.byType(Divider));
      final expected = Theme.of(ctx).colorScheme.outlineVariant;

      expect(divider.color, equals(expected));
    });

    testWidgets('inset: md applies horizontal padding equal to spaceMd',
        (tester) async {
      await pumpSakai(
        tester,
        const SakaiDivider(inset: SakaiDividerInset.md),
        wrapInScaffold: true,
      );

      final padding = tester.widget<Padding>(find.ancestor(
        of: find.byType(Divider),
        matching: find.byType(Padding),
      ).first);
      final BuildContext ctx = tester.element(find.byType(Divider));
      final tokens = SakaiDesignTokens.of(ctx);

      final edge = padding.padding.resolve(TextDirection.ltr);
      expect(edge.left, equals(tokens.spaceMd));
      expect(edge.right, equals(tokens.spaceMd));
    });
  });
}
