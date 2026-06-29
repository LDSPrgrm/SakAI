import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../settings/providers/sos_safety_prefs.dart';
import '../view_models/support_view_model.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I request a ride?',
      'answer':
          'Open the app and tap the "Where to?" search bar. Enter your destination, confirm your pickup location, select your ride type, and tap "Request Ride".',
    },
    {
      'question': 'How does pricing work?',
      'answer':
          'Pricing is calculated based on distance, estimated time, and current demand. You will see an estimated fare before confirming your ride.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept credit/debit cards, digital wallets, and cash where applicable. You can manage this in Settings > Payment Methods.',
    },
    {
      'question': 'How do I cancel a ride?',
      'answer':
          'While waiting for a driver, tap "Cancel" on the waiting screen. Cancellation fees may apply if the driver is already en route.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);
    final vm = ref.watch(supportViewModelProvider);

    ref.listen<SupportState>(supportViewModelProvider.select((v) => v.state), (
      previous,
      next,
    ) {
      if (next.status == SupportStatus.success && next.submitted) {
        SakaiSnackBar.success(
          context,
          'Support ticket submitted successfully!',
        );
        vm.resetState();
      } else if (next.status == SupportStatus.error && next.error != null) {
        SakaiSnackBar.error(context, next.error!);
      }
    });

    return SakaiScreenScaffold(
      title: 'Support & Help',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'FAQs', icon: Icon(Icons.help_outline)),
              Tab(text: 'Contact Us', icon: Icon(Icons.email_outlined)),
            ],
          ),
          SizedBox(height: tokens.spaceMd),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaqTab(tokens, theme),
                _buildContactTab(tokens, theme, vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab(SakaiDesignTokens tokens, ThemeData theme) {
    return ListView.separated(
      itemCount: _faqs.length,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spaceSm),
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        final isExpanded = _expandedIndex == index;

        return SakaiSurfaceCard(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      faq['question']!,
                      style: theme.textTheme.titleMedium?.copyWith(
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
                SizedBox(height: tokens.spaceSm),
                Text(
                  faq['answer']!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactTab(
    SakaiDesignTokens tokens,
    ThemeData theme,
    SupportViewModel vm,
  ) {
    final state = vm.state;
    final isSubmitting = state.status == SupportStatus.submitting;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a Message',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spaceSm),
                Text(
                  'Have an issue? Fill out the form below and our team will get back to you as soon as possible.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.spaceLg),
                SakaiTextField(
                  label: 'Subject',
                  hint: 'e.g., Payment issue, App crash',
                  onChanged: vm.updateSubject,
                  enabled: !isSubmitting,
                ),
                SizedBox(height: tokens.spaceMd),
                SakaiTextField(
                  label: 'Message',
                  hint: 'Describe your issue in detail...',
                  maxLines: 5,
                  onChanged: vm.updateMessage,
                  enabled: !isSubmitting,
                ),
                SizedBox(height: tokens.spaceXl),
                Divider(color: theme.colorScheme.outlineVariant),
                SizedBox(height: tokens.spaceLg),
                _buildEmergencySos(tokens, theme, vm),
              ],
            ),
          ),
        ),
        SakaiBottomActionBar(
          actions: [
            SakaiPrimaryButton(
              label: isSubmitting ? 'Submitting…' : 'Submit Ticket',
              onPressed: vm.isValid && !isSubmitting ? vm.submitTicket : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmergencySos(
    SakaiDesignTokens tokens,
    ThemeData theme,
    SupportViewModel vm,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: tokens.spaceSm),
              Text(
                'Emergency SOS',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            'If you feel unsafe during an active ride, use the SOS feature to alert emergency contacts and SakAI response teams.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          SakaiSecondaryButton(
            label: 'Trigger SOS',
            onPressed: () => _showSosDialog(context, vm),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context, SupportViewModel vm) {
    final reasonController = TextEditingController();
    final prefs = ref.read(sosSafetyPrefsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Emergency SOS?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will alert SakAI Trust & Safety and your emergency contacts. '
                'Use only when you feel unsafe — false triggers may slow real responses.',
              ),
              const SizedBox(height: 16),
              const _ConsentSummary(),
              const SizedBox(height: 8),
              _PrivacyOptInRow(
                label: 'Ambient audio (60s)',
                optedIn: prefs.ambientAudioOptIn,
              ),
              _PrivacyOptInRow(
                label: 'Live location streaming',
                optedIn: prefs.liveLocationOptIn,
              ),
              _PrivacyOptInRow(
                label: 'Scene photo prompt',
                optedIn: prefs.photoOptIn,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push(Routes.settingsSosSafety);
                },
                child: Text(
                  'Change opt-ins',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              vm.triggerSOS('mock-active-ride', reasonController.text);
            },
            child: const Text('TRIGGER'),
          ),
        ],
      ),
    );
  }
}

class _ConsentSummary extends StatelessWidget {
  const _ConsentSummary();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Per your privacy settings, the following will be collected during this incident:',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _PrivacyOptInRow extends StatelessWidget {
  const _PrivacyOptInRow({required this.label, required this.optedIn});

  final String label;
  final bool optedIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            optedIn ? Icons.check_circle : Icons.do_not_disturb_on_outlined,
            size: 16,
            color: optedIn
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label — ${optedIn ? 'enabled' : 'off'}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
