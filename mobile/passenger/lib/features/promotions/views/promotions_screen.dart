import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
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

  Future<void> _applyPromo() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;
    final success = await ref
        .read(promotionsNotifierProvider.notifier)
        .validatePromo(code);
    if (success && mounted) {
      _promoCodeController.clear();
      final semanticColors = SakaiSemanticColors.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Promo code applied!',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: semanticColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(promotionsNotifierProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: scheme.primary,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: scheme.onPrimary),
                  onPressed: () {
                    if (context.canPop()) context.pop();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.75),
                          scheme.tertiary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative blurred circles
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.onPrimary.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scheme.onPrimary.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: scheme.onPrimary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.local_offer_rounded,
                                      color: scheme.onPrimary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Promotions',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: scheme.onPrimary,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Exclusive deals and discounts just for you',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(promotionsNotifierProvider.notifier)
                      .fetchPromotions(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Promo Code Entry Card ─────────────────────────────
                      Padding(
                        padding: EdgeInsets.all(tokens.spaceLg),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: EdgeInsets.all(tokens.spaceMd),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    scheme.primaryContainer.withValues(
                                      alpha: 0.5,
                                    ),
                                    scheme.surfaceContainerHighest.withValues(
                                      alpha: 0.4,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusLg,
                                ),
                                border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.confirmation_number_rounded,
                                        size: 18,
                                        color: scheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Have a promo code?',
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: scheme.onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: tokens.spaceSm),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: SakaiTextField(
                                          controller: _promoCodeController,
                                          hint: 'Enter code e.g. SAKAI20',
                                          enabled: !state.isLoading,
                                        ),
                                      ),
                                      SizedBox(width: tokens.spaceSm),
                                      SakaiPrimaryButton(
                                        label: 'Apply',
                                        expand: false,
                                        onPressed: state.isLoading
                                            ? null
                                            : _applyPromo,
                                      ),
                                    ],
                                  ),
                                  if (state.errorMessage != null &&
                                      state.promotions.isEmpty) ...[
                                    SizedBox(height: tokens.spaceSm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scheme.errorContainer.withValues(
                                          alpha: 0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          tokens.radiusSm,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 14,
                                            color: scheme.error,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            state.errorMessage!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: scheme.error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Section Label ─────────────────────────────────────
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spaceLg,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Available Offers',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (state.promotions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${state.promotions.length}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(height: tokens.spaceMd),

                      // ── Empty State ────────────────────────────────────────
                      if (state.promotions.isEmpty && !state.isLoading)
                        _EmptyPromotionsState(
                          tokens: tokens,
                          theme: theme,
                          scheme: scheme,
                        ),

                      // ── Promo Cards ────────────────────────────────────────
                      if (state.promotions.isNotEmpty)
                        ...state.promotions.map(
                          (promo) => Padding(
                            padding: EdgeInsets.fromLTRB(
                              tokens.spaceLg,
                              0,
                              tokens.spaceLg,
                              tokens.spaceMd,
                            ),
                            child: _PromoCard(promo: promo),
                          ),
                        ),

                      SizedBox(height: tokens.spaceXl),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (state.isLoading)
            Positioned.fill(
              child: ColoredBox(
                color: scheme.scrim.withValues(alpha: 0.12),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyPromotionsState extends StatelessWidget {
  const _EmptyPromotionsState({
    required this.tokens,
    required this.theme,
    required this.scheme,
  });

  final SakaiDesignTokens tokens;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spaceLg,
        vertical: tokens.spaceLg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                // Layered icon stack
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary.withValues(alpha: 0.06),
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.8),
                            scheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: scheme.onPrimary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'No Offers Right Now',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for exclusive deals,\ndiscounts, and special offers.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Tip badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _TipBadge(
                      icon: Icons.percent_rounded,
                      label: 'Ride discounts',
                      scheme: scheme,
                      theme: theme,
                    ),
                    _TipBadge(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Free rides',
                      scheme: scheme,
                      theme: theme,
                    ),
                    _TipBadge(
                      icon: Icons.star_rounded,
                      label: 'Loyalty rewards',
                      scheme: scheme,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipBadge extends StatelessWidget {
  const _TipBadge({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.theme,
  });
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Promo Card ───────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo});
  final api.Promotion promo;

  String _discountLabel() {
    if (promo.discountType == api.PromotionDiscountTypeEnum.percentage) {
      final pct = promo.discountValue.toStringAsFixed(0);
      final cap = promo.maxDiscount != null
          ? ' (up to ${SakaiCurrency.format(promo.maxDiscount!)})'
          : '';
      return '$pct% OFF$cap';
    }
    return '${SakaiCurrency.format(promo.discountValue)} OFF';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = SakaiDesignTokens.of(context);
    final expiry = DateFormat('MMM d, yyyy').format(promo.expiresAt.toLocal());
    final isExpiringSoon =
        promo.expiresAt.difference(DateTime.now()).inDays <= 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header band with gradient
              Container(
                padding: EdgeInsets.all(tokens.spaceMd),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.85),
                      scheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(tokens.radiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: scheme.onPrimary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promo.title?.isNotEmpty == true
                                ? promo.title!
                                : promo.code,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _discountLabel(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onPrimary.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promo.code,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details section
              Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promo.description.isNotEmpty)
                      Text(
                        promo.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    SizedBox(height: tokens.spaceSm),
                    Row(
                      children: [
                        if (promo.minRideAmount != null) ...[
                          Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Min. fare ${SakaiCurrency.format(promo.minRideAmount!)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: isExpiringSoon
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Expires $expiry',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isExpiringSoon
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                            fontWeight: isExpiringSoon
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        if (isExpiringSoon) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.errorContainer.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Expiring soon',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
