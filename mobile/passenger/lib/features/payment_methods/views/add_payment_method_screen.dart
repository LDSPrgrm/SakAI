import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/payment_method.dart';
import '../view_models/add_payment_method_view_model.dart';
import '../view_models/payment_methods_list_view_model.dart';

/// Add payment method screen.
/// Presents a type selector and conditional form based on the chosen type.
class AddPaymentMethodScreen extends ConsumerStatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  ConsumerState<AddPaymentMethodScreen> createState() =>
      _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState
    extends ConsumerState<AddPaymentMethodScreen> {
  final _cardNumberFocus = FocusNode();
  final _expiryMonthFocus = FocusNode();
  final _expiryYearFocus = FocusNode();

  @override
  void dispose() {
    _cardNumberFocus.dispose();
    _expiryMonthFocus.dispose();
    _expiryYearFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addPaymentMethodProvider);
    final notifier = ref.read(addPaymentMethodProvider.notifier);
    final theme = Theme.of(context);

    // Listen for success state and navigate back
    ref.listen<AddPaymentMethodState>(addPaymentMethodProvider, (
      previous,
      next,
    ) {
      if (next.status == AddPaymentMethodStatus.success &&
          previous?.status != AddPaymentMethodStatus.success) {
        // Refresh the list and navigate back
        ref.read(paymentMethodsListProvider.notifier).refresh();
        if (context.mounted) {
          context.pop(true); // Return true to signal success
        }
      }
    });

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Add Payment Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.status == AddPaymentMethodStatus.adding
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Type Selector
                          Text(
                            'Payment Type',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PaymentTypeSelector(
                            selectedType: state.selectedType,
                            onTypeSelected: notifier.selectType,
                          ),
                          const SizedBox(height: 24),

                          // Conditional Form
                          _buildFormForType(state, notifier, theme),

                          // Error Message
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme.colorScheme.onErrorContainer,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onErrorContainer,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Set as Default Checkbox
                          CheckboxListTile(
                            title: const Text('Set as default payment method'),
                            value: state.setAsDefault,
                            onChanged: (value) =>
                                notifier.toggleSetAsDefault(value ?? false),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Save Button (fixed at bottom)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SakaiPrimaryButton(
                      label: 'Save Payment Method',
                      icon: Icons.save,
                      onPressed: () => notifier.addPaymentMethod(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFormForType(
    AddPaymentMethodState state,
    AddPaymentMethodNotifier notifier,
    ThemeData theme,
  ) {
    switch (state.selectedType) {
      case DomainPaymentMethodType.card:
        return _CardForm(
          cardNumber: state.cardNumber,
          expiryMonth: state.expiryMonth,
          expiryYear: state.expiryYear,
          cvv: state.cvv,
          onCardNumberChanged: notifier.updateCardNumber,
          onExpiryMonthChanged: notifier.updateExpiryMonth,
          onExpiryYearChanged: notifier.updateExpiryYear,
          onCVVChanged: notifier.updateCVV,
          cardNumberFocus: _cardNumberFocus,
          expiryMonthFocus: _expiryMonthFocus,
          expiryYearFocus: _expiryYearFocus,
        );

      case DomainPaymentMethodType.eWallet:
        return _EWalletForm(
          selectedProvider: state.selectedProvider,
          accountId: state.eWalletAccountId,
          onProviderSelected: notifier.selectProvider,
          onAccountIdChanged: notifier.updateEWalletAccountId,
        );

      case DomainPaymentMethodType.cash:
        return _CashConfirmation(theme: theme);
    }
  }
}

// ─── Payment Type Selector ────────────────────────────────────────

class _PaymentTypeSelector extends StatelessWidget {
  const _PaymentTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
  });

  final DomainPaymentMethodType selectedType;
  final ValueChanged<DomainPaymentMethodType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: DomainPaymentMethodType.values.map((type) {
        final isSelected = type == selectedType;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _PaymentTypeChip(
              type: type,
              isSelected: isSelected,
              onTap: () => onTypeSelected(type),
              theme: theme,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentTypeChip extends StatelessWidget {
  const _PaymentTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final DomainPaymentMethodType type;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  IconData get _icon {
    switch (type) {
      case DomainPaymentMethodType.card:
        return Icons.credit_card;
      case DomainPaymentMethodType.eWallet:
        return Icons.account_balance_wallet;
      case DomainPaymentMethodType.cash:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _icon,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              type.label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Card Form ────────────────────────────────────────────────────

class _CardForm extends StatelessWidget {
  const _CardForm({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.onCardNumberChanged,
    required this.onExpiryMonthChanged,
    required this.onExpiryYearChanged,
    required this.onCVVChanged,
    required this.cardNumberFocus,
    required this.expiryMonthFocus,
    required this.expiryYearFocus,
  });

  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryMonthChanged;
  final ValueChanged<String> onExpiryYearChanged;
  final ValueChanged<String> onCVVChanged;
  final FocusNode cardNumberFocus;
  final FocusNode expiryMonthFocus;
  final FocusNode expiryYearFocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SakaiTextField(
          controller: TextEditingController(text: cardNumber),
          label: 'Card Number',
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          onChanged: onCardNumberChanged,
          prefixIcon: const Icon(Icons.credit_card),
          focusNode: cardNumberFocus,
          textInputAction: TextInputAction.next,
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SakaiTextField(
                controller: TextEditingController(text: expiryMonth),
                label: 'Exp. Month',
                hint: 'MM',
                keyboardType: TextInputType.number,
                onChanged: onExpiryMonthChanged,
                focusNode: expiryMonthFocus,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SakaiTextField(
                controller: TextEditingController(text: expiryYear),
                label: 'Exp. Year',
                hint: 'YY',
                keyboardType: TextInputType.number,
                onChanged: onExpiryYearChanged,
                focusNode: expiryYearFocus,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SakaiTextField(
                controller: TextEditingController(text: cvv),
                label: 'CVV',
                hint: '123',
                keyboardType: TextInputType.number,
                obscureText: true,
                onChanged: onCVVChanged,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Card details will be securely processed via Stripe.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── E-Wallet Form ────────────────────────────────────────────────

class _EWalletForm extends StatelessWidget {
  const _EWalletForm({
    required this.selectedProvider,
    required this.accountId,
    required this.onProviderSelected,
    required this.onAccountIdChanged,
  });

  final String selectedProvider;
  final String accountId;
  final ValueChanged<String> onProviderSelected;
  final ValueChanged<String> onAccountIdChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Provider',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EWalletProviders.all.map((provider) {
            final isSelected = provider == selectedProvider;
            return ChoiceChip(
              label: Text(provider),
              selected: isSelected,
              onSelected: (_) => onProviderSelected(provider),
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: isSelected
                  ? BorderSide(color: theme.colorScheme.primary, width: 2)
                  : null,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        SakaiTextField(
          controller: TextEditingController(text: accountId),
          label: selectedProvider.isNotEmpty
              ? '$selectedProvider Account ID / Phone'
              : 'Account ID / Phone',
          hint: '09XXXXXXXXX',
          keyboardType: TextInputType.phone,
          onChanged: onAccountIdChanged,
          prefixIcon: const Icon(Icons.person_outline),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the phone number or account ID linked to your e-wallet.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Cash Confirmation ────────────────────────────────────────────

class _CashConfirmation extends StatelessWidget {
  const _CashConfirmation({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payments,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Pay with Cash',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will pay the driver in cash at the end of your ride. '
            'Please ensure you have exact change ready.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
