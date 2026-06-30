import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../models/session_earnings.dart';
import '../../../app/providers.dart';

enum _Range { week, month }

/// Weekly / monthly earnings breakdown — re-queries the existing earnings
/// repo with `from`/`to` date params per range.
class EarningsBreakdownScreen extends ConsumerStatefulWidget {
  const EarningsBreakdownScreen({super.key});

  @override
  ConsumerState<EarningsBreakdownScreen> createState() =>
      _EarningsBreakdownScreenState();
}

class _EarningsBreakdownScreenState
    extends ConsumerState<EarningsBreakdownScreen> {
  _Range _range = _Range.week;
  bool _loading = true;
  String? _error;
  SessionEarnings _earnings = const SessionEarnings();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final from = _range == _Range.week
          ? now.subtract(const Duration(days: 7))
          : DateTime(now.year, now.month - 1, now.day);
      final repo = ref.read(earningsRepositoryProvider);
      final result = await repo.getEarnings(from: from, to: now);
      if (!mounted) return;
      setState(() {
        _earnings = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Earnings breakdown'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: t.spaceMd, vertical: t.spaceSm),
            child: SegmentedButton<_Range>(
              segments: const [
                ButtonSegment(value: _Range.week, label: Text('Week')),
                ButtonSegment(value: _Range.month, label: Text('Month')),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                setState(() => _range = s.first);
                _load();
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? SakaiEmptyState(
                    icon: Icons.error_outline,
                    title: 'Couldn\'t load earnings',
                    message: _error,
                    primaryLabel: 'Retry',
                    onPrimary: _load,
                  )
                : ListView(
                    padding: EdgeInsets.all(t.spaceMd),
                    children: [
                      SakaiGlassCard(
                        child: Padding(
                          padding: EdgeInsets.all(t.spaceLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: t.spaceXs),
                              Text(
                                NumberFormat.currency(symbol: '\$')
                                    .format(_earnings.totalEarnings),
                                style: theme.textTheme.displaySmall,
                              ),
                              SizedBox(height: t.spaceSm),
                              Text(
                                '${_earnings.completedRidesCount} completed rides',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: t.spaceMd),
                      Text(
                        'Per-ride breakdown',
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: t.spaceSm),
                      if (_earnings.rideBreakdowns.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: t.spaceMd),
                          child: Center(
                            child: Text(
                              'No rides in this range yet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        SakaiPhasedReveal(
                          spacing: t.spaceXs,
                          children: [
                            for (final r in _earnings.rideBreakdowns)
                              SakaiSurfaceCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat.yMMMd()
                                                .add_jm()
                                                .format(r.completedAt),
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Fare ${NumberFormat.currency(symbol: '\$').format(r.fare)} • Tip ${NumberFormat.currency(symbol: '\$').format(r.tip)}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(symbol: '\$')
                                          .format(r.total),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
      ),
    );
  }
}
