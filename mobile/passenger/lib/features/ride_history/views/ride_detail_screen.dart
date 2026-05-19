import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../models/ride_detail.dart';
import '../view_models/ride_detail_view_model.dart'
    show rideDetailNotifierProvider, RideDetailState, RideDetailStatus;

/// Converts an API client [LatLng] to a google_maps_flutter [gmaps.LatLng].
gmaps.LatLng _toGmapsLatLng(LatLng api) {
  return gmaps.LatLng(api.lat, api.lng);
}

/// Ride detail screen with map, trip info, and action buttons.
class RideDetailScreen extends ConsumerStatefulWidget {
  const RideDetailScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends ConsumerState<RideDetailScreen> {
  final Set<gmaps.Marker> _markers = {};
  final Set<gmaps.Polyline> _polylines = {};
  RideDetailState _state = const RideDetailState();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(rideDetailNotifierProvider(widget.rideId)).loadDetail(),
    );
    // Listen to notifier changes
    final notifier = ref.read(rideDetailNotifierProvider(widget.rideId));
    notifier.addListener(_onNotifierChanged);
  }

  void _onNotifierChanged() {
    if (!mounted) return;
    final notifier = ref.read(rideDetailNotifierProvider(widget.rideId));
    setState(() => _state = notifier.state);
  }

  @override
  void dispose() {
    final notifier = ref.read(rideDetailNotifierProvider(widget.rideId));
    notifier.removeListener(_onNotifierChanged);
    super.dispose();
  }

  void _onMapCreated(gmaps.GoogleMapController controller) {
    // Keep reference if needed for later map manipulation
  }

  void _onRebook() {
    final state = ref.read(rideDetailNotifierProvider(widget.rideId)).state;
    final detail = state.detail;
    if (detail == null) return;
    // Navigate to home with destination pre-filled via query extras
    context.go(
      Routes.home,
      extra: {'destinationAddress': detail.destinationAddress},
    );
  }

  void _onViewReceipt() {
    context.push(Routes.receipt.replaceFirst(':rideId', widget.rideId));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(title: const Text('Ride Details')),
      body: _buildBody(_state, tokens, theme),
    );
  }

  Widget _buildBody(
    RideDetailState state,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    switch (state.status) {
      case RideDetailStatus.initial:
      case RideDetailStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case RideDetailStatus.error:
        return SakaiErrorState(
          message: state.error ?? 'Failed to load ride details',
          onRetry: () => ref
              .read(rideDetailNotifierProvider(widget.rideId))
              .loadDetail(),
        );

      case RideDetailStatus.success:
        final detail = state.detail as RideDetail;
        return _buildDetailContent(detail, tokens, theme);
    }
  }

  Widget _buildDetailContent(
    RideDetail detail,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    _updateMarkers(detail);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              child: gmaps.GoogleMap(
                initialCameraPosition: gmaps.CameraPosition(
                  target: _toGmapsLatLng(detail.origin),
                  zoom: 12,
                ),
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: _onMapCreated,
              ),
            ),
          ),

          SizedBox(height: tokens.spaceLg),

          // Trip Info Card
          SakaiSurfaceCard(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Information', style: theme.textTheme.titleMedium),
                  const Divider(),
                  _InfoRow(
                    label: 'From',
                    value: detail.originAddress,
                    icon: Icons.circle,
                    iconColor: SakaiSemanticColors.of(context).success,
                  ),
                  SizedBox(height: tokens.spaceSm),
                  _InfoRow(
                    label: 'To',
                    value: detail.destinationAddress,
                    icon: Icons.location_on,
                    iconColor: SakaiSemanticColors.of(context).danger,
                  ),
                  const Divider(),
                  _InfoRow(
                    label: 'Fare',
                    value: detail.displayFare,
                    bold: true,
                  ),
                  SizedBox(height: tokens.spaceXs),
                  _InfoRow(
                    label: 'Payment',
                    value:
                        detail.paymentMethod[0].toUpperCase() +
                        detail.paymentMethod.substring(1),
                  ),
                  if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                    SizedBox(height: tokens.spaceXs),
                    _InfoRow(label: 'Notes', value: detail.notes!),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: tokens.spaceLg),

          // Driver Card
          if (detail.driverName != null)
            SakaiSurfaceCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Driver', style: theme.textTheme.titleMedium),
                    const Divider(),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person, size: 28),
                        ),
                        SizedBox(width: tokens.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.driverName!,
                                style: theme.textTheme.titleSmall,
                              ),
                              if (detail.driverVehicle != null)
                                Text(
                                  detail.driverVehicle!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: tokens.spaceLg),

          // Timeline Card
          SakaiSurfaceCard(
            child: Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Timeline', style: theme.textTheme.titleMedium),
                  const Divider(),
                  ...detail.timelineLabels.entries
                      .where((e) => e.value != null)
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: tokens.spaceXs),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: theme.textTheme.bodyMedium),
                              Text(
                                e.value!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          // Cancellation info
          if (detail.isCancelled && detail.cancellationReason != null) ...[
            SizedBox(height: tokens.spaceLg),
            SakaiSurfaceCard(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    SizedBox(width: tokens.spaceSm),
                    Expanded(
                      child: Text(
                        detail.cancellationReason!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: tokens.spaceXl),

          // Action Buttons
          if (detail.isCompleted) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onRebook,
                icon: const Icon(Icons.replay),
                label: const Text('Rebook This Ride'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(tokens.spaceMd),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onViewReceipt,
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(tokens.spaceMd),
                ),
              ),
            ),
          ],

          SizedBox(height: tokens.spaceLg),
        ],
      ),
    );
  }

  void _updateMarkers(RideDetail detail) {
    _markers.clear();
    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('origin'),
        position: _toGmapsLatLng(detail.origin),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueGreen,
        ),
        infoWindow: const gmaps.InfoWindow(title: 'Pickup'),
      ),
    );
    _markers.add(
      gmaps.Marker(
        markerId: const gmaps.MarkerId('destination'),
        position: _toGmapsLatLng(detail.destination),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
          gmaps.BitmapDescriptor.hueRed,
        ),
        infoWindow: const gmaps.InfoWindow(title: 'Drop-off'),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
