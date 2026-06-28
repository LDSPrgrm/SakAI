import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/home/views/widgets/home_greeting_header.dart';
import 'package:passenger/features/notifications/models/app_notification.dart';
import 'package:passenger/features/notifications/view_models/notifications_notifier.dart';
import 'package:passenger/features/profile/models/user_profile.dart';
import 'package:passenger/features/profile/view_models/profile_view_model.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '_test_helpers.dart';

class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._state);
  final ProfileState _state;
  @override
  ProfileState build() => _state;
}

class _FakeNotificationsNotifier extends NotificationsNotifier {
  _FakeNotificationsNotifier(this._state);
  final NotificationsState _state;
  @override
  NotificationsState build() => _state;
}

void main() {
  setUp(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = true;
  });
  tearDown(() {
    SakaiAnimatedBackdrop.debugDisableAnimations = false;
  });

  testWidgets('renders greeting with first name when profile loaded', (
    tester,
  ) async {
    final profile = UserProfileModel(
      id: 'u1',
      name: 'Ana Reyes',
      email: 'ana@example.com',
      role: 'passenger',
      createdAt: DateTime(2025, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileNotifierProvider.overrideWith(
            () => _FakeProfileNotifier(
              ProfileState(status: ProfileStatus.loaded, profile: profile),
            ),
          ),
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(const NotificationsState()),
          ),
        ],
        child: routedScaffold(child: const HomeGreetingHeader()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
  });

  testWidgets('shows unread badge when notifications.unreadCount > 0', (
    tester,
  ) async {
    final unreadItems = [
      AppNotification(
        id: 'n1',
        title: 'Hi',
        body: 'Test',
        createdAt: DateTime.now(),
        read: false,
      ),
      AppNotification(
        id: 'n2',
        title: 'Hi',
        body: 'Test',
        createdAt: DateTime.now(),
        read: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileNotifierProvider.overrideWith(
            () => _FakeProfileNotifier(
              const ProfileState(status: ProfileStatus.loaded),
            ),
          ),
          notificationsNotifierProvider.overrideWith(
            () => _FakeNotificationsNotifier(
              NotificationsState(items: unreadItems),
            ),
          ),
        ],
        child: routedScaffold(child: const HomeGreetingHeader()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_notif_badge')), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
