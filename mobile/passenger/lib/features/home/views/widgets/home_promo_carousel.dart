import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../../app/routes.dart';
import '../../../promotions/view_models/promotions_view_model.dart';

class HomePromoCarousel extends ConsumerStatefulWidget {
  const HomePromoCarousel({super.key});

  @override
  ConsumerState<HomePromoCarousel> createState() => _HomePromoCarouselState();
}

class _HomePromoCarouselState extends ConsumerState<HomePromoCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
    Future.microtask(() {
      if (!mounted) return;
      final state = ref.read(promotionsNotifierProvider);
      if (state.status == PromotionsStatus.initial) {
        ref.read(promotionsNotifierProvider.notifier).fetchPromotions();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final state = ref.watch(promotionsNotifierProvider);

    if (state.status == PromotionsStatus.error) {
      return const SizedBox.shrink();
    }
    if (state.status == PromotionsStatus.loaded && state.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 140,
      child: state.isLoading
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
              child: Row(
                children: [
                  Expanded(child: SakaiSkeleton.card(height: 140)),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(child: SakaiSkeleton.card(height: 140)),
                ],
              ),
            )
          : PageView.builder(
              controller: _controller,
              itemCount: state.promotions.length,
              itemBuilder: (context, i) {
                final promo = state.promotions[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spaceSm),
                  child: _PromoCard(promotion: promo),
                );
              },
            ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promotion});

  final api.Promotion promotion;

  String _discountLabel() {
    final value = promotion.discountValue;
    if (promotion.discountType == api.PromotionDiscountTypeEnum.percentage) {
      return '${value.toStringAsFixed(0)}% OFF';
    }
    return '₱${value.toStringAsFixed(0)} OFF';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = promotion.title ?? promotion.code;

    return Semantics(
      label: 'Promotion: $title, code ${promotion.code}',
      button: true,
      child: SakaiTactile(
        onTap: () => context.push(Routes.promotions),
        child: Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.secondary],
            ),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            boxShadow: tokens.elevationMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spaceSm,
                      vertical: tokens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.onPrimary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Text(
                      _discountLabel(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                promotion.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: tokens.iconSm,
                    color: scheme.onPrimary,
                  ),
                  SizedBox(width: tokens.spaceXs),
                  Text(
                    promotion.code,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
