import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiAvatar', () {
    testWidgets('renders uppercase initials when no image is provided',
        (tester) async {
      await pumpSakai(
        tester,
        const Center(child: SakaiAvatar(initials: 'jd')),
        wrapInScaffold: true,
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('size: lg produces a 64x64 box', (tester) async {
      await pumpSakai(
        tester,
        const Center(
          child: SakaiAvatar(
            initials: 'AB',
            size: SakaiAvatarSize.lg,
          ),
        ),
        wrapInScaffold: true,
      );

      final size = tester.getSize(find.ancestor(
        of: find.text('AB'),
        matching: find.byType(Container),
      ).first);
      expect(size.width, 64.0);
      expect(size.height, 64.0);
    });

    testWidgets('badge widget is rendered in the tree', (tester) async {
      const badgeKey = Key('avatar-badge');
      await pumpSakai(
        tester,
        const Center(
          child: SakaiAvatar(
            initials: 'CD',
            badge: SizedBox(
              key: badgeKey,
              width: 12,
              height: 12,
            ),
          ),
        ),
        wrapInScaffold: true,
      );

      expect(find.byKey(badgeKey), findsOneWidget);
    });
  });
}
