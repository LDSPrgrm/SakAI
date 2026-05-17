import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/wallet_models.dart';
import '../repositories/wallet_repository.dart';
import '../../../app/providers.dart';

class WalletViewState {
  const WalletViewState({
    this.loading = false,
    this.balance,
    this.transactions = const [],
    this.errorMessage,
  });

  final bool loading;
  final WalletBalance? balance;
  final List<WalletTransaction> transactions;
  final String? errorMessage;

  WalletViewState copyWith({
    bool? loading,
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
    String? errorMessage,
  }) {
    return WalletViewState(
      loading: loading ?? this.loading,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }
}

class WalletNotifier extends Notifier<WalletViewState> {
  @override
  WalletViewState build() {
    Future.microtask(load);
    return const WalletViewState(loading: true);
  }

  WalletRepository get _repo => ref.read(walletRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      final (balance, txns) = await (
        _repo.getBalance(),
        _repo.listTransactions(),
      ).wait;
      state = WalletViewState(balance: balance, transactions: txns);
    } on UnimplementedError catch (e) {
      state = WalletViewState(errorMessage: e.message);
    } catch (e) {
      state = WalletViewState(errorMessage: e.toString());
    }
  }

  Future<void> topUp(double amount, String currency) async {
    state = state.copyWith(loading: true, errorMessage: null);
    try {
      await _repo.topUp(amount: amount, currency: currency);
      await load();
    } on UnimplementedError catch (e) {
      state = state.copyWith(loading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, errorMessage: e.toString());
    }
  }
}

final walletNotifierProvider =
    NotifierProvider<WalletNotifier, WalletViewState>(WalletNotifier.new);
