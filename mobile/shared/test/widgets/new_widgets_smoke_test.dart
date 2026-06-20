import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('SakaiStatusBadge renders for every status', (tester) async {
    for (final s in SakaiStatus.values) {
      await tester.pumpWidget(
        _wrap(SakaiStatusBadge(status: s, label: s.name)),
      );
      expect(find.text(s.name), findsOneWidget);
    }
  });

  testWidgets('SakaiCountdownChip renders + ticks', (tester) async {
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    await tester.pumpWidget(_wrap(SakaiCountdownChip(deadline: deadline)));
    expect(find.byType(SakaiCountdownChip), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    // Must not throw.
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('SakaiSkeleton.line + card render', (tester) async {
    await tester.pumpWidget(_wrap(Column(
      children: [
        SakaiSkeleton.line(width: 80),
        SakaiSkeleton.card(),
        SakaiSkeleton.circle(),
      ],
    )));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SakaiSkeleton), findsNWidgets(3));
  });

  testWidgets('SakaiSkeleton.list renders N items', (tester) async {
    await tester.pumpWidget(_wrap(SakaiSkeleton.list(itemCount: 3)));
    expect(find.byType(SakaiSkeleton), findsNWidgets(3));
  });

  testWidgets('SakaiSectionHeader shows title + trailing', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(SakaiSectionHeader(
      title: 'Recent',
      trailingLabel: 'See all',
      onTrailingTap: () => tapped = true,
    )));
    expect(find.text('Recent'), findsOneWidget);
    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });

  testWidgets('SakaiErrorState shows retry when onRetry set', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(SakaiErrorState(
      message: 'Could not load',
      onRetry: () => retried = true,
    )));
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Could not load'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('SakaiBottomActionBar lays out actions equally', (tester) async {
    await tester.pumpWidget(_wrap(Align(
      alignment: Alignment.bottomCenter,
      child: SakaiBottomActionBar(actions: [
        SakaiSecondaryButton(label: 'Decline', onPressed: () {}),
        SakaiPrimaryButton(label: 'Accept', onPressed: () {}),
      ]),
    )));
    expect(find.text('Decline'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
  });

  testWidgets('SakaiFareChip + SakaiRideTypeChip render', (tester) async {
    await tester.pumpWidget(_wrap(Column(children: const [
      SakaiFareChip(amount: '₱12.40', subtitle: 'estimate'),
      SakaiRideTypeChip(label: 'Standard', icon: Icons.directions_car, selected: true),
    ])));
    expect(find.text('₱12.40'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
  });
}
