import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/geocoding_service.dart';
import '../view_models/destination_sheet_view_model.dart';

enum LocationSearchMode { pickup, destination }

/// Bottom sheet that lets the rider type a destination address.
///
/// Returns a [RideLocation] via [onLocationConfirmed] or null on dismiss.
///
/// All geocoding logic lives in [DestinationSheetViewModel]; this widget
/// is pure View — it reads state and forwards events to the VM.
class DestinationSheet extends StatefulWidget {
  const DestinationSheet({
    super.key,
    required this.mode,
    required this.onLocationConfirmed,
    required this.viewModel,
  });

  final LocationSearchMode mode;
  final ValueChanged<RideLocation> onLocationConfirmed;
  final DestinationSheetViewModel viewModel;

  @override
  State<DestinationSheet> createState() => _DestinationSheetState();
}

class _DestinationSheetState extends State<DestinationSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final result = await widget.viewModel.geocodeAndConfirm(_ctrl.text);
    if (result != null && mounted) {
      widget.onLocationConfirmed(result);
      Navigator.of(context).pop();
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
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          return Column(
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
                widget.mode == LocationSearchMode.pickup
                    ? 'Where from?'
                    : 'Where to?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: tokens.spaceMd),
              SakaiTextField(
                controller: _ctrl,
                label: widget.mode == LocationSearchMode.pickup
                    ? 'Pickup Location'
                    : 'Destination',
                hint: widget.mode == LocationSearchMode.pickup
                    ? 'e.g. 123 Main St'
                    : 'e.g. SM Mall of Asia, Pasay',
                prefixIcon: Icon(
                  widget.mode == LocationSearchMode.pickup
                      ? Icons.my_location
                      : Icons.place_outlined,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => vm.clearError(),
              ),
              if (vm.errorMessage != null) ...[
                SizedBox(height: tokens.spaceXs),
                Text(
                  vm.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                ),
              ],
              SizedBox(height: tokens.spaceMd),
              SakaiPrimaryButton(
                label: vm.geocoding
                    ? 'Looking up…'
                    : (widget.mode == LocationSearchMode.pickup
                        ? 'Confirm pickup'
                        : 'Confirm destination'),
                icon: Icons.arrow_forward,
                onPressed: vm.geocoding ? null : _confirm,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper to show [DestinationSheet] as a modal bottom sheet.
///
/// Creates a fresh [DestinationSheetViewModel] (scoped to the sheet lifetime).
Future<void> showLocationSearchSheet(
  BuildContext context, {
  required LocationSearchMode mode,
  required ValueChanged<RideLocation> onLocationConfirmed,
}) {
  final vm = DestinationSheetViewModel(GeocodingService());
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
      viewModel: vm,
    ),
  ).whenComplete(vm.dispose);
}
