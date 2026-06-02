import 'dart:ui' show ImageFilter;
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
          // Map + Floating Badge
          Stack(
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusLg - 1),
                  child: gmaps.GoogleMap(
                    initialCameraPosition: gmaps.CameraPosition(
                      target: _toGmapsLatLng(detail.origin),
                      zoom: 12.5,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: _onMapCreated,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusFull),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(tokens.radiusFull),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: _statusColor(detail.status, context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            detail.statusLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          SizedBox(height: tokens.spaceLg),

          // Trip Info Card (Signature Route Timeline)
          Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Route Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: SakaiSemanticColors.of(context).success,
                        ),
                        Container(
                          width: 1.5,
                          height: 52,
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: SakaiSemanticColors.of(context).danger,
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail.originAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Drop-off Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail.destinationAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
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

          SizedBox(height: tokens.spaceMd),

          // Fare & Payment Dash
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Fare',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.displayFare,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            detail.paymentMethod.toLowerCase() == 'cash'
                                ? Icons.payments_outlined
                                : Icons.credit_card_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            detail.paymentMethod[0].toUpperCase() +
                                detail.paymentMethod.substring(1),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            SizedBox(height: tokens.spaceMd),
            Container(
              padding: EdgeInsets.all(tokens.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.notes, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      detail.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: tokens.spaceLg),

          // Driver Card
          if (detail.driverName != null) ...[
            Container(
              padding: EdgeInsets.all(tokens.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Driver',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                        child: Icon(Icons.person, size: 28, color: theme.colorScheme.primary),
                      ),
                      SizedBox(width: tokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.driverName!,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (detail.driverVehicle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                detail.driverVehicle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
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
            SizedBox(height: tokens.spaceLg),
          ],

          // Timeline Stepper Card
          Container(
            padding: EdgeInsets.all(tokens.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                ...detail.timelineLabels.entries
                    .where((e) => e.value != null)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      final idx = entry.key;
                      final e = entry.value;
                      final timelineItems = detail.timelineLabels.entries.where((el) => el.value != null).toList();
                      final isLast = idx == timelineItems.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 38,
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.value!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),

          // Cancellation info
          if (detail.isCancelled && detail.cancellationReason != null) ...[
            SizedBox(height: tokens.spaceLg),
            Container(
              padding: EdgeInsets.all(tokens.spaceMd),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.08),
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.error),
                  SizedBox(width: tokens.spaceSm),
                  Expanded(
                    child: Text(
                      detail.cancellationReason!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: tokens.spaceXl),

          // Action Buttons
          if (detail.isCompleted) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onRebook,
                icon: const Icon(Icons.replay),
                label: const Text('Rebook This Ride'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusFull),
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _onViewReceipt,
                icon: const Icon(Icons.receipt_long),
                label: const Text('View Receipt'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusFull),
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: tokens.spaceLg),
        ],
      ),
    );
  }

  Color _statusColor(RideStatus status, BuildContext context) {
    if (status == RideStatus.completed) return SakaiSemanticColors.of(context).success;
    if (status == RideStatus.cancelled) return SakaiSemanticColors.of(context).danger;
    return SakaiSemanticColors.of(context).accentBlue;
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

