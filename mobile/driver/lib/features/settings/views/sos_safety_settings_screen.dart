import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../providers/sos_safety_prefs.dart';

/// Driver-side SOS & Safety preferences. Mirrors the passenger app's
/// screen with copy adjusted for the driver's perspective (you may be
/// the receiver of a passenger SOS, not just the trigger).
class SosSafetySettingsScreen extends ConsumerWidget {
  const SosSafetySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    final prefs = ref.watch(sosSafetyPrefsProvider);
    final notifier = ref.read(sosSafetyPrefsProvider.notifier);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('SOS & Safety'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: prefs.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(t.spaceMd),
              children: [
                SakaiSurfaceCard(
                  padding: EdgeInsets.all(t.spaceMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: t.spacing12),
                      Expanded(
                        child: Text(
                          'Sakai never records or shares your location, audio, '
                          'or photos unless you explicitly opt in below. These '
                          'apply BOTH when you trigger an SOS and when a '
                          'passenger triggers one during your ride.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: t.spaceMd),
                _SwitchTile(
                  icon: Icons.mic_outlined,
                  title: 'Ambient audio during SOS',
                  subtitle:
                      'Records cabin audio for up to 60 seconds when an SOS '
                      'is active. Uploaded encrypted. OFF by default.',
                  value: prefs.ambientAudioOptIn,
                  onChanged: notifier.setAmbientAudio,
                ),
                _SwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Live location during SOS',
                  subtitle:
                      'Stream GPS to Sakai Trust & Safety while the incident '
                      'is open. Disabled means support sees only the trigger '
                      'location.',
                  value: prefs.liveLocationOptIn,
                  onChanged: notifier.setLiveLocation,
                ),
                _SwitchTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Allow scene photo upload',
                  subtitle:
                      'Allows the app to prompt for a scene photo during an '
                      'active incident.',
                  value: prefs.photoOptIn,
                  onChanged: notifier.setPhoto,
                ),
                SizedBox(height: t.spaceLg),
                Text(
                  'Consent & Data Use',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: t.spaceSm),
                Text(
                  'Recordings, location pings, and photos collected during a '
                  'safety incident are retained for 90 days and used solely '
                  'for incident investigation. They are encrypted at rest '
                  'and accessible only to Sakai Trust & Safety staff. You '
                  'may request deletion at any time via support.',
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
    final t = SakaiDesignTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.spaceXs),
      child: SakaiSurfaceCard(
        padding: EdgeInsets.symmetric(
          horizontal: t.spaceMd,
          vertical: t.spaceSm,
        ),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: value,
          onChanged: onChanged,
          title: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurface),
              SizedBox(width: t.spacing12),
              Expanded(child: Text(title)),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(
              top: t.spaceXs,
              left: t.iconMd + t.spacing12,
            ),
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
