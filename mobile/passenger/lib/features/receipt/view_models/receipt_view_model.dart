import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart' show receiptRepositoryProvider;
import '../models/ride_receipt.dart';
import '../repositories/receipt_repository.dart';
import '../repositories/receipt_repository_impl.dart' show ReceiptException;

enum ReceiptStatus { initial, loading, success, error }

class ReceiptState {
  const ReceiptState({
    this.status = ReceiptStatus.initial,
    this.receipt,
    this.error,
  });

  final ReceiptStatus status;
  final RideReceipt? receipt;
  final String? error;

  ReceiptState copyWith({
    ReceiptStatus? status,
    RideReceipt? receipt,
    String? error,
    bool clearError = false,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipt: receipt ?? this.receipt,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final receiptNotifierProvider = NotifierProvider<ReceiptNotifier, ReceiptState>(
  ReceiptNotifier.new,
);

class ReceiptNotifier extends Notifier<ReceiptState> {
  @override
  ReceiptState build() => const ReceiptState();

  ReceiptRepository get _repo => ref.read(receiptRepositoryProvider);

  /// Load the receipt for a completed ride.
  Future<void> loadReceipt(String rideId) async {
    state = state.copyWith(status: ReceiptStatus.loading, clearError: true);
    try {
      final receipt = await _repo.getReceipt(rideId);
      state = state.copyWith(status: ReceiptStatus.success, receipt: receipt);
    } catch (e) {
      final message = e is ReceiptException
          ? e.userMessage
          : 'Failed to load receipt.';
      state = state.copyWith(status: ReceiptStatus.error, error: message);
    }
  }
}
