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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
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
    final scheme = Theme.of(context).colorScheme;

    if (state.status == PromotionsStatus.error) {
      return const SizedBox.shrink();
    }
    if (state.status == PromotionsStatus.loaded && state.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: state.isLoading
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
                  child: SakaiSkeleton.card(height: 160),
                )
              : PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: state.promotions.length,
                  itemBuilder: (context, i) {
                    final promo = state.promotions[i];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
                      child: _PromoCard(promotion: promo),
                    );
                  },
                ),
        ),
        if (!state.isLoading && state.promotions.length > 1) ...[
          SizedBox(height: tokens.spaceMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              state.promotions.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                width: _currentPage == index ? 16 : 4,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? scheme.primary
                      : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ],
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
          padding: EdgeInsets.all(tokens.spaceLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, scheme.secondary, 0.4)!,
              ],
            ),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spaceSm,
                      vertical: tokens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Text(
                      'LIMITED OFFER',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Text(
                    _discountLabel(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tokens.spaceXs),
              Text(
                promotion.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
