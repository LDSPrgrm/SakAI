import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/availability_notifier.dart';

class AvailabilitySettingsScreen extends ConsumerWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityNotifierProvider);
    final notifier = ref.read(availabilityNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SakaiAppBar(title: Text('Availability')),
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : state.backendUnavailable != null
                ? const ComingSoonState(feature: 'Availability windows')
                : ListView(
                padding: EdgeInsets.all(t.spaceMd),
                children: [
                  if (state.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: t.spaceSm),
                      child: Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  SakaiSurfaceCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto go online'),
                      subtitle: const Text(
                        'Automatically go online at your preferred hours.',
                      ),
                      value: state.prefs.autoGoOnline,
                      onChanged: (v) => notifier.update(
                        state.prefs.copyWith(autoGoOnline: v),
                      ),
                    ),
                  ),
                  if (state.prefs.autoGoOnline) ...[
                    SizedBox(height: t.spaceSm),
                    SakaiSurfaceCard(
                      child: Column(
                        children: [
                          _HourPicker(
                            label: 'Start',
                            value: state.prefs.startHour ?? 7,
                            onChanged: (v) => notifier.update(
                              state.prefs.copyWith(startHour: v),
                            ),
                          ),
                          _HourPicker(
                            label: 'End',
                            value: state.prefs.endHour ?? 19,
                            onChanged: (v) => notifier.update(
                              state.prefs.copyWith(endHour: v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: t.spaceLg),
                  SakaiPrimaryButton(
                    label: state.saving ? 'Saving…' : 'Save',
                    onPressed: state.saving ? null : notifier.save,
                  ),
                ],
              ),
      ),
    );
  }
}

class _HourPicker extends StatelessWidget {
  const _HourPicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: DropdownButton<int>(
        value: value,
        items: List.generate(24, (i) => i)
            .map(
              (h) => DropdownMenuItem(
                value: h,
                child: Text('${h.toString().padLeft(2, '0')}:00'),
              ),
            )
            .toList(),
        onChanged: (v) => v == null ? null : onChanged(v),
      ),
    );
  }
}
