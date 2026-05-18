import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kSupportPhone = '+639171234567';
const String _kSupportEmail = 'driver-support@sakai.app';

class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await canLaunchUrl(uri).catchError((_) => false);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open ${uri.scheme} app on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    final faqs = const [
      ('How are earnings calculated?',
          'Earnings = base fare + per-km + per-min + tips, minus platform fee. View the per-ride breakdown on the Earnings screen.'),
      ('Why am I not getting ride requests?',
          'Make sure you\'re online, your documents are approved, and your location is up to date.'),
      ('How do I update my vehicle?',
          'Go to Profile → Vehicle Info and tap Edit. Some changes may require re-approval.'),
      ('How do I cash out?',
          'Payouts run on a weekly cycle. Check the Earnings → Payouts tab for the next payout date.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Driver support')),
      body: ListView(
        padding: EdgeInsets.all(t.spaceMd),
        children: [
          Text('Frequently asked', style: theme.textTheme.titleLarge),
          SizedBox(height: t.spaceSm),
          for (final (q, a) in faqs) ...[
            SakaiSurfaceCard(
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.only(bottom: t.spaceSm),
                title: Text(q, style: theme.textTheme.titleMedium),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(a, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
            SizedBox(height: t.spaceXs),
          ],
          SizedBox(height: t.spaceLg),
          Text('Still need help?', style: theme.textTheme.titleLarge),
          SizedBox(height: t.spaceSm),
          SakaiSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone),
                  title: const Text('Call driver hotline'),
                  subtitle: const Text('Available 24/7'),
                  onTap: () => _launch(
                    context,
                    Uri(scheme: 'tel', path: _kSupportPhone),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email $_kSupportEmail'),
                  onTap: () => _launch(
                    context,
                    Uri(scheme: 'mailto', path: _kSupportEmail),
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
