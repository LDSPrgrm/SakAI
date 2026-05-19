import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';
import '../models/ride_type_option.dart';

class RideTypeSheet extends StatefulWidget {
  final List<RideTypeOption> options;
  final ValueChanged<VehicleType?> onTypeSelected;
  final VoidCallback onRequestRide;

  const RideTypeSheet({
    super.key,
    required this.options,
    required this.onTypeSelected,
    required this.onRequestRide,
  });

  @override
  State<RideTypeSheet> createState() => _RideTypeSheetState();
}

class _RideTypeSheetState extends State<RideTypeSheet> {
  VehicleType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose your ride',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Ride type list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final isSelected = _selectedType == option.type;
                    return ListTile(
                      leading: Icon(
                        option.type.icon,
                        color: isSelected ? theme.primaryColor : null,
                      ),
                      title: Text(option.type.displayName),
                      subtitle: Text('${option.availableDrivers} nearby'),
                      trailing: Text(
                        '\u20B1${option.estimatedFare.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.primaryColor : null,
                        ),
                      ),
                      selected: isSelected,
                      onTap: option.isAvailable
                          ? () => setState(() => _selectedType = option.type)
                          : null,
                      enabled: option.isAvailable,
                    );
                  },
                ),
              ),
              // Request button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedType != null
                        ? widget.onRequestRide
                        : null,
                    child: Text(
                      'Request ${_selectedType?.displayName ?? 'Ride'}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
