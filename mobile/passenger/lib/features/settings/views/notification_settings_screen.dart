import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Notification preferences stored in SharedPreferences.
class _NotificationPrefs {
  static const String _prefix = 'notification_';
  static const String rideUpdates = '${_prefix}ride_updates';
  static const String promotions = '${_prefix}promotions';
  static const String safetyAlerts = '${_prefix}safety_alerts';
  static const String paymentNotifications = '${_prefix}payment_notifications';
}

/// Notification settings screen allowing users to toggle notification preferences.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _rideUpdates = true;
  bool _promotions = false;
  bool _safetyAlerts = true;
  bool _paymentNotifications = true;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rideUpdates = prefs.getBool(_NotificationPrefs.rideUpdates) ?? true;
      _promotions = prefs.getBool(_NotificationPrefs.promotions) ?? false;
      _safetyAlerts = prefs.getBool(_NotificationPrefs.safetyAlerts) ?? true;
      _paymentNotifications =
          prefs.getBool(_NotificationPrefs.paymentNotifications) ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SakaiSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Choose which notifications you want to receive. '
                          'You can always change these settings later.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader(context, 'Ride Notifications'),
                _buildSwitchTile(
                  context,
                  Icons.directions_car,
                  'Ride Updates',
                  'Status changes, driver arrival, and trip updates',
                  _rideUpdates,
                  (value) {
                    setState(() => _rideUpdates = value);
                    _savePreference(_NotificationPrefs.rideUpdates, value);
                  },
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  context,
                  Icons.payment_outlined,
                  'Payment Notifications',
                  'Receipts, refunds, and payment method updates',
                  _paymentNotifications,
                  (value) {
                    setState(() => _paymentNotifications = value);
                    _savePreference(
                      _NotificationPrefs.paymentNotifications,
                      value,
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionHeader(context, 'Marketing'),
                _buildSwitchTile(
                  context,
                  Icons.local_offer_outlined,
                  'Promotions',
                  'Discounts, special offers, and rewards',
                  _promotions,
                  (value) {
                    setState(() => _promotions = value);
                    _savePreference(_NotificationPrefs.promotions, value);
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionHeader(context, 'Safety'),
                _buildSwitchTile(
                  context,
                  Icons.security_outlined,
                  'Safety Alerts',
                  'Important safety information and emergency alerts',
                  _safetyAlerts,
                  (value) {
                    setState(() => _safetyAlerts = value);
                    _savePreference(_NotificationPrefs.safetyAlerts, value);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SakaiSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
