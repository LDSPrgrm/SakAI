import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/widgets/sakai_primary_button.dart';
import 'package:sakai_shared/widgets/sakai_secondary_button.dart';

void main() {
  group('SakaiPrimaryButton', () {
    testWidgets('renders label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SakaiPrimaryButton(label: 'Submit'),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SakaiPrimaryButton(
              label: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(pressed, isTrue);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SakaiPrimaryButton(
              label: 'Submit',
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('expands to full width by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SakaiPrimaryButton(label: 'Submit'),
          ),
        ),
      );

      final SizedBox sizedBox = tester.widget(find.byType(SizedBox));
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('does not expand when expand is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SakaiPrimaryButton(
              label: 'Submit',
              expand: false,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsNothing);
    });
  });

  group('SakaiSecondaryButton', () {
    testWidgets('renders label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SakaiSecondaryButton(label: 'Cancel'),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SakaiSecondaryButton(
              label: 'Cancel',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      expect(pressed, isTrue);
    });
  });
}
