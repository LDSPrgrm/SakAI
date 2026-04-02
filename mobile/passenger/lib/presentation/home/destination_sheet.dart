import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

enum LocationSearchMode { pickup, destination }

/// Bottom sheet that lets the rider type a destination address.
///
/// Returns a [RideLocation] via [onLocationConfirmed] or null on dismiss.
class DestinationSheet extends StatefulWidget {
  const DestinationSheet({
    super.key,
    required this.mode,
    required this.onLocationConfirmed,
  });

  final LocationSearchMode mode;
  final ValueChanged<RideLocation> onLocationConfirmed;

  @override
  State<DestinationSheet> createState() => _DestinationSheetState();
}

class _DestinationSheetState extends State<DestinationSheet> {
  final _ctrl = TextEditingController();
  bool _geocoding = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final query = _ctrl.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Please enter a destination.');
      return;
    }
    setState(() {
      _geocoding = true;
      _error = null;
    });
    try {
      final dio = Dio();
      const apiKey = String.fromEnvironment('MAPS_API_KEY');
      
      if (apiKey.isEmpty) {
        setState(() => _error = 'Configuration Error: Missing API key. Did you run via run-mobile.sh?');
        return;
      }
      
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': query,
          'key': apiKey,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String?;
      
      if (status != 'OK' || (data['results'] as List?)?.isEmpty == true) {
        setState(() => _error = 'Address not found. Try being more specific.');
        return;
      }

      final firstResult = (data['results'] as List).first as Map<String, dynamic>;
      final geometry = firstResult['geometry'] as Map<String, dynamic>;
      final location = geometry['location'] as Map<String, dynamic>;
      
      final lat = (location['lat'] as num).toDouble();
      final lng = (location['lng'] as num).toDouble();
      final formattedAddress = firstResult['formatted_address'] as String? ?? query;

      final dest = RideLocation(
        lat: lat,
        lng: lng,
        address: formattedAddress, // We now use the exact Google Maps address string
      );
      widget.onLocationConfirmed(dest);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _error = 'Could not look up that address. Try again.');
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = SakaiDesignTokens.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spaceLg,
        right: tokens.spaceLg,
        top: tokens.spaceMd,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: tokens.spaceMd),
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.mode == LocationSearchMode.pickup ? 'Where from?' : 'Where to?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: tokens.spaceMd),
          SakaiTextField(
            controller: _ctrl,
            label: widget.mode == LocationSearchMode.pickup ? 'Pickup Location' : 'Destination',
            hint: widget.mode == LocationSearchMode.pickup
                ? 'e.g. 123 Main St'
                : 'e.g. SM Mall of Asia, Pasay',
            prefixIcon: Icon(
              widget.mode == LocationSearchMode.pickup ? Icons.my_location : Icons.place_outlined,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            SizedBox(height: tokens.spaceXs),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.error,
                  ),
            ),
          ],
          SizedBox(height: tokens.spaceMd),
          SakaiPrimaryButton(
            label: _geocoding
                ? 'Looking up…'
                : (widget.mode == LocationSearchMode.pickup ? 'Confirm pickup' : 'Confirm destination'),
            icon: Icons.arrow_forward,
            onPressed: _geocoding ? null : _confirm,
          ),
        ],
      ),
    );
  }
}

/// Helper to show [DestinationSheet] as a modal bottom sheet.
Future<void> showLocationSearchSheet(
  BuildContext context, {
  required LocationSearchMode mode,
  required ValueChanged<RideLocation> onLocationConfirmed,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DestinationSheet(
      mode: mode,
      onLocationConfirmed: onLocationConfirmed,
    ),
  );
}
