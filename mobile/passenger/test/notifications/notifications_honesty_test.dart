import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/notifications/models/app_notification.dart';
import 'package:passenger/features/notifications/views/notifications_screen.dart';
import 'package:passenger/features/notifications/view_models/notifications_notifier.dart';
import 'package:sakai_shared/sakai_shared.dart';

class _FakeNotificationsNotifier extends NotificationsNotifier {
  _FakeNotificationsNotifier(this._state);
  final NotificationsState _state;
  @override
  NotificationsState build() => _state;
}

Future<void> _pumpNotifications(
  WidgetTester tester, {
  required NotificationsState state,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsNotifierProvider.overrideWith(
          () => _FakeNotificationsNotifier(state),
        ),
      ],
      child: MaterialApp(
        theme: SakaiTheme.light(SakaiThemeConfig.passenger()),
        home: const NotificationsScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('backend-unavailable shows Coming soon, not mock messages', (
    tester,
  ) async {
    await _pumpNotifications(
      tester,
      state: const NotificationsState(
        backendUnavailable: BackendUnavailableException(
          feature: 'notifications',
        ),
      ),
    );

    expect(find.byType(ComingSoonState), findsOneWidget);
    expect(find.textContaining('Mid-Autumn'), findsNothing);
    expect(find.textContaining('₱120.00'), findsNothing);
  });

  testWidgets('loading shows spinner, not mock messages', (tester) async {
    await _pumpNotifications(
      tester,
      state: const NotificationsState(loading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Mid-Autumn'), findsNothing);
    expect(find.textContaining('₱120.00'), findsNothing);
  });

  testWidgets('empty state shown when backend returns no items, not mock messages', (
    tester,
  ) async {
    await _pumpNotifications(
      tester,
      state: const NotificationsState(items: []),
    );

    expect(find.byType(SakaiEmptyState), findsOneWidget);
    expect(find.textContaining('Mid-Autumn'), findsNothing);
    expect(find.textContaining('₱120.00'), findsNothing);
  });

  testWidgets('real items render via the real notification tile, not mock messages', (
    tester,
  ) async {
    await _pumpNotifications(
      tester,
      state: NotificationsState(
        items: [
          AppNotification(
            id: '1',
            title: 'Ride confirmed',
            body: 'Your driver is on the way.',
            createdAt: DateTime(2026, 6, 19, 9),
          ),
        ],
      ),
    );

    expect(find.text('Ride confirmed'), findsOneWidget);
    expect(find.textContaining('Mid-Autumn'), findsNothing);
    expect(find.textContaining('₱120.00'), findsNothing);
  });
}
