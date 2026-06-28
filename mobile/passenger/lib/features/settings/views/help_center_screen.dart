import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// FAQ item data class.
class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

/// Help center screen with FAQ list and support contact option.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedIndex;

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I request a ride?',
      answer:
          'Open the app and tap the "Where to?" search bar. Enter your destination, '
          'confirm your pickup location, select your ride type, and tap "Request Ride". '
          'The app will match you with a nearby driver.',
    ),
    _FaqItem(
      question: 'How does pricing work?',
      answer:
          'Pricing is calculated based on distance, estimated time, and current demand. '
          'You will see an estimated fare before confirming your ride. Final charges may '
          'vary slightly based on route changes, traffic, or stops.',
    ),
    _FaqItem(
      question: 'What payment methods are accepted?',
      answer:
          'We accept credit/debit cards, digital wallets, and cash (where available). '
          'You can manage your payment methods in Settings > Payment Methods.',
    ),
    _FaqItem(
      question: 'How do I cancel a ride?',
      answer:
          'While waiting for a driver, tap the "Cancel" button on the waiting screen. '
          'Note: Cancellation fees may apply if the driver is already on their way. '
          'You can cancel an active ride through the ride screen, but fees may apply.',
    ),
    _FaqItem(
      question: 'How do I contact support?',
      answer:
          'You can contact support by tapping the "Contact Support" button below, '
          'which will open your email client. You can also reach us through the in-app '
          'chat during an active ride, or call our support hotline for urgent matters.',
    ),
  ];

  void _contactSupport() {
    // Placeholder: In production, this would open email or in-app chat.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text(
          'Support contact functionality will be available soon. '
          'For now, please email us at support@sakai.com.',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Help Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                final isExpanded = _expandedIndex == index;

                return SakaiSurfaceCard(
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              faq.question,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        Text(
                          faq.answer,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SakaiPrimaryButton(
              label: 'Contact Support',
              icon: Icons.support_agent,
              onPressed: _contactSupport,
            ),
          ),
        ],
      ),
    );
  }
}
