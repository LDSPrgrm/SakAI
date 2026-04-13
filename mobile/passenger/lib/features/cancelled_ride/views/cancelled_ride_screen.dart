import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart' show cancelledRideRepositoryProvider;
import '../../../app/routes.dart';
import '../models/cancellation_details.dart';
import '../view_models/cancelled_ride_view_model.dart';

/// Provider family that creates a CancelledRideViewModel per rideId.
final _cancelledRideViewModelProvider =
    Provider.family<CancelledRideViewModel, String>((ref, rideId) {
      final repo = ref.watch(cancelledRideRepositoryProvider);
      final vm = CancelledRideViewModel(repository: repo);
      ref.onDispose(() => vm.dispose());
      return vm;
    });

/// Screen displayed when a ride has been cancelled.
///
/// Shows cancellation reason, driver info (if assigned), refund/fee details,
/// and actions to request a new ride or view a receipt.
class CancelledRideScreen extends ConsumerStatefulWidget {
  const CancelledRideScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<CancelledRideScreen> createState() =>
      _CancelledRideScreenState();
}

class _CancelledRideScreenState extends ConsumerState<CancelledRideScreen> {
  @override
  void initState() {
    super.initState();
    // Load on first build
    final vm = ref.read(_cancelledRideViewModelProvider(widget.rideId));
    vm.loadCancellation(widget.rideId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(_cancelledRideViewModelProvider(widget.rideId));
    return _buildContent(context, vm.state);
  }

  Widget _buildContent(BuildContext context, CancelledRideState state) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    if (state.status == CancelledRideStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.status == CancelledRideStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: tokens.spaceMd),
              Text(
                state.error ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: tokens.spaceMd),
              SakaiPrimaryButton(
                label: 'Retry',
                onPressed: () {
                  final vm = ref.read(
                    _cancelledRideViewModelProvider(widget.rideId),
                  );
                  vm.loadCancellation(widget.rideId);
                },
              ),
            ],
          ),
        ),
      );
    }

    final details = state.details!;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Cancelled')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cancellation illustration
            SizedBox(height: tokens.spaceLg),
            Icon(
              Icons.cancel_outlined,
              size: 80,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: tokens.spaceMd),
            Text(
              'Ride Cancelled',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              details.reason,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (details.hasReasonCode &&
                details.reasonCode != CancellationReason.other)
              Padding(
                padding: EdgeInsets.only(top: tokens.spaceXs),
                child: Chip(
                  label: Text(
                    details.reasonCode!.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            if (details.reasonText != null && details.reasonText!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: tokens.spaceXs),
                child: Text(
                  '"${details.reasonText}"',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(height: tokens.spaceXs),
            Text(
              'Cancelled on ${details.formattedCancelledAt}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),

            SizedBox(height: tokens.spaceLg),

            // Cancelled by badge
            Center(
              child: Chip(
                avatar: Icon(
                  _cancelledByIcon(details.cancelledBy),
                  size: 18,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                label: Text(
                  'Cancelled by ${details.cancelledBy.displayName}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Driver info card (if assigned)
            if (details.hasDriver)
              SakaiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driver', style: theme.textTheme.titleMedium),
                    SizedBox(height: tokens.spaceSm),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 28,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(width: tokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details.driverName!,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (details.driverVehicle != null) ...[
                                SizedBox(height: tokens.spaceXs),
                                Text(
                                  details.driverVehicle!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (details.hasDriver) SizedBox(height: tokens.spaceLg),

            // Route info card
            SakaiSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Planned Route', style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  _RoutePoint(
                    icon: Icons.circle,
                    label: details.originAddress ?? 'Pickup location',
                  ),
                  SizedBox(height: tokens.spaceSm),
                  _RoutePoint(
                    icon: Icons.location_on,
                    label: details.destinationAddress ?? 'Drop-off location',
                  ),
                ],
              ),
            ),

            SizedBox(height: tokens.spaceLg),

            // Refund / fee card
            if (details.hasRefund || details.hasFee)
              SakaiSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment', style: theme.textTheme.titleMedium),
                    SizedBox(height: tokens.spaceSm),
                    if (details.hasRefund)
                      _PaymentRow(
                        label: 'Refund',
                        value: details.formattedRefund,
                        valueColor: theme.colorScheme.primary,
                      ),
                    if (details.hasFee)
                      _PaymentRow(
                        label: 'Cancellation fee',
                        value: '-${details.formattedFee}',
                        valueColor: theme.colorScheme.error,
                      ),
                    if (details.hasRefund)
                      Padding(
                        padding: EdgeInsets.only(top: tokens.spaceSm),
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                    if (details.hasRefund)
                      _PaymentRow(
                        label: 'Net refund',
                        value: details.formattedRefund,
                        valueColor: theme.colorScheme.primary,
                        bold: true,
                      ),
                  ],
                ),
              ),

            SizedBox(height: tokens.spaceXl),

            // Action buttons
            SakaiPrimaryButton(
              label: 'Request New Ride',
              icon: Icons.directions_car,
              onPressed: () => context.go(Routes.home),
            ),

            if (details.hasRefund) ...[
              SizedBox(height: tokens.spaceMd),
              SakaiPrimaryButton(
                label: 'View Receipt',
                icon: Icons.receipt_long,
                onPressed: () => context.push(Routes.receipt),
              ),
            ],

            SizedBox(height: tokens.spaceMd),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    CancelledRideViewModel vm,
  ) async {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);
    CancellationReason? selectedReason;
    final reasonTextController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Cancel Ride'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Why are you cancelling this ride?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: tokens.spaceMd),
                    ...vm.reasonOptions.map((reason) {
                      final isSelected = selectedReason == reason;
                      return RadioListTile<CancellationReason>(
                        title: Text(reason.label),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedReason = value;
                            if (reason != CancellationReason.other) {
                              reasonTextController.clear();
                            }
                          });
                        },
                        dense: true,
                      );
                    }),
                    if (selectedReason == CancellationReason.other) ...[
                      SizedBox(height: tokens.spaceSm),
                      TextField(
                        controller: reasonTextController,
                        decoration: const InputDecoration(
                          labelText: 'Please specify',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 500,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          vm.selectReason(selectedReason!);
                          if (selectedReason == CancellationReason.other &&
                              reasonTextController.text.isNotEmpty) {
                            vm.setReasonText(reasonTextController.text);
                          }
                          Navigator.of(ctx).pop();
                        },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        SizedBox(width: 8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _cancelledByIcon(CancelledBy by) {
  switch (by) {
    case CancelledBy.passenger:
      return Icons.person;
    case CancelledBy.driver:
      return Icons.directions_car;
    default:
      return Icons.settings;
  }
}
