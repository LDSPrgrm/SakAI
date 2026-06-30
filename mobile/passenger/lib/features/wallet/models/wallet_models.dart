class WalletBalance {
  const WalletBalance({required this.amount, required this.currency});
  final double amount;
  final String currency;
}

enum WalletTxnType { topup, ridePayment, refund, payout }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.type,
    required this.createdAt,
    this.description,
  });

  final String id;
  final double amount;
  final String currency;
  final WalletTxnType type;
  final DateTime createdAt;
  final String? description;

  bool get isDebit => type == WalletTxnType.ridePayment;
}
