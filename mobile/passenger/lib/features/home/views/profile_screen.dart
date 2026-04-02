import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Some custom theme colors based on Stitch mapping not in tokens immediately
    final dangerColor = theme.colorScheme.error;
    final warningColor = Colors.amber;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Profile Centered Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.outlineVariant, width: 2),
                      color: theme.colorScheme.surfaceContainerHighest,
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAtlK44lWfSLPbi8VhGSIlBacxPROicD1DLbpLDcDlcdaTqs1A2Bn7E9OiH5-dawEyDMxehLnPG44wHHdgZgFYKCekp4WXcCcbcE5EyMIrE62RAc2ifnBiR3AFB886xjWu5VoGHOwjTVfL6qzeKluimXxU_RYtmLrA7bBAZVhN1kmZCXD42usLXwIutgcUf7eiusWL4SyYykkMgW8BFbzm4P2RpEgftDpM1z1qtPrBONdbgSYhM90rvkDF0-9k4qVPw5coACeuUd0g'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                    ),
                    child: Icon(Icons.edit, size: 16, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                'Andrew Santos',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '+63 917 123 4567',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Rating Badge
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '4.8',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.star, size: 16, color: warningColor),
                    const SizedBox(width: 6),
                    Text(
                      'Rider Rating',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const Divider(thickness: 8, height: 8),

        // Payment Methods
        _buildSectionHeader(context, 'Payment Methods'),
        _buildCustomPaymentTile(
          context,
          icon: Icons.account_balance_wallet,
          iconBgColor: Colors.blue.withValues(alpha: 0.1),
          iconColor: Colors.blue,
          title: 'GCash',
          subtitle: '**** 4567',
          trailingValue: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'PRIMARY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        ),
        const Divider(indent: 64, height: 1),
        _buildCustomPaymentTile(
          context,
          icon: Icons.credit_card,
          iconBgColor: Colors.purple.withValues(alpha: 0.1),
          iconColor: Colors.purple,
          title: 'Visa ending in 8890',
          subtitle: 'Expires 12/26',
        ),
        const Divider(indent: 64, height: 1),
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), style: BorderStyle.solid),
                  ),
                  child: Icon(Icons.add, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Text(
                  'Add payment method',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Divider(thickness: 8, height: 8),

        // Safety
        _buildSectionHeader(context, 'Safety'),
        _buildStandardTile(context, Icons.emergency_share, 'Emergency Contacts'),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(context, Icons.notifications_active, 'Notifications'),
        
        const Divider(thickness: 8, height: 8),

        // General
        _buildSectionHeader(context, 'General'),
        _buildStandardTile(context, Icons.language, 'Language', trailingValue: const Text('English', style: TextStyle(fontSize: 14))),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(context, Icons.description, 'Terms of Service'),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(context, Icons.shield, 'Privacy Policy'),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(context, Icons.help_outline, 'Help Center'),

        // Footer / Logout
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: dangerColor,
              side: BorderSide(color: dangerColor.withValues(alpha: 0.3)),
              backgroundColor: dangerColor.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        Center(
          child: Text(
            'Version 2.4.0 (Build 192)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCustomPaymentTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailingValue,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (trailingValue != null) ...[
              trailingValue,
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardTile(BuildContext context, IconData icon, String title, {Widget? trailingValue}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
            if (trailingValue != null) ...[
              DefaultTextStyle(
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                child: trailingValue,
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
