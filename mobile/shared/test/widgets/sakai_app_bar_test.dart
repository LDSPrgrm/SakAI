import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../support/test_harness.dart';

void main() {
  group('SakaiAppBar', () {
    testWidgets('renders provided title widget', (tester) async {
      await pumpSakai(
        tester,
        const Scaffold(
          appBar: SakaiAppBar(title: Text('Hello')),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('invokes onBack when back button is tapped', (tester) async {
      var tapped = false;

      await pumpSakai(
        tester,
        Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: SakaiAppBar(
                        title: const Text('Detail'),
                        onBack: () => tapped = true,
                      ),
                      body: const SizedBox.shrink(),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('transparent factory has elevation 0 and transparent bg',
        (tester) async {
      await pumpSakai(
        tester,
        Scaffold(
          appBar: SakaiAppBar.transparent(title: const Text('Clear')),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.elevation, 0);
      expect(appBar.backgroundColor, Colors.transparent);
    });
  });
}
