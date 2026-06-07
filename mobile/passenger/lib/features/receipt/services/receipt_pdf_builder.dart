import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/ride_receipt.dart';

/// Builds a PDF byte stream for a [RideReceipt].
///
/// Layout is deliberately conservative — no embedded fonts, no images —
/// so the document renders identically on every platform's PDF viewer.
/// The visual hierarchy mirrors the on-screen receipt: header, trip
/// summary, fare breakdown, payment block. PII (passenger / driver
/// names, addresses) is included because the user is sharing their own
/// receipt; consumers wanting to share without PII should redact in the
/// [RideReceipt] before calling this builder.
class ReceiptPdfBuilder {
  static Future<Uint8List> build(RideReceipt receipt) async {
    final doc = pw.Document(title: 'SakAI Ride Receipt', author: 'SakAI');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _header(receipt),
              pw.SizedBox(height: 20),
              _section('Trip Summary', _tripSummary(receipt)),
              pw.SizedBox(height: 16),
              _section('Fare Breakdown', _fareBreakdown(receipt)),
              pw.SizedBox(height: 16),
              _section('Payment', _paymentBlock(receipt)),
              pw.Spacer(),
              _footer(receipt),
            ],
          ),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(RideReceipt r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SakAI',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Ride Receipt',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 8),
        if (r.formattedDate != null)
          pw.Text(
            r.formattedDate!,
            style: pw.TextStyle(color: PdfColors.grey600),
          ),
        pw.Text(
          'Ride ID: ${r.rideId}',
          style: pw.TextStyle(color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _section(String title, pw.Widget body) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 6),
        body,
      ],
    );
  }

  static pw.Widget _tripSummary(RideReceipt r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _kv('Passenger', r.passengerName),
        _kv('Driver', r.driverName),
        if (r.pickupAddress != null) _kv('From', r.pickupAddress!),
        if (r.destinationAddress != null) _kv('To', r.destinationAddress!),
      ],
    );
  }

  static pw.Widget _fareBreakdown(RideReceipt r) {
    final rows = <pw.Widget>[];
    final breakdown = r.fareBreakdown;
    if (breakdown != null && breakdown.isNotEmpty) {
      double pick(String k) => (breakdown[k] as num?)?.toDouble() ?? 0.0;
      rows.add(_kv('Base Fare', r.formatAmount(pick('base_fare'))));
      rows.add(_kv('Distance Charge', r.formatAmount(pick('distance_charge'))));
      rows.add(_kv('Time Charge', r.formatAmount(pick('time_charge'))));
      rows.add(_kv('Booking Fee', r.formatAmount(pick('booking_fee'))));
    } else if (r.actualFare != null) {
      rows.add(_kv('Actual Fare', r.formatAmount(r.actualFare!)));
    } else if (r.estimatedFare != null) {
      rows.add(_kv('Estimated Fare', r.formatAmount(r.estimatedFare!)));
    }

    rows.add(pw.SizedBox(height: 8));
    rows.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            r.totalLabel,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  static pw.Widget _paymentBlock(RideReceipt r) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _kv('Method', r.paymentMethodLabel),
        _kv('Status', r.paymentStatusLabel),
      ],
    );
  }

  static pw.Widget _footer(RideReceipt r) {
    return pw.Center(
      child: pw.Text(
        'Thank you for riding with SakAI.',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
    );
  }

  static pw.Widget _kv(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Flexible(
            flex: 2,
            child: pw.Text(key, style: pw.TextStyle(color: PdfColors.grey700)),
          ),
          pw.SizedBox(width: 12),
          pw.Flexible(
            flex: 3,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
