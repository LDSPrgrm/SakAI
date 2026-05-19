import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../../app/routes.dart';
import '../../../notifications/view_models/notifications_notifier.dart';
import '../../../profile/view_models/profile_view_model.dart';

class HomeGreetingHeader extends ConsumerStatefulWidget {
  const HomeGreetingHeader({super.key});

  @override
  ConsumerState<HomeGreetingHeader> createState() => _HomeGreetingHeaderState();
}

class _HomeGreetingHeaderState extends ConsumerState<HomeGreetingHeader> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final profile = ref.read(profileNotifierProvider);
      if (profile.profile == null && profile.status == ProfileStatus.initial) {
        ref.read(profileNotifierProvider.notifier).loadProfile();
      }
    });
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = ref.watch(profileNotifierProvider).profile;
    final unread = ref.watch(notificationsNotifierProvider).unreadCount;

    final displayName = profile?.name.split(' ').first ?? 'there';
    final initials = profile?.initials;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
      child: Row(
        children: [
          SakaiAvatar(initials: initials, size: SakaiAvatarSize.md),
          SizedBox(width: tokens.spaceMd),
          Expanded(
            child: AnimatedSwitcher(
              duration: tokens.durationFast,
              child: Column(
                key: ValueKey(displayName),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeGreeting(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: unread > 0
                ? 'Notifications, $unread unread'
                : 'Notifications',
            child: SakaiTactile(
              onTap: () => context.push(Routes.notifications),
              child: Container(
                width: tokens.touchTargetMin,
                height: tokens.touchTargetMin,
                alignment: Alignment.center,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: tokens.iconMd,
                      color: scheme.onSurface,
                    ),
                    if (unread > 0)
                      Positioned(
                        key: const Key('home_notif_badge'),
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spaceXs,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.error,
                            borderRadius: BorderRadius.circular(
                              tokens.radiusFull,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onError,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
