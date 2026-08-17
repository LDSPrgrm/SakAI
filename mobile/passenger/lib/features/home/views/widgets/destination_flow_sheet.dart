import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';
import '../../view_models/home_notifier.dart';
import '../../repositories/geocoding_service.dart';

/// A sleek, dedicated bottom sheet for location selection.
class DestinationFlowSheet extends ConsumerStatefulWidget {
  const DestinationFlowSheet({super.key});

  @override
  ConsumerState<DestinationFlowSheet> createState() =>
      _DestinationFlowSheetState();
}

class _DestinationFlowSheetState extends ConsumerState<DestinationFlowSheet> {
  final _pickupController = TextEditingController();
  final _destController = TextEditingController();
  bool _isSearching = false;
  List<String> _suggestions = [];
  bool _editingPickup = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(homeNotifierProvider);
    _pickupController.text = state.pickup?.address ?? 'Current Location';
    _destController.text = state.destination?.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(scheme),
          const SizedBox(height: 20),
          _buildInput('From', _pickupController, scheme, true),
          const SizedBox(height: 8),
          _buildInput('To', _destController, scheme, false),
          const SizedBox(height: 16),
          if (!_isSearching) ...[
            _buildShortcut(context, Icons.home_rounded, 'Home', scheme),
            _buildShortcut(context, Icons.work_rounded, 'Work', scheme),
          ] else
            _buildSuggestions(scheme),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme scheme) => Container(
    width: 40,
    height: 5,
    decoration: BoxDecoration(
      color: scheme.outlineVariant,
      borderRadius: BorderRadius.circular(2.5),
    ),
  );

  Widget _buildInput(
    String label,
    TextEditingController controller,
    ColorScheme scheme,
    bool isPickup,
  ) => TextField(
    controller: controller,
    autofocus: !isPickup,
    decoration: InputDecoration(
      hintText: label,
      prefixIcon: Icon(isPickup ? Icons.my_location : Icons.place),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
    onTap: () => setState(() => _editingPickup = isPickup),
    onChanged: (val) {
      setState(() => _isSearching = val.isNotEmpty);
      if (val.isNotEmpty) _fetchSuggestions(val);
    },
  );

  void _fetchSuggestions(String query) async {
    final results = await GeocodingService().getSuggestions(query);
    if (mounted) setState(() => _suggestions = results);
  }

  Widget _buildSuggestions(ColorScheme scheme) => Expanded(
    child: ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, i) => ListTile(
        leading: const Icon(Icons.place),
        title: Text(_suggestions[i]),
        onTap: () {
          if (_editingPickup) {
            ref
                .read(homeNotifierProvider.notifier)
                .setPickupFromString(_suggestions[i]);
          } else {
            ref
                .read(homeNotifierProvider.notifier)
                .setDestinationFromString(_suggestions[i]);
          }
          Navigator.pop(context);
        },
      ),
    ),
  );

  Widget _buildShortcut(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme scheme,
  ) => ListTile(
    leading: Icon(icon, color: scheme.primary),
    title: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
    onTap: () => SakaiSnackBar.info(context, 'Selected $label'),
  );
}
