import '../models/wallet_models.dart';

/// Port for the rider wallet.
///
/// TODO(backend): No wallet endpoints exist yet. Expected contract:
///   * `GET  /users/me/wallet`               -> WalletBalance
///   * `GET  /users/me/wallet/transactions`  -> { items, nextCursor }
///   * `POST /users/me/wallet/topup`         -> { redirectUrl | success }
abstract class WalletRepository {
  Future<WalletBalance> getBalance();
  Future<List<WalletTransaction>> listTransactions({int limit = 20});
  Future<void> topUp({required double amount, required String currency});
}
