import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Result of the driver cancel reason sheet.
///
/// [reason] is the wire-level taxonomy pick. [note] is the optional
/// free-text explanation (relevant when [reason] is `otherDriverReason`).
class CancelReasonResult {
  const CancelReasonResult({required this.reason, this.note});

  final DriverCancelReason reason;
  final String? note;

  /// Serialised wire form for the legacy `reason_text` field while the
  /// OpenAPI v2 driver-cancel enum is pending (RFC v2 §8.6, API-1).
  String toReasonText() {
    final n = note;
    if (n != null && n.trim().isNotEmpty) {
      return '${reason.wire}: ${n.trim()}';
    }
    return reason.wire;
  }
}

/// Bottom-sheet picker for driver cancel reasons.
///
/// Returns null if the driver dismisses without confirming. Returns a
/// [CancelReasonResult] otherwise. The caller routes it through
/// `cancelRide(reasonText: result.toReasonText())`.
Future<CancelReasonResult?> showCancelReasonSheet(BuildContext context) {
  return showModalBottomSheet<CancelReasonResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => const _CancelReasonSheet(),
  );
}

class _CancelReasonSheet extends StatefulWidget {
  const _CancelReasonSheet();

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  DriverCancelReason? _selected;
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _needsNote => _selected == DriverCancelReason.otherDriverReason;

  bool get _canConfirm {
    if (_selected == null) return false;
    if (_needsNote && _note.text.trim().isEmpty) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spaceLg,
        right: tokens.spaceLg,
        top: tokens.spaceMd,
        bottom: tokens.spaceLg + viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Why are you cancelling?', style: theme.textTheme.titleLarge),
          SizedBox(height: tokens.spaceSm),
          Text(
            'This is logged for safety and dispatch quality.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          RadioGroup<DriverCancelReason>(
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v),
            child: Column(
              children: DriverCancelReason.ordered
                  .where((r) => r != DriverCancelReason.other)
                  .map(
                    (r) => RadioListTile<DriverCancelReason>(
                      value: r,
                      title: Text(r.label),
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_needsNote) ...[
            SizedBox(height: tokens.spaceSm),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Add a short note',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          SizedBox(height: tokens.spaceLg),
          SakaiPrimaryButton(
            label: 'Confirm cancellation',
            icon: Icons.cancel_outlined,
            onPressed: _canConfirm
                ? () => Navigator.of(context).pop(
                    CancelReasonResult(
                      reason: _selected!,
                      note: _needsNote ? _note.text : null,
                    ),
                  )
                : null,
          ),
          SizedBox(height: tokens.spaceSm),
          SakaiSecondaryButton(
            label: 'Keep ride',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
