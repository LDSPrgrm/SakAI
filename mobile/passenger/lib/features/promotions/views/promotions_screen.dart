import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/promotions_view_model.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  late TextEditingController _promoCodeController;

  @override
  void initState() {
    super.initState();
    _promoCodeController = TextEditingController();
    Future.microtask(() {
      ref.read(promotionsNotifierProvider.notifier).fetchPromotions();
    });
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promotionsNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref.read(promotionsNotifierProvider.notifier).fetchPromotions(),
              child: ListView(
                padding: EdgeInsets.all(tokens.spaceLg),
                children: [
                  // Apply Promo Code section
                  Text(
                    'Have a promo code?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SakaiTextField(
                          controller: _promoCodeController,
                          hint: 'Enter promo code',
                          enabled: !state.isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: SakaiPrimaryButton(
                          label: 'Apply',
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final code = _promoCodeController.text.trim();
                                  if (code.isNotEmpty) {
                                    final success = await ref
                                        .read(promotionsNotifierProvider.notifier)
                                        .validatePromo(code);
                                    if (success && context.mounted) {
                                      _promoCodeController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Promo code applied successfully!'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (state.errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Available Offers',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (state.promotions.isEmpty && !state.isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'No promotions available right now.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                  ...state.promotions.map((promo) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceMd),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(tokens.spaceSm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(tokens.radiusSm),
                              ),
                              child: Icon(
                                Icons.local_offer,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    promo.code,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    promo.description.isNotEmpty ? promo.description : 'Discount offer',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (state.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
