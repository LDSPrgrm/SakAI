import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('BackendUnavailableException', () {
    test('toString reports feature name', () {
      final ex = const BackendUnavailableException(feature: 'wallet');
      expect(ex.toString(), contains('wallet'));
      expect(ex.toString(), contains('awaiting backend'));
    });

    test('includes optional message', () {
      final ex = const BackendUnavailableException(
        feature: 'otp',
        message: 'SMS provider not configured.',
      );
      expect(ex.toString(), contains('SMS provider not configured'));
    });

    test('is catchable as Exception', () {
      Exception? captured;
      try {
        throw const BackendUnavailableException(feature: 'notifications');
      } on Exception catch (e) {
        captured = e;
      }
      expect(captured, isA<BackendUnavailableException>());
    });
  });

  group('ComingSoonState', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
          home: Scaffold(body: child),
        );

    testWidgets('renders title, feature-aware message and no CTA by default',
        (tester) async {
      await tester.pumpWidget(wrap(const ComingSoonState(feature: 'Wallet')));
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.textContaining('Wallet'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('renders Back CTA when onBack is supplied', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        wrap(ComingSoonState(feature: 'OTP', onBack: () => tapped++)),
      );
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('overrides title and message', (tester) async {
      await tester.pumpWidget(wrap(const ComingSoonState(
        feature: 'Wallet',
        title: 'Backend pending',
        message: 'Custom copy.',
      )));
      expect(find.text('Backend pending'), findsOneWidget);
      expect(find.text('Custom copy.'), findsOneWidget);
    });
  });
}
