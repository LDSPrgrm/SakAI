import 'package:sakai_shared/sakai_shared.dart';

import '../models/wallet_models.dart';
import 'wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._client);

  // ignore: unused_field
  final SakaiApiClient _client;

  @override
  Future<WalletBalance> getBalance() {
    // TODO(backend): wire to GET /users/me/wallet once endpoint exists.
    throw const BackendUnavailableException(feature: 'wallet');
  }

  @override
  Future<List<WalletTransaction>> listTransactions({int limit = 20}) {
    // TODO(backend): wire to GET /users/me/wallet/transactions.
    throw const BackendUnavailableException(feature: 'wallet');
  }

  @override
  Future<void> topUp({required double amount, required String currency}) {
    // TODO(backend): wire to POST /users/me/wallet/topup.
    throw const BackendUnavailableException(feature: 'wallet');
  }
}
