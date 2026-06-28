import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../models/payment_method.dart';
import '../view_models/payment_methods_list_view_model.dart';

/// Payment methods list screen.
/// Displays saved payment methods with swipe-to-remove and tap-to-set-default.
class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    // Load on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentMethodsListProvider.notifier).loadMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentMethodsListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.paymentMethodAdd),
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: _buildBody(context, state, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PaymentMethodsListState state,
    ThemeData theme,
  ) {
    switch (state.status) {
      case PaymentMethodsStatus.initial:
      case PaymentMethodsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case PaymentMethodsStatus.loaded:
        if (state.methods.isEmpty) {
          return _EmptyState(
            onAdd: () => context.push(Routes.paymentMethodAdd),
          );
        }
        return _buildList(state, theme);

      case PaymentMethodsStatus.error:
        return _ErrorState(
          message: state.errorMessage ?? 'Failed to load payment methods',
          onRetry: () =>
              ref.read(paymentMethodsListProvider.notifier).loadMethods(),
        );
    }
  }

  Widget _buildList(PaymentMethodsListState state, ThemeData theme) {
    final notifier = ref.read(paymentMethodsListProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      // PERFORMANCE: ListView.builder ensures only visible payment method tiles
      // are built, keeping render cost O(1) regardless of total method count.
      child: ListView.builder(
        padding: EdgeInsets.all(SakaiDesignTokens.of(context).spaceMd),
        itemCount: state.sortedMethods.length,
        itemBuilder: (context, index) {
          final method = state.sortedMethods[index];
          return _PaymentMethodTile(
            method: method,
            onSetDefault: () => _handleSetDefault(method.id),
            onRemove: () => _handleRemove(method.id, method.displayName),
          );
        },
      ),
    );
  }

  Future<void> _handleSetDefault(String methodId) async {
    final success = await ref
        .read(paymentMethodsListProvider.notifier)
        .setDefault(methodId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default payment method updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final state = ref.read(paymentMethodsListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Failed to update default'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleRemove(String methodId, String displayName) async {
    final confirmed = await _showRemoveConfirmation(context, displayName);
    if (confirmed != true) return;

    final success = await ref
        .read(paymentMethodsListProvider.notifier)
        .removeMethod(methodId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName removed'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Reload the list to restore the method
                ref.read(paymentMethodsListProvider.notifier).refresh();
              },
            ),
          ),
        );
      } else {
        final state = ref.read(paymentMethodsListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'Failed to remove method'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool?> _showRemoveConfirmation(
    BuildContext context,
    String displayName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Payment Method'),
        content: Text('Are you sure you want to remove "$displayName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Method Tile ──────────────────────────────────────────

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.method,
    required this.onSetDefault,
    required this.onRemove,
  });

  final PaymentMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SakaiSurfaceCard(
      onTap: onSetDefault,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              method.icon,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (method.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Default',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    'Tap to set as default',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No payment methods',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a payment method to book rides.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SakaiPrimaryButton(
              label: 'Add Payment Method',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load payment methods',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SakaiPrimaryButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
