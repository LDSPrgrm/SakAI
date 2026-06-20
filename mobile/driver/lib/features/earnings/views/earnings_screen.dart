import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/earnings_notifier.dart';

/// Session-level earnings overview screen.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsState = ref.watch(earningsNotifierProvider);
    final earnings = earningsState.earnings;
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings — Current Shift'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.earningsBreakdown),
            icon: const Icon(Icons.bar_chart),
            label: const Text('Breakdown'),
          ),
        ],
      ),
      body: earningsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : earningsState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: scheme.error),
                  const SizedBox(height: 16),
                  Text('Error: ${earningsState.error}'),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(earningsNotifierProvider.notifier)
                        .loadEarnings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : earnings.completedRidesCount == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 64,
                    color: scheme.onSurface.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text(
                    'No rides completed yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(tokens.spaceMd),
              children: [
                // Summary card.
                SakaiGlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completed Rides',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${earnings.completedRidesCount}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.spaceMd),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earnings',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            SakaiCurrency.format(earnings.totalEarnings),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: SakaiSemanticColors.of(
                                    context,
                                  ).success,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.spaceLg),

                // Breakdown list.
                Text(
                  'Ride Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceSm),
                ...earnings.rideBreakdowns.map(
                  (b) => SakaiGlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ride ${b.rideId.substring(0, 8)}...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Fare: ${SakaiCurrency.format(b.fare)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (b.tip > 0)
                                Text(
                                  'Tip: ${SakaiCurrency.format(b.tip)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: SakaiSemanticColors.of(
                                          context,
                                        ).success,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          SakaiCurrency.format(b.total),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
