import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../providers/sos_safety_prefs.dart';

/// SOS & Safety preferences. Surfaces the privacy-sensitive opt-ins
/// required by RFC v2 §20 decision 3: ambient audio capture during an
/// active SOS is OPT-IN ONLY, defaulting to OFF, with the consent text
/// visible on the same screen as the toggle.
class SosSafetySettingsScreen extends ConsumerWidget {
  const SosSafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(sosSafetyPrefsProvider);
    final notifier = ref.read(sosSafetyPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS & Safety'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: prefs.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SakaiSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sakai never records or shares your location, audio, '
                          'or photos unless you explicitly opt in below. SOS '
                          'triggers always alert support staff and your '
                          'emergency contacts.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SwitchTile(
                  icon: Icons.mic_outlined,
                  title: 'Ambient audio during SOS',
                  subtitle:
                      'When you trigger SOS, your microphone records for up '
                      'to 60 seconds and uploads encrypted audio to Sakai '
                      'support. OFF by default.',
                  value: prefs.ambientAudioOptIn,
                  onChanged: notifier.setAmbientAudio,
                ),
                _SwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Live location during SOS',
                  subtitle:
                      'Stream your GPS coordinates to Sakai support while the '
                      'incident is open. Disabling means support sees only '
                      'the trigger location.',
                  value: prefs.liveLocationOptIn,
                  onChanged: notifier.setLiveLocation,
                ),
                _SwitchTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Allow scene photo upload',
                  subtitle:
                      'Lets the passenger app prompt for an optional photo '
                      'when the SOS is in progress.',
                  value: prefs.photoOptIn,
                  onChanged: notifier.setPhoto,
                ),
                const SizedBox(height: 24),
                Text(
                  'Consent & Data Use',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recordings, location pings, and photos collected during a '
                  'safety incident are retained for 90 days and used solely '
                  'for incident investigation. They are encrypted at rest and '
                  'accessible only to Sakai Trust & Safety staff. You may '
                  'request deletion at any time via support.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SakaiSurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: value,
          onChanged: onChanged,
          title: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurface),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4, left: 36),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
