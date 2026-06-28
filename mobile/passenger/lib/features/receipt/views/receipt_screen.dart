import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/ride_receipt.dart';
import '../services/receipt_pdf_builder.dart';
import '../view_models/receipt_view_model.dart';

/// Receipt screen displaying a professional fare breakdown for a completed ride.
class ReceiptScreen extends ConsumerStatefulWidget {
  const ReceiptScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends ConsumerState<ReceiptScreen> {
  final GlobalKey _receiptKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(receiptNotifierProvider.notifier).loadReceipt(widget.rideId),
    );
  }

  Future<void> _onShareReceipt() async {
    try {
      final boundary =
          _receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/receipt_${widget.rideId}.png',
      ).writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'SakAI Ride Receipt',
          text: 'Receipt for your SakAI ride',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share receipt: $e')));
      }
    }
  }

  Future<void> _onShareReceiptPdf() async {
    try {
      final receipt = ref.read(receiptNotifierProvider).receipt;
      if (receipt == null) return;
      final bytes = await ReceiptPdfBuilder.build(receipt);
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/receipt_${widget.rideId}.pdf',
      ).writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'SakAI Ride Receipt',
          text: 'PDF receipt for your SakAI ride',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptNotifierProvider);
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Ride Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (state.status == ReceiptStatus.success) ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Share as PDF',
              onPressed: _onShareReceiptPdf,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Receipt',
              onPressed: _onShareReceipt,
            ),
          ],
        ],
      ),
      body: _buildBody(state, tokens, theme),
    );
  }

  Widget _buildBody(
    ReceiptState state,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    switch (state.status) {
      case ReceiptStatus.initial:
      case ReceiptStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case ReceiptStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: tokens.spaceMd),
              Text(
                state.error ?? 'Failed to load receipt',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: tokens.spaceMd),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(receiptNotifierProvider.notifier)
                    .loadReceipt(widget.rideId),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );

      case ReceiptStatus.success:
        final receipt = state.receipt!;
        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: RepaintBoundary(
            key: _receiptKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(receipt, tokens, theme),
                SizedBox(height: tokens.spaceLg),
                _buildTripSummary(receipt, tokens, theme),
                SizedBox(height: tokens.spaceLg),
                _buildFareBreakdown(receipt, tokens, theme),
                SizedBox(height: tokens.spaceLg),
                _buildPaymentInfo(receipt, tokens, theme),
                SizedBox(height: tokens.spaceXl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onShareReceipt,
                    icon: const Icon(Icons.share),
                    label: const Text('Share Receipt'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(tokens.spaceMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildHeader(
    RideReceipt receipt,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    return SakaiSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              'Ride Receipt',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spaceXs),
            Text(
              receipt.paymentStatusLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: receipt.paymentStatus == 'completed'
                    ? SakaiSemanticColors.of(context).success
                    : theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (receipt.formattedDate != null) ...[
              SizedBox(height: tokens.spaceXs),
              Text(
                receipt.formattedDate!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary(
    RideReceipt receipt,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    return SakaiSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(height: tokens.spaceSm),
            _InfoRow(
              label: 'Passenger',
              value: receipt.passengerName,
              icon: Icons.person_outline,
            ),
            SizedBox(height: tokens.spaceSm),
            _InfoRow(
              label: 'Driver',
              value: receipt.driverName,
              icon: Icons.drive_eta,
            ),
            if (receipt.pickupAddress != null) ...[
              SizedBox(height: tokens.spaceSm),
              _InfoRow(
                label: 'From',
                value: receipt.pickupAddress!,
                icon: Icons.circle,
                iconColor: SakaiSemanticColors.of(context).success,
              ),
            ],
            if (receipt.destinationAddress != null) ...[
              SizedBox(height: tokens.spaceSm),
              _InfoRow(
                label: 'To',
                value: receipt.destinationAddress!,
                icon: Icons.location_on,
                iconColor: SakaiSemanticColors.of(context).danger,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFareBreakdown(
    RideReceipt receipt,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    final breakdown = receipt.fareBreakdown;
    final hasBreakdown = breakdown != null && breakdown.isNotEmpty;

    final baseFare = hasBreakdown
        ? (breakdown['base_fare'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    final distanceCharge = hasBreakdown
        ? (breakdown['distance_charge'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    final timeCharge = hasBreakdown
        ? (breakdown['time_charge'] as num?)?.toDouble() ?? 0.0
        : 0.0;
    final bookingFee = hasBreakdown
        ? (breakdown['booking_fee'] as num?)?.toDouble() ?? 0.0
        : 0.0;

    return SakaiSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fare Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(height: tokens.spaceSm),
            // P7 phased reveal — fare components animate in one-by-one
            // so the breakdown reads like a running tally rather than a
            // dump. Divider + total stay outside the reveal so they
            // remain anchored.
            SakaiPhasedReveal(
              spacing: tokens.spaceXs,
              children: [
                if (receipt.estimatedFare != null)
                  _FareRow(
                    label: 'Estimated Fare',
                    amount: receipt.formatAmount(receipt.estimatedFare!),
                  ),
                if (receipt.actualFare != null)
                  _FareRow(
                    label: 'Actual Fare',
                    amount: receipt.formatAmount(receipt.actualFare!),
                    highlight: true,
                  ),
                if (hasBreakdown) ...[
                  _FareRow(
                    label: 'Base Fare',
                    amount: receipt.formatAmount(baseFare),
                  ),
                  _FareRow(
                    label: 'Distance Charge',
                    amount: receipt.formatAmount(distanceCharge),
                  ),
                  _FareRow(
                    label: 'Time Charge',
                    amount: receipt.formatAmount(timeCharge),
                  ),
                  _FareRow(
                    label: 'Booking Fee',
                    amount: receipt.formatAmount(bookingFee),
                  ),
                ],
              ],
            ),
            if (hasBreakdown) ...[
              const Divider(),
              SizedBox(height: tokens.spaceSm),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  receipt.totalLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(
    RideReceipt receipt,
    SakaiDesignTokens tokens,
    ThemeData theme,
  ) {
    return SakaiSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            SizedBox(height: tokens.spaceSm),
            Row(
              children: [
                Icon(
                  receipt.paymentMethod == 'cash'
                      ? Icons.money
                      : Icons.credit_card,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: tokens.spaceSm),
                Expanded(
                  child: Text(
                    receipt.paymentMethodLabel,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spaceSm,
                    vertical: tokens.spaceXs,
                  ),
                  decoration: BoxDecoration(
                    color: receipt.paymentStatus == 'completed'
                        ? SakaiSemanticColors.of(
                            context,
                          ).success.withValues(alpha: 0.1)
                        : theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Text(
                    receipt.paymentStatusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: receipt.paymentStatus == 'completed'
                          ? SakaiSemanticColors.of(context).success
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor ?? scheme.onSurfaceVariant),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final String amount;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            color: highlight ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
