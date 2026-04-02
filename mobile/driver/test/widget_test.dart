import 'package:flutter_test/flutter_test.dart';

import 'package:driver/main.dart';

void main() {
  testWidgets('app builds with shared theme', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverApp());
    expect(find.textContaining('Driver workspace'), findsOneWidget);
  });
}
