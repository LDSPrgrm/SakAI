import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Two horizontal wallet cards: "Activate Pay" and "Use Points".
class HomeWalletCards extends StatelessWidget {
  const HomeWalletCards({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _WalletCard(
            gradient: LinearGradient(
              colors: [
                SakaiDesignTokens.walletPayGradientStart,
                SakaiDesignTokens.walletPayGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.account_balance_wallet_rounded,
            title: 'Activate SakPay',
            subtitle: 'Swipe to pay',
            badgeLabel: 'NEW',
          ),
          SizedBox(width: 12),
          _WalletCard(
            gradient: LinearGradient(
              colors: [
                SakaiDesignTokens.walletPointsGradientStart,
                SakaiDesignTokens.walletPointsGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.stars_rounded,
            title: 'Use Points',
            subtitle: '758 pts available',
            badgeLabel: 'EARN',
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
  });

  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spacing12,
        ),
        child: Row(
          children: [
            // Fixed brand-gradient card: white is the fixed contrast color,
            // not a themed surface color.
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
