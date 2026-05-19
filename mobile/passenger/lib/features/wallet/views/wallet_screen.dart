import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/wallet_models.dart';
import '../view_models/wallet_notifier.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletNotifierProvider);
    final notifier = ref.read(walletNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: SakaiAppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: _body(context, state, notifier, t),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WalletViewState state,
    WalletNotifier notifier,
    SakaiDesignTokens t,
  ) {
    if (state.loading && state.balance == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Only swap to ComingSoonState when we never got data. If balance is
    // already loaded and a later top-up trips the typed exception, keep the
    // UI and surface the error inline via the existing snackbar path.
    if (state.backendUnavailable != null && state.balance == null) {
      return const ComingSoonState(feature: 'Wallet');
    }
    if (state.errorMessage != null && state.balance == null) {
      return SakaiEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Wallet unavailable',
        message: state.errorMessage,
        primaryLabel: 'Retry',
        onPrimary: notifier.load,
      );
    }

    final balance = state.balance!;
    return ListView(
      padding: EdgeInsets.all(t.spaceMd),
      children: [
        _BalanceCard(balance: balance),
        SizedBox(height: t.spaceMd),
        SakaiPrimaryButton(
          icon: Icons.add_circle_outline,
          label: 'Add money',
          onPressed: state.loading
              ? null
              : () => _showTopUpSheet(context, notifier, balance.currency),
        ),
        SizedBox(height: t.spaceLg),
        Text(
          'Recent transactions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: t.spaceSm),
        if (state.transactions.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: t.spaceLg),
            child: Center(
              child: Text(
                'No transactions yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final txn in state.transactions) _TxnTile(txn: txn),
      ],
    );
  }

  void _showTopUpSheet(
    BuildContext context,
    WalletNotifier notifier,
    String currency,
  ) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final t = SakaiDesignTokens.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: t.spaceLg,
            right: t.spaceLg,
            top: t.spaceLg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + t.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add money', style: Theme.of(ctx).textTheme.titleLarge),
              SizedBox(height: t.spaceMd),
              SakaiTextField(
                controller: controller,
                label: 'Amount ($currency)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: t.spaceMd),
              SakaiPrimaryButton(
                label: 'Top up',
                onPressed: () {
                  final amount = double.tryParse(controller.text);
                  if (amount == null || amount <= 0) return;
                  Navigator.of(ctx).pop();
                  notifier.topUp(amount, currency);
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final WalletBalance balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    return SakaiGlassCard(
      child: Padding(
        padding: EdgeInsets.all(t.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available balance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: t.spaceXs),
            Text(
              NumberFormat.currency(
                symbol: '${balance.currency} ',
              ).format(balance.amount),
              style: theme.textTheme.displaySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  const _TxnTile({required this.txn});
  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SakaiDesignTokens.of(context);
    final sign = txn.isDebit ? '-' : '+';
    final color = txn.isDebit
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: t.spaceSm),
      child: SakaiSurfaceCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description ?? _label(txn.type),
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: t.spaceXs),
                  Text(
                    DateFormat.yMMMd().add_jm().format(txn.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign${NumberFormat.currency(symbol: '${txn.currency} ').format(txn.amount.abs())}',
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  String _label(WalletTxnType type) {
    switch (type) {
      case WalletTxnType.topup:
        return 'Top-up';
      case WalletTxnType.ridePayment:
        return 'Ride payment';
      case WalletTxnType.refund:
        return 'Refund';
      case WalletTxnType.payout:
        return 'Payout';
    }
  }
}
