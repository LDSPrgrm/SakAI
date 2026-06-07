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
      appBar: AppBar(
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
    if (state.errorMessage != null) {
      return SakaiEmptyState(
        icon: Icons.error_outline,
        title: 'Couldn\'t load notifications',
        message: state.errorMessage,
        primaryLabel: 'Retry',
        onPrimary: notifier.load,
      );
    }

    final List<Map<String, dynamic>> inboxMessages = [
      {
        'title': '🥮 Celebrate Mid-Autumn Festival!',
        'body': 'Enjoy 25% off all rides back home from Sep 15 to Sep 18. Use code MIDAUTUMN25.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isUnread': true,
        'icon': Icons.celebration_rounded,
        'iconColor': Colors.purple,
      },
      {
        'title': 'Ride Receipt - Trip #8492',
        'body': 'Your trip with Driver Juan is complete. Total fare was ₱120.00. Thank you for riding with SakAI!',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isUnread': false,
        'icon': Icons.receipt_long_rounded,
        'iconColor': Colors.green,
      },
      {
        'title': 'Safety Update',
        'body': 'We have updated our terms of service to enhance ride-sharing safety protocols. Learn more here.',
        'time': DateTime.now().subtract(const Duration(days: 3)),
        'isUnread': false,
        'icon': Icons.security_rounded,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Scheduled Maintenance',
        'body': 'Our services will be down for 30 minutes on Sunday at 2 AM for system upgrades.',
        'time': DateTime.now().subtract(const Duration(days: 5)),
        'isUnread': false,
        'icon': Icons.build_rounded,
        'iconColor': Colors.orange,
      },
      {
        'title': 'Unlock Premium Rewards!',
        'body': 'You are only 2 rides away from earning your Gold status badge. Keep riding!',
        'time': DateTime.now().subtract(const Duration(days: 7)),
        'isUnread': false,
        'icon': Icons.stars_rounded,
        'iconColor': Colors.amber,
      },
      {
        'title': 'Rate your driver',
        'body': 'How was your ride with Driver Juan? Tap here to leave a rating and help us improve.',
        'time': DateTime.now().subtract(const Duration(minutes: 1)),
        'isUnread': true,
        'icon': Icons.star_rounded,
        'iconColor': Colors.yellow.shade800,
      },
    ];

    final List<dynamic> allNotifications = [
      ...inboxMessages.map((m) => {
        'title': m['title'],
        'body': m['body'],
        'time': m['time'],
        'isUnread': m['isUnread'],
        'icon': m['icon'],
        'iconColor': m['iconColor'],
        'isInbox': true,
      }),
      ...state.items.map((n) => {
        'title': n.title,
        'body': n.body,
        'time': n.createdAt,
        'isUnread': !n.read,
        'id': n.id,
        'isInbox': false,
      }),
    ];

    allNotifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    if (allNotifications.isEmpty) {
      return SakaiEmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications yet',
        message: 'Updates about your rides and account will appear here.',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: t.spaceSm),
      itemCount: allNotifications.length,
      separatorBuilder: (_, _) => SizedBox(height: t.spaceXs),
      itemBuilder: (context, i) {
        final n = allNotifications[i];
        if (n['isInbox'] == true) {
          return _InboxTile(
            title: n['title'],
            body: n['body'],
            time: _timeAgo(n['time']),
            isUnread: n['isUnread'],
            icon: n['icon'],
            iconColor: n['iconColor'],
          );
        }
        return _Tile(state.items.firstWhere((item) => item.id == n['id']), onTap: () => notifier.markRead(n['id']));
      },
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat.yMMMd().format(date);
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
  });
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    return SakaiSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: t.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600))),
                    Text(time, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                SizedBox(height: t.spaceXs),
                Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
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
