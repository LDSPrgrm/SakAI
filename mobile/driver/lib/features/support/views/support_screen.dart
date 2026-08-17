import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kSupportPhone = '+639171234567';
const String _kSupportEmail = 'driver-support@sakai.app';

/// Driver support entry point. Owns the driver-specific FAQ copy and the
/// tel/mailto launch handlers; the layout itself lives in the shared
/// [SakaiSupportScreen].
class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  static const List<SakaiSupportFaq> _faqs = [
    SakaiSupportFaq(
      question: 'How are earnings calculated?',
      answer:
          'Earnings = base fare + per-km + per-min + tips, minus platform fee. View the per-ride breakdown on the Earnings screen.',
    ),
    SakaiSupportFaq(
      question: 'Why am I not getting ride requests?',
      answer:
          "Make sure you're online, your documents are approved, and your location is up to date.",
    ),
    SakaiSupportFaq(
      question: 'How do I update my vehicle?',
      answer:
          'Go to Profile → Vehicle Info and tap Edit. Some changes may require re-approval.',
    ),
    SakaiSupportFaq(
      question: 'How do I cash out?',
      answer:
          'Payouts run on a weekly cycle. Check the Earnings → Payouts tab for the next payout date.',
    ),
  ];

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await canLaunchUrl(uri).catchError((_) => false);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    SakaiSnackBar.error(
      context,
      'Could not open ${uri.scheme} app on this device.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SakaiSupportScreen(
      title: 'Driver support',
      faqs: _faqs,
      contactActionsHeading: 'Still need help?',
      contactActions: [
        SakaiSupportContactAction(
          icon: Icons.phone,
          title: 'Call driver hotline',
          subtitle: 'Available 24/7',
          onTap: () =>
              _launch(context, Uri(scheme: 'tel', path: _kSupportPhone)),
        ),
        SakaiSupportContactAction(
          icon: Icons.email_outlined,
          title: 'Email $_kSupportEmail',
          onTap: () =>
              _launch(context, Uri(scheme: 'mailto', path: _kSupportEmail)),
        ),
      ],
    );
  }
}
