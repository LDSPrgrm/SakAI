import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    final messages = [
      _InboxMessage(
        title: '🥮 Celebrate Mid-Autumn Festival!',
        body: 'Enjoy 25% off all rides back home from Sep 15 to Sep 18. Use code MIDAUTUMN25.',
        time: '2 hours ago',
        isUnread: true,
        icon: Icons.celebration_rounded,
        iconColor: Colors.purple,
      ),
      _InboxMessage(
        title: 'Ride Receipt - Trip #8492',
        body: 'Your trip with Driver Juan is complete. Total fare was ₱120.00. Thank you for riding with SakAI!',
        time: 'Yesterday',
        isUnread: false,
        icon: Icons.receipt_long_rounded,
        iconColor: Colors.green,
      ),
      _InboxMessage(
        title: 'Safety Update',
        body: 'We have updated our terms of service to enhance ride-sharing safety protocols. Learn more here.',
        time: '3 days ago',
        isUnread: false,
        icon: Icons.security_rounded,
        iconColor: Colors.blue,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(tokens.spaceMd),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: msg.isUnread
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: msg.isUnread
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: msg.isUnread ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: msg.iconColor.withValues(alpha: 0.1),
                  child: Icon(msg.icon, color: msg.iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              msg.title,
                              style: TextStyle(
                                fontWeight:
                                    msg.isUnread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (msg.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg.body,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        msg.time,
                        style: TextStyle(
                          color: theme.colorScheme.outline,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InboxMessage {
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;

  _InboxMessage({
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
  });
}
