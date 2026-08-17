import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../settings/providers/sos_safety_prefs.dart';
import '../view_models/support_view_model.dart';

/// Passenger support entry point. Owns the passenger-specific FAQ copy,
/// ticket view model wiring, and the SOS consent dialog; the layout itself
/// lives in the shared [SakaiSupportScreen].
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  static const List<SakaiSupportFaq> _faqs = [
    SakaiSupportFaq(
      question: 'How do I request a ride?',
      answer:
          'Open the app and tap the "Where to?" search bar. Enter your destination, confirm your pickup location, select your ride type, and tap "Request Ride".',
    ),
    SakaiSupportFaq(
      question: 'How does pricing work?',
      answer:
          'Pricing is calculated based on distance, estimated time, and current demand. You will see an estimated fare before confirming your ride.',
    ),
    SakaiSupportFaq(
      question: 'What payment methods are accepted?',
      answer:
          'We accept credit/debit cards, digital wallets, and cash where applicable. You can manage this in Settings > Payment Methods.',
    ),
    SakaiSupportFaq(
      question: 'How do I cancel a ride?',
      answer:
          'While waiting for a driver, tap "Cancel" on the waiting screen. Cancellation fees may apply if the driver is already en route.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return SakaiSupportScreen(
      title: 'Support & Help',
      faqs: _faqs,
      ticketForm: SakaiSupportTicketForm(
        onSubjectChanged: vm.updateSubject,
        onMessageChanged: vm.updateMessage,
        onSubmit: vm.submitTicket,
        canSubmit: vm.isValid,
        isSubmitting: vm.state.status == SupportStatus.submitting,
      ),
      emergency: SakaiSupportEmergency(
        onTrigger: () => _showSosDialog(context, ref, vm),
      ),
    );
  }

  void _showSosDialog(BuildContext context, WidgetRef ref, SupportViewModel vm) {
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
