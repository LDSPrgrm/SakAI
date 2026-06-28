import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/app_notification.dart';
import '../view_models/notifications_notifier.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsNotifierProvider);
    final notifier = ref.read(notificationsNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: notifier.markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: _body(context, state, notifier, t),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    NotificationsState state,
    NotificationsNotifier notifier,
    SakaiDesignTokens t,
  ) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.backendUnavailable != null) {
      return const ComingSoonState(feature: 'notifications');
    }
    if (state.errorMessage != null) {
      return SakaiEmptyState(
        icon: Icons.error_outline,
        title: 'Couldn\'t load notifications',
        message: state.errorMessage,
        primaryLabel: 'Retry',
        onPrimary: notifier.load,
      );
    }
    if (state.items.isEmpty) {
      return const SakaiEmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications yet',
        message: 'Updates about your rides and account will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: t.spaceSm),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => SizedBox(height: t.spaceXs),
      itemBuilder: (context, i) {
        final n = state.items[i];
        return _Tile(n, onTap: () => notifier.markRead(n.id));
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.n, {required this.onTap});
  final AppNotification n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    return SakaiSurfaceCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!n.read)
            Container(
              margin: EdgeInsets.only(top: t.spaceXs, right: t.spaceSm),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: theme.textTheme.titleMedium),
                SizedBox(height: t.spaceXs),
                Text(n.body, style: theme.textTheme.bodyMedium),
                SizedBox(height: t.spaceXs),
                Text(
                  DateFormat.yMMMd().add_jm().format(n.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
